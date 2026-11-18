import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/favorit_model.dart';
import 'models/keranjang_model.dart';
import 'models/tema_model.dart';
import 'pages/halaman_katalog.dart';
import 'pages/halaman_keranjang.dart';
import 'pages/halaman_pengaturan.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => KeranjangModel()),
        ChangeNotifierProvider(create: (_) => TemaModel()),
        ChangeNotifierProvider(create: (_) => FavoritModel()),
      ],
      child: const KedaiKopiApp(),
    ),
  );
}

ThemeData _buatTema(Color seed, Brightness b) {
  final skema = ColorScheme.fromSeed(seedColor: seed, brightness: b);
  RoundedRectangleBorder bentuk(double r) =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(r));
  return ThemeData(
    useMaterial3: true,
    colorScheme: skema,
    scaffoldBackgroundColor: skema.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: skema.surface,
      centerTitle: false,
      scrolledUnderElevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: skema.surfaceContainerHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: bentuk(14),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      ),
    ),
    snackBarTheme:
    SnackBarThemeData(behavior: SnackBarBehavior.floating, shape: bentuk(14)),
  );
}

class KedaiKopiApp extends StatelessWidget {
  const KedaiKopiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = context.watch<TemaModel>();
    return MaterialApp(
      title: 'Kedai Kopi',
      debugShowCheckedModeBanner: false,
      themeMode: tema.mode,
      theme: _buatTema(tema.warna, Brightness.light),
      darkTheme: _buatTema(tema.warna, Brightness.dark),
      home: const KerangkaUtama(),
    );
  }
}

class KerangkaUtama extends StatefulWidget {
  const KerangkaUtama({super.key});

  @override
  State<KerangkaUtama> createState() => _KerangkaUtamaState();
}

class _KerangkaUtamaState extends State<KerangkaUtama> {
  int _tab = 0; // state lokal: hanya dipakai widget ini
  static const _judul = ['Kedai Kopi ☕', 'Pesanan Saya', 'Pengaturan'];

  void _ke(int i) => setState(() => _tab = i);

  @override
  Widget build(BuildContext context) {
    final jumlah = context.watch<KeranjangModel>().jumlahItem;
    final nama = context.watch<TemaModel>().nama;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_judul[_tab], style: const TextStyle(fontWeight: FontWeight.w800)),
            if (_tab == 0)
              Text('Halo, $nama 👋', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _ke(1),
            icon: TweenAnimationBuilder<double>(
              key: ValueKey(jumlah), // berganti tiap jumlah berubah → efek "pop"
              tween: Tween(begin: 1.5, end: 1.0),
              duration: const Duration(milliseconds: 350),
              curve: Curves.elasticOut,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: Badge(
                label: Text('$jumlah'),
                isLabelVisible: jumlah > 0,
                child: const Icon(Icons.shopping_bag_outlined),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          HalamanKatalog(onLihatPesanan: () => _ke(1)),
          const HalamanKeranjang(),
          const HalamanPengaturan(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _ke,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.local_cafe_outlined),
              selectedIcon: Icon(Icons.local_cafe),
              label: 'Menu'),
          NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Pesanan'),
          NavigationDestination(
              icon: Icon(Icons.tune), label: 'Pengaturan'),
        ],
      ),
    );
  }
}
