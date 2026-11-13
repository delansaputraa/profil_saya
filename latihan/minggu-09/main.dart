import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const AplikasiCatatan());

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------
class Catatan {
  Catatan({required this.judul, required this.isi, this.pathFoto});

  final String judul;
  final String isi;
  final String? pathFoto;
}

// ---------------------------------------------------------------------------
// Aplikasi
// ---------------------------------------------------------------------------
class AplikasiCatatan extends StatelessWidget {
  const AplikasiCatatan({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Bergambar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const DaftarCatatan(),
    );
  }
}

// ---------------------------------------------------------------------------
// Halaman daftar catatan (disimpan di memori; persistensi dibahas Minggu 13)
// ---------------------------------------------------------------------------
class DaftarCatatan extends StatefulWidget {
  const DaftarCatatan({super.key});

  @override
  State<DaftarCatatan> createState() => _DaftarCatatanState();
}

class _DaftarCatatanState extends State<DaftarCatatan> {
  final List<Catatan> _daftar = [];

  Future<void> _bukaForm({int? indeks}) async {
    final hasil = await Navigator.push<Catatan>(
      context,
      MaterialPageRoute(
        builder: (_) => FormCatatan(awal: indeks == null ? null : _daftar[indeks]),
      ),
    );
    if (hasil == null || !mounted) return;
    setState(() {
      if (indeks == null) {
        _daftar.insert(0, hasil);
      } else {
        _daftar[indeks] = hasil;
      }
    });
  }

  void _hapus(int indeks) {
    setState(() => _daftar.removeAt(indeks));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catatan Bergambar')),
      body: _daftar.isEmpty
          ? const Center(child: Text('Belum ada catatan. Ketuk + untuk menambah.'))
          : ListView.separated(
        itemCount: _daftar.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final c = _daftar[i];
          return ListTile(
            leading: _Thumbnail(path: c.pathFoto),
            title: Text(c.judul),
            subtitle: Text(c.isi, maxLines: 2, overflow: TextOverflow.ellipsis),
            onTap: () => _bukaForm(indeks: i),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Hapus',
              onPressed: () => _hapus(i),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _bukaForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    const ukuran = 56.0;
    if (path == null) {
      return const SizedBox(
        width: ukuran,
        height: ukuran,
        child: Icon(Icons.note_outlined),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(path!),
        width: ukuran,
        height: ukuran,
        fit: BoxFit.cover,
        cacheWidth: 200,
        errorBuilder: (_, __, ___) => const SizedBox(
          width: ukuran,
          height: ukuran,
          child: Icon(Icons.broken_image_outlined),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Form catatan: judul, isi, dan satu foto (kamera atau galeri)
// ---------------------------------------------------------------------------
class FormCatatan extends StatefulWidget {
  const FormCatatan({super.key, this.awal});

  final Catatan? awal;

  @override
  State<FormCatatan> createState() => _FormCatatanState();
}

class _FormCatatanState extends State<FormCatatan> {
  final _kunci = GlobalKey<FormState>();
  late final TextEditingController _judul;
  late final TextEditingController _isi;
  String? _pathFoto;
  bool _memproses = false;

  @override
  void initState() {
    super.initState();
    _judul = TextEditingController(text: widget.awal?.judul);
    _isi = TextEditingController(text: widget.awal?.isi);
    _pathFoto = widget.awal?.pathFoto;
  }

  @override
  void dispose() {
    _judul.dispose();
    _isi.dispose();
    super.dispose();
  }

  void _pesan(String teks) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(teks)));
  }

  // --- Izin kamera -----------------------------------------------------------
  Future<bool> _pastikanIzinKamera() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    if (status.isGranted) return true;
    if (!mounted) return false;

    final permanen = status.isPermanentlyDenied;
    final dibatasi = status.isRestricted;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Izin kamera diperlukan'),
        content: Text(
          dibatasi
              ? 'Akses kamera dibatasi oleh sistem perangkat ini. '
              'Anda tetap dapat melampirkan foto dari galeri.'
              : permanen
              ? 'Izin kamera ditolak permanen. Kamera dipakai untuk '
              'mengambil foto yang dilampirkan pada catatan. '
              'Aktifkan izin melalui pengaturan aplikasi.'
              : 'Kamera dipakai untuk mengambil foto yang dilampirkan '
              'pada catatan. Tanpa izin, Anda masih dapat memilih '
              'foto dari galeri.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
          if (permanen)
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                openAppSettings();
              },
              child: const Text('Buka pengaturan'),
            ),
        ],
      ),
    );
    return false;
  }

  // --- Sumber gambar ---------------------------------------------------------
  Future<void> _ambilDariKamera() async {
    if (!await _pastikanIzinKamera()) return;
    if (!mounted) return;

    final path = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const HalamanKamera()),
    );
    if (path == null) return; // pengguna kembali tanpa mengambil foto
    await _simpanFoto(path);
  }

  Future<void> _pilihDariGaleri() async {
    try {
      final berkas = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1280,
      );
      if (berkas == null) return; // pengguna membatalkan
      await _simpanFoto(berkas.path);
    } catch (_) {
      if (mounted) _pesan('Gagal memilih gambar dari galeri.');
    }
  }

  // Menyalin foto ke penyimpanan aplikasi supaya tidak hilang
  // bila berkas sementara dibersihkan sistem.
  Future<void> _simpanFoto(String sumber) async {
    setState(() => _memproses = true);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final tujuan =
          '${dir.path}/foto_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(sumber).copy(tujuan);
      if (!mounted) return;
      setState(() => _pathFoto = tujuan);
    } on FileSystemException {
      if (mounted) _pesan('Gagal menyimpan foto. Periksa ruang penyimpanan.');
    } finally {
      if (mounted) setState(() => _memproses = false);
    }
  }

  void _simpanCatatan() {
    if (!_kunci.currentState!.validate()) return;
    Navigator.pop(
      context,
      Catatan(
        judul: _judul.text.trim(),
        isi: _isi.text.trim(),
        pathFoto: _pathFoto,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.awal == null ? 'Catatan baru' : 'Ubah catatan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Simpan',
            onPressed: _memproses ? null : _simpanCatatan,
          ),
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _kunci,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _judul,
                  decoration: const InputDecoration(
                    labelText: 'Judul',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _isi,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Isi catatan',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                if (_pathFoto != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_pathFoto!),
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(
                        height: 220,
                        child: Center(child: Text('Foto tidak dapat ditampilkan')),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _memproses ? null : _ambilDariKamera,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Kamera'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _memproses ? null : _pilihDariGaleri,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galeri'),
                    ),
                    if (_pathFoto != null)
                      TextButton.icon(
                        onPressed: _memproses
                            ? null
                            : () => setState(() => _pathFoto = null),
                        icon: const Icon(Icons.close),
                        label: const Text('Hapus foto'),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Indikator saat gambar diproses
          if (_memproses)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x66000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Halaman kamera: pratinjau + ambil foto. Mengembalikan path foto via pop.
// ---------------------------------------------------------------------------
class HalamanKamera extends StatefulWidget {
  const HalamanKamera({super.key});

  @override
  State<HalamanKamera> createState() => _HalamanKameraState();
}

class _HalamanKameraState extends State<HalamanKamera>
    with WidgetsBindingObserver {
  CameraController? _controller;
  String? _pesanError;
  bool _mengambil = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _siapkanKamera();
  }

  Future<void> _siapkanKamera() async {
    try {
      final kamera = await availableCameras();
      if (kamera.isEmpty) {
        if (mounted) {
          setState(() => _pesanError = 'Tidak ada kamera pada perangkat ini.');
        }
        return;
      }
      final controller = CameraController(
        kamera.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        // Halaman sudah ditutup selama inisialisasi: lepas sumber daya.
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _pesanError = null;
      });
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() {
        _pesanError = e.code == 'CameraAccessDenied'
            ? 'Izin kamera ditolak. Aktifkan melalui pengaturan aplikasi.'
            : 'Kamera gagal disiapkan (${e.code}).';
      });
    }
  }

  Future<void> _ambilFoto() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (_mengambil || controller.value.isTakingPicture) return;

    setState(() => _mengambil = true);
    try {
      final berkas = await controller.takePicture();
      if (!mounted) return;
      Navigator.pop(context, berkas.path);
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() => _mengambil = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil gambar (${e.code}).')),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      // Lepas kamera saat aplikasi masuk latar belakang.
      final controller = _controller;
      if (controller == null) return;
      setState(() => _controller = null);
      controller.dispose();
    } else if (state == AppLifecycleState.resumed &&
        _controller == null &&
        _pesanError == null) {
      _siapkanKamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    Widget isi;
    if (_pesanError != null) {
      isi = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_pesanError!, textAlign: TextAlign.center),
        ),
      );
    } else if (controller == null || !controller.value.isInitialized) {
      isi = const Center(child: CircularProgressIndicator());
    } else {
      isi = Center(child: CameraPreview(controller));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ambil foto')),
      body: isi,
      floatingActionButton: (controller == null || _pesanError != null)
          ? null
          : FloatingActionButton(
        onPressed: _mengambil ? null : _ambilFoto,
        child: _mengambil
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : const Icon(Icons.camera_alt),
      ),
    );
  }
}