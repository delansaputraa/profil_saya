import 'package:flutter/material.dart';

void main() {
  runApp(const KartuIdentitasApp());
}

/// StatefulWidget utama: menyimpan state mode terang/gelap.
class KartuIdentitasApp extends StatefulWidget {
  const KartuIdentitasApp({super.key});

  @override
  State<KartuIdentitasApp> createState() => _KartuIdentitasAppState();
}

class _KartuIdentitasAppState extends State<KartuIdentitasApp> {
  bool _modeGelap = false;

  void _gantiTema() {
    setState(() {
      _modeGelap = !_modeGelap;
    });
  }

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF0B6B45);
    return MaterialApp(
      title: 'Kartu Identitas Digital',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: seed,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: seed,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: _modeGelap ? ThemeMode.dark : ThemeMode.light,
      home: HalamanKartu(modeGelap: _modeGelap, onGantiTema: _gantiTema),
    );
  }
}

class HalamanKartu extends StatelessWidget {
  final bool modeGelap;
  final VoidCallback onGantiTema;

  const HalamanKartu({
    super.key,
    required this.modeGelap,
    required this.onGantiTema,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kartu Identitas Digital'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const KartuMahasiswa(),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onGantiTema,
                child: Text(modeGelap ? 'Mode Terang' : 'Mode Gelap'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class KartuMahasiswa extends StatelessWidget {
  const KartuMahasiswa({super.key});

  @override
  Widget build(BuildContext context) {
    final warna = Theme.of(context).colorScheme;

    return Container(
      width: 360,
      decoration: BoxDecoration(
        color: warna.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: warna.outlineVariant),
      ),
      child: Column(
        children: [
          // Header kartu
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              color: warna.primary,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Text(
              'KARTU MAHASISWA',
              style: TextStyle(
                color: warna.onPrimary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          // Isi kartu
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: warna.primaryContainer,
                      backgroundImage: const AssetImage('assets/foto.jpg'),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Putu Delansa Putra',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text('Mahasiswa Aktif'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(color: warna.outlineVariant),
                const SizedBox(height: 12),
                const BarisInfo(label: 'NIM', nilai: '202463121025'),
                const SizedBox(height: 12),
                const BarisInfo(
                  label: 'Program Studi',
                  nilai: 'Teknik Komputer',
                ),
                const SizedBox(height: 12),
                const BarisInfo(label: 'Semester', nilai: '5'),
                const SizedBox(height: 12),
                const BarisInfo(
                  label: 'Email',
                  nilai: 'putudelansaputra@student.warmadewa.ac.id',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BarisInfo extends StatelessWidget {
  final String label;
  final String nilai;

  const BarisInfo({super.key, required this.label, required this.nilai});

  @override
  Widget build(BuildContext context) {
    final warna = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: warna.onSurfaceVariant),
              ),
              Text(
                nilai,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

