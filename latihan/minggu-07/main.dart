import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Wajib agar format tanggal bahasa Indonesia tersedia
  await initializeDateFormatting('id_ID', null);
  runApp(const AplikasiKuliah());
}

class AplikasiKuliah extends StatelessWidget {
  const AplikasiKuliah({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      colorSchemeSeed: Colors.indigo,
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'Aplikasi Kuliah',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        // Satu jenis huruf untuk seluruh aplikasi
        textTheme: GoogleFonts.interTextTheme(base.textTheme),
      ),
      home: const HalamanUtama(),
    );
  }
}

class HalamanUtama extends StatelessWidget {
  const HalamanUtama({super.key});

  @override
  Widget build(BuildContext context) {
    // Contoh hasil: Senin, 8 September 2026
    final tanggal = DateFormat('EEEE, d MMMM y', 'id_ID').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text('Praktikum Minggu 07')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hari ini', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(tanggal, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}