// Minggu 11 - Pemrograman Asynchronous
// Tugas: halaman dengan empat kondisi (memuat, berhasil+data, berhasil+kosong, gagal)
//
// Cara pakai:
//   1. flutter create tugas_minggu11
//   2. Ganti isi lib/main.dart dengan file ini
//   3. flutter run
//
// Menu ikon "tune" di pojok kanan atas dipakai untuk mensimulasikan
// kondisi data kosong, gagal, dan timeout saat demo.

import 'dart:async';

import 'package:flutter/material.dart';

void main() => runApp(const AplikasiTugas());

// ---------------------------------------------------------------------------
// Tema
// ---------------------------------------------------------------------------

class Palet {
  static const latar = Color(0xFFF6F4EF);
  static const permukaan = Colors.white;
  static const garis = Color(0xFFE4E0D6);
  static const garisTegas = Color(0xFFB9B4A6);
  static const utama = Color(0xFF1F6F5C);
  static const teks = Color(0xFF1E2421);
  static const teksRedup = Color(0xFF6B726D);
  static const bahaya = Color(0xFFB3412F);
  static const bahayaLatar = Color(0xFFFBEDEA);
  static const bahayaGaris = Color(0xFFEBC9C2);
}

class AplikasiTugas extends StatelessWidget {
  const AplikasiTugas({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Materi Kuliah',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Palet.utama),
        scaffoldBackgroundColor: Palet.latar,
        appBarTheme: const AppBarTheme(
          backgroundColor: Palet.latar,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Palet.teks,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const HalamanMateri(),
    );
  }
}

// ---------------------------------------------------------------------------
// Model & layanan (simulasi jaringan)
// ---------------------------------------------------------------------------

class Materi {
  final int minggu;
  final String judul;
  final String ringkasan;
  final int menit;

  const Materi(this.minggu, this.judul, this.ringkasan, this.menit);
}

enum Skenario { normal, kosong, gagal, lambat }

class LayananMateri {
  Future<List<Materi>> ambilMateri(Skenario skenario) async {
    // "lambat" sengaja melebihi batas waktu 3 detik pada halaman.
    final tunda = skenario == Skenario.lambat ? 5 : 2;
    await Future.delayed(Duration(seconds: tunda));

    switch (skenario) {
      case Skenario.gagal:
        throw Exception('Tidak ada koneksi internet');
      case Skenario.kosong:
        return [];
      case Skenario.normal:
      case Skenario.lambat:
        return const [
          Materi(9, 'Kamera',
              'Mengakses kamera perangkat, mengambil foto, dan menampilkan hasilnya di aplikasi.', 12),
          Materi(10, 'State Management',
              'Mengelola data yang dipakai bersama oleh banyak widget tanpa mengoper manual.', 15),
          Materi(11, 'Asynchronous',
              'Future, async/await, dan FutureBuilder untuk pekerjaan yang membutuhkan waktu.', 14),
          Materi(12, 'Streams & BLoC',
              'Aliran data yang berkelanjutan dan pemisahan logika bisnis dari tampilan.', 18),
          Materi(13, 'Persistensi Data',
              'Menyimpan data secara lokal agar tetap ada setelah aplikasi ditutup.', 16),
          Materi(14, 'REST API',
              'Mengambil dan mengirim data ke server melalui permintaan HTTP.', 17),
        ];
    }
  }
}

final layanan = LayananMateri();

// ---------------------------------------------------------------------------
// Halaman utama
// ---------------------------------------------------------------------------

class HalamanMateri extends StatefulWidget {
  const HalamanMateri({super.key});

  @override
  State<HalamanMateri> createState() => _HalamanMateriState();
}

class _HalamanMateriState extends State<HalamanMateri> {
  Skenario _skenario = Skenario.normal;

  // Future disimpan di variabel agar tidak dikirim ulang saat widget rebuild.
  late Future<List<Materi>> _future;

  // Materi yang sudah ditandai selesai (bertahan walau data dimuat ulang).
  final Set<int> _selesai = {};

  @override
  void initState() {
    super.initState();
    _future = _ambil();
  }

  Future<List<Materi>> _ambil() {
    return layanan
        .ambilMateri(_skenario)
        .timeout(const Duration(seconds: 3));
  }

  void _muatUlang() {
    setState(() {
      _future = _ambil();
    });
  }

  void _gantiSkenario(Skenario baru) {
    _skenario = baru;
    _muatUlang();
  }

  String _pesanError(Object error) {
    if (error is TimeoutException) {
      return 'Server terlalu lama merespons. Periksa jaringan Anda, lalu coba lagi.';
    }
    final isi = error.toString().replaceFirst('Exception: ', '');
    return '$isi. Pastikan perangkat terhubung, lalu coba lagi.';
  }

  void _tandai(Materi m) {
    final sudahSelesai = _selesai.contains(m.minggu);
    setState(() {
      sudahSelesai ? _selesai.remove(m.minggu) : _selesai.add(m.minggu);
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(sudahSelesai
              ? 'Tanda selesai dihapus'
              : 'Minggu ${m.minggu} ditandai selesai'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Urungkan',
            onPressed: () => setState(() {
              sudahSelesai ? _selesai.add(m.minggu) : _selesai.remove(m.minggu);
            }),
          ),
        ),
      );
  }

  void _bukaDetail(Materi m) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Palet.permukaan,
      showDragHandle: true,
      builder: (ctx) {
        final selesai = _selesai.contains(m.minggu);
        final tema = Theme.of(ctx).textTheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MINGGU ${m.minggu}',
                style: tema.labelMedium?.copyWith(
                  color: Palet.utama,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(m.judul,
                  style: tema.headlineSmall?.copyWith(
                      color: Palet.teks, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Text(m.ringkasan,
                  style: tema.bodyLarge?.copyWith(color: Palet.teks, height: 1.4)),
              const SizedBox(height: 8),
              Text('${m.menit} menit baca',
                  style: tema.bodySmall?.copyWith(color: Palet.teksRedup)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: selesai
                    ? OutlinedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _tandai(m);
                  },
                  child: const Text('Batalkan tanda selesai'),
                )
                    : FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _tandai(m);
                  },
                  child: const Text('Tandai selesai'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materi'),
        actions: [
          PopupMenuButton<Skenario>(
            tooltip: 'Simulasi kondisi',
            icon: const Icon(Icons.tune),
            initialValue: _skenario,
            onSelected: _gantiSkenario,
            itemBuilder: (_) => const [
              PopupMenuItem(value: Skenario.normal, child: Text('Data tersedia')),
              PopupMenuItem(value: Skenario.kosong, child: Text('Data kosong')),
              PopupMenuItem(value: Skenario.gagal, child: Text('Koneksi gagal')),
              PopupMenuItem(value: Skenario.lambat, child: Text('Respons lambat')),
            ],
          ),
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            onPressed: _muatUlang,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: FutureBuilder<List<Materi>>(
        future: _future,
        builder: (context, snapshot) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _isi(snapshot),
          );
        },
      ),
    );
  }

  Widget _isi(AsyncSnapshot<List<Materi>> snapshot) {
    // 1. Sedang memuat
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const _KerangkaMuat(key: ValueKey('memuat'));
    }

    // 2. Gagal
    if (snapshot.hasError) {
      return _TampilanGagal(
        key: const ValueKey('gagal'),
        pesan: _pesanError(snapshot.error!),
        onCobaLagi: _muatUlang,
      );
    }

    final data = snapshot.data ?? [];

    // 3. Berhasil, tetapi kosong
    if (data.isEmpty) {
      return _TampilanKosong(
        key: const ValueKey('kosong'),
        onPeriksa: _muatUlang,
      );
    }

    // 4. Berhasil dengan data
    final jumlahSelesai = data.where((m) => _selesai.contains(m.minggu)).length;
    return ListView.separated(
      key: const ValueKey('data'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: data.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        if (i == 0) {
          return _Progres(selesai: jumlahSelesai, total: data.length);
        }
        final m = data[i - 1];
        return _BarisMateri(
          materi: m,
          selesai: _selesai.contains(m.minggu),
          onBuka: () => _bukaDetail(m),
          onTandai: () => _tandai(m),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Komponen tampilan
// ---------------------------------------------------------------------------

class _Progres extends StatelessWidget {
  final int selesai;
  final int total;
  const _Progres({required this.selesai, required this.total});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$selesai dari $total materi selesai',
            style: tema.bodyMedium?.copyWith(color: Palet.teksRedup),
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(end: total == 0 ? 0 : selesai / total),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            builder: (context, nilai, _) => LinearProgressIndicator(
              value: nilai,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
              backgroundColor: Palet.garis,
              color: Palet.utama,
            ),
          ),
        ],
      ),
    );
  }
}

class _BarisMateri extends StatelessWidget {
  final Materi materi;
  final bool selesai;
  final VoidCallback onBuka;
  final VoidCallback onTandai;

  const _BarisMateri({
    required this.materi,
    required this.selesai,
    required this.onBuka,
    required this.onTandai,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Material(
      color: Palet.permukaan,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Palet.garis),
      ),
      child: InkWell(
        onTap: onBuka,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  materi.minggu.toString().padLeft(2, '0'),
                  style: tema.titleSmall?.copyWith(color: Palet.teksRedup),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      materi.judul,
                      style: tema.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: selesai ? Palet.teksRedup : Palet.teks,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${materi.menit} menit baca',
                      style: tema.bodySmall?.copyWith(color: Palet.teksRedup),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onTandai,
                tooltip: selesai ? 'Hapus tanda selesai' : 'Tandai selesai',
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    selesai ? Icons.check_circle : Icons.radio_button_unchecked,
                    key: ValueKey(selesai),
                    color: selesai ? Palet.utama : Palet.garisTegas,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder berdenyut yang meniru bentuk daftar saat data dimuat.
class _KerangkaMuat extends StatefulWidget {
  const _KerangkaMuat({super.key});

  @override
  State<_KerangkaMuat> createState() => _KerangkaMuatState();
}

class _KerangkaMuatState extends State<_KerangkaMuat>
    with SingleTickerProviderStateMixin {
  late final AnimationController _kontrol = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _kontrol.dispose();
    super.dispose();
  }

  Widget _batang(double lebar, double tinggi) => Container(
    width: lebar,
    height: tinggi,
    decoration: BoxDecoration(
      color: Palet.garis,
      borderRadius: BorderRadius.circular(4),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Memuat materi',
      child: FadeTransition(
        opacity: Tween(begin: 0.45, end: 1.0).animate(
          CurvedAnimation(parent: _kontrol, curve: Curves.easeInOut),
        ),
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
              child: Row(
                children: [
                  _batang(140, 12),
                ],
              ),
            ),
            for (var i = 0; i < 6; i++)
              Container(
                height: 64,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Palet.permukaan,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Palet.garis),
                ),
                child: Row(
                  children: [
                    _batang(20, 14),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _batang(150 + (i % 3) * 30, 14),
                        const SizedBox(height: 8),
                        _batang(80, 10),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TampilanKosong extends StatelessWidget {
  final VoidCallback onPeriksa;
  const _TampilanKosong({super.key, required this.onPeriksa});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Palet.garis,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.menu_book_outlined,
                    color: Palet.teksRedup),
              ),
              const SizedBox(height: 16),
              Text('Belum ada materi',
                  style: tema.titleLarge?.copyWith(
                      color: Palet.teks, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(
                'Dosen belum merilis materi untuk saat ini. Materi akan muncul sesuai jadwal perkuliahan.',
                style: tema.bodyMedium
                    ?.copyWith(color: Palet.teksRedup, height: 1.4),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onPeriksa,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Periksa lagi'),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TampilanGagal extends StatelessWidget {
  final String pesan;
  final VoidCallback onCobaLagi;
  const _TampilanGagal({
    super.key,
    required this.pesan,
    required this.onCobaLagi,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Palet.bahayaLatar,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Palet.bahayaGaris),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.wifi_off_rounded, color: Palet.bahaya),
                const SizedBox(height: 12),
                Text('Materi belum bisa dimuat',
                    style: tema.titleMedium?.copyWith(
                        color: Palet.teks, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(pesan,
                    style: tema.bodyMedium
                        ?.copyWith(color: Palet.teks, height: 1.4)),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: onCobaLagi,
                  style: FilledButton.styleFrom(
                      backgroundColor: Palet.bahaya),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
