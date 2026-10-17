import 'package:flutter/material.dart';

// ============================================================
// Tugas Minggu 06 - Aplikasi Katalog Multi-Halaman
// Tema: Katalog Model Kit Gundam
//
// Halaman:
//  1. HalamanBeranda   -> daftar dinamis (ListView / GridView responsif)
//  2. HalamanDetail    -> menerima data lewat konstruktor
//  3. HalamanPilihGrade-> mengembalikan nilai ke pemanggil (pop dengan hasil)
//  4. HalamanTentang   -> dibuka lewat named route '/tentang'
// ============================================================

void main() => runApp(const KatalogApp());

// ---------------------- MODEL & DATA ------------------------

class Gundam {
  final String nama;
  final String seri;
  final String grade; // HG, RG, MG, PG
  final String skala;
  final String deskripsi;
  final String fitur;
  final int harga;
  final IconData ikon;
  final Color warna;

  const Gundam({
    required this.nama,
    required this.seri,
    required this.grade,
    required this.skala,
    required this.deskripsi,
    required this.fitur,
    required this.harga,
    required this.ikon,
    required this.warna,
  });
}

const List<String> daftarGrade = ['Semua', 'HG', 'RG', 'MG', 'PG'];

const Map<String, String> infoGrade = {
  'Semua': 'Tampilkan seluruh grade',
  'HG': 'High Grade - ramah pemula, skala 1/144',
  'RG': 'Real Grade - detail tinggi dalam ukuran 1/144',
  'MG': 'Master Grade - rangka dalam, skala 1/100',
  'PG': 'Perfect Grade - paling detail, skala 1/60',
};

const List<Gundam> daftarGundam = [
  Gundam(
    nama: 'RX-78-2 Gundam',
    seri: 'Mobile Suit Gundam',
    grade: 'HG',
    skala: '1/144',
    deskripsi:
    'Mobile suit pertama dan paling ikonik dari franchise Gundam, dengan warna putih, biru, merah, dan kuning.',
    fitur: 'Mudah dirakit, sendi cukup luas, cocok sebagai kit pertama.',
    harga: 150000,
    ikon: Icons.smart_toy,
    warna: Color(0xFF1565C0),
  ),
  Gundam(
    nama: 'Zaku II',
    seri: 'Mobile Suit Gundam',
    grade: 'HG',
    skala: '1/144',
    deskripsi:
    'Mobile suit produksi massal pihak Zeon dengan mata tunggal yang khas.',
    fitur: 'Desain mono-eye, mudah dimodifikasi dan di-weathering.',
    harga: 140000,
    ikon: Icons.precision_manufacturing,
    warna: Color(0xFF2E7D32),
  ),
  Gundam(
    nama: 'Gundam Aerial',
    seri: 'The Witch from Mercury',
    grade: 'HG',
    skala: '1/144',
    deskripsi:
    'Gundam dengan desain modern yang menjadi tokoh utama serial Witch from Mercury.',
    fitur: 'Panel Bit Stave dapat dilepas dan disusun.',
    harga: 175000,
    ikon: Icons.rocket_launch,
    warna: Color(0xFF00897B),
  ),
  Gundam(
    nama: 'Gundam Barbatos',
    seri: 'Iron-Blooded Orphans',
    grade: 'HG',
    skala: '1/144',
    deskripsi:
    'Frame Gundam dengan tampilan kasar dan senjata jarak dekat yang berat.',
    fitur: 'Dilengkapi mace dan aksesori senjata jarak dekat.',
    harga: 165000,
    ikon: Icons.shield,
    warna: Color(0xFF6D4C41),
  ),
  Gundam(
    nama: 'Unicorn Gundam',
    seri: 'Gundam Unicorn',
    grade: 'RG',
    skala: '1/144',
    deskripsi:
    'Gundam yang bisa berubah antara Unicorn Mode dan Destroy Mode.',
    fitur: 'Transformasi mode Destroy, rangka dalam detail.',
    harga: 450000,
    ikon: Icons.bolt,
    warna: Color(0xFFC62828),
  ),
  Gundam(
    nama: 'Nu Gundam',
    seri: "Char's Counterattack",
    grade: 'RG',
    skala: '1/144',
    deskripsi:
    'Gundam dengan Fin Funnel di punggung yang menjadi simbol rivalitas Amuro dan Char.',
    fitur: 'Fin Funnel dapat dipasang, gerakan sendi sangat halus.',
    harga: 520000,
    ikon: Icons.flash_on,
    warna: Color(0xFF283593),
  ),
  Gundam(
    nama: 'Strike Freedom Gundam',
    seri: 'Gundam SEED Destiny',
    grade: 'MG',
    skala: '1/100',
    deskripsi:
    'Gundam bersayap lebar dengan banyak senjata jarak jauh yang tampil megah.',
    fitur: 'Sayap DRAGOON, rangka dalam, dan pose dinamis.',
    harga: 1100000,
    ikon: Icons.security,
    warna: Color(0xFF3949AB),
  ),
  Gundam(
    nama: 'Wing Gundam Zero EW',
    seri: 'Endless Waltz',
    grade: 'MG',
    skala: '1/100',
    deskripsi:
    'Gundam bersayap malaikat dari Endless Waltz dengan warna putih dan biru.',
    fitur: 'Sayap besar dapat dilipat dan dibuka.',
    harga: 950000,
    ikon: Icons.military_tech,
    warna: Color(0xFF546E7A),
  ),
  Gundam(
    nama: 'RX-78-2 Gundam Unleashed',
    seri: 'Mobile Suit Gundam',
    grade: 'PG',
    skala: '1/60',
    deskripsi:
    'Versi Perfect Grade dari RX-78-2 dengan tingkat detail dan ukuran paling besar di katalog ini.',
    fitur: 'Rangka dalam lengkap, ukuran besar, detail sangat tinggi.',
    harga: 3500000,
    ikon: Icons.android,
    warna: Color(0xFFEF6C00),
  ),
];

String formatRupiah(int nilai) {
  final s = nilai.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp $buf';
}

// ------------------------- APP ------------------------------

class KatalogApp extends StatelessWidget {
  const KatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Katalog Gundam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HalamanBeranda(),
        '/tentang': (context) => const HalamanTentang(),
      },
    );
  }
}

// ---------------------- HALAMAN 1: BERANDA ------------------

class HalamanBeranda extends StatefulWidget {
  const HalamanBeranda({super.key});

  @override
  State<HalamanBeranda> createState() => _HalamanBerandaState();
}

class _HalamanBerandaState extends State<HalamanBeranda> {
  String gradeAktif = 'Semua';

  Future<void> _pilihGrade() async {
    // Menerima hasil dari halaman tujuan
    final hasil = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => HalamanPilihGrade(gradeAktif: gradeAktif),
      ),
    );
    if (hasil != null) {
      setState(() => gradeAktif = hasil);
    }
  }

  void _bukaDetail(Gundam gundam) {
    // Mengirim data lewat konstruktor
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HalamanDetail(gundam: gundam),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = gradeAktif == 'Semua'
        ? daftarGundam
        : daftarGundam.where((g) => g.grade == gradeAktif).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Gundam'),
        actions: [
          IconButton(
            tooltip: 'Pilih grade',
            icon: const Icon(Icons.filter_list),
            onPressed: _pilihGrade,
          ),
          IconButton(
            tooltip: 'Tentang',
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.pushNamed(context, '/tentang'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${data.length} model kit',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                InputChip(
                  avatar: const Icon(Icons.category, size: 18),
                  label: Text('Grade: $gradeAktif'),
                  onPressed: _pilihGrade,
                ),
              ],
            ),
          ),
          Expanded(
            child: data.isEmpty
                ? const Center(child: Text('Tidak ada data'))
                : LayoutBuilder(
              builder: (context, constraints) {
                // Layar lebar (tablet) -> grid, layar sempit -> list
                if (constraints.maxWidth >= 600) {
                  final kolom = constraints.maxWidth >= 900 ? 4 : 3;
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: kolom,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: data.length,
                    itemBuilder: (context, index) => KartuGrid(
                      gundam: data[index],
                      onTap: () => _bukaDetail(data[index]),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final g = data[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: g.warna.withAlpha(40),
                        child: Icon(g.ikon, color: g.warna),
                      ),
                      title: Text(g.nama),
                      subtitle: Text(
                        '${g.grade} ${g.skala} · ${formatRupiah(g.harga)}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _bukaDetail(g),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class KartuGrid extends StatelessWidget {
  final Gundam gundam;
  final VoidCallback onTap;

  const KartuGrid({super.key, required this.gundam, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    color: gundam.warna.withAlpha(40),
                    child: Center(
                      child: Icon(gundam.ikon, size: 56, color: gundam.warna),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: gundam.warna,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        gundam.grade,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gundam.nama,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(formatRupiah(gundam.harga)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------- HALAMAN 2: DETAIL -------------------

class HalamanDetail extends StatelessWidget {
  final Gundam gundam;

  const HalamanDetail({super.key, required this.gundam});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(gundam.nama)),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            // Batasi lebar agar tetap rapi di tablet
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: gundam.warna.withAlpha(40),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Icon(gundam.ikon, size: 96, color: gundam.warna),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(gundam.nama, style: tema.textTheme.headlineSmall),
                  const SizedBox(height: 2),
                  Text(
                    gundam.seri,
                    style: tema.textTheme.bodyMedium
                        ?.copyWith(color: tema.colorScheme.outline),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(label: Text('Grade ${gundam.grade}')),
                      Chip(label: Text('Skala ${gundam.skala}')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatRupiah(gundam.harga),
                    style: tema.textTheme.titleLarge
                        ?.copyWith(color: tema.colorScheme.primary),
                  ),
                  const SizedBox(height: 16),
                  Text('Deskripsi', style: tema.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(gundam.deskripsi),
                  const SizedBox(height: 16),
                  Text('Fitur', style: tema.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(gundam.fitur),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Kembali ke daftar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ------------- HALAMAN 3: PILIH GRADE (return value) --------

class HalamanPilihGrade extends StatelessWidget {
  final String gradeAktif;

  const HalamanPilihGrade({super.key, required this.gradeAktif});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Grade')),
      body: ListView(
        children: [
          for (final g in daftarGrade)
            ListTile(
              title: Text(g),
              subtitle: Text(infoGrade[g] ?? ''),
              trailing: g == gradeAktif
                  ? Icon(Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary)
                  : null,
              // Mengembalikan nilai ke halaman pemanggil
              onTap: () => Navigator.pop(context, g),
            ),
        ],
      ),
    );
  }
}

// ---------------- HALAMAN 4: TENTANG (named route) ----------

class HalamanTentang extends StatelessWidget {
  const HalamanTentang({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Katalog Model Kit Gundam\nTugas Pemrograman Mobile - Minggu 06\n\n',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
