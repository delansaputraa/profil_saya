// Latihan 2: Class Produk dengan diskon opsional

class Produk {
  final String nama;
  final double harga;

  /// Diskon dalam persen (0-100). Boleh null bila tidak ada diskon.
  final double? diskon;

  Produk({required this.nama, required this.harga, this.diskon});

  /// Besar potongan harga. Bila diskon null dianggap 0 (operator ??).
  double get potongan => harga * (diskon ?? 0) / 100;

  /// Harga setelah dikurangi diskon.
  double get hargaAkhir => harga - potongan;

  bool get adaDiskon => diskon != null && diskon! > 0;

  @override
  String toString() {
    final info = adaDiskon
        ? 'diskon ${diskon!.toStringAsFixed(0)}% -> ${_rupiah(hargaAkhir)}'
        : 'tanpa diskon -> ${_rupiah(hargaAkhir)}';
    return '$nama (${_rupiah(harga)}): $info';
  }
}

/// Format angka menjadi Rupiah, contoh: 15000 -> Rp 15.000
String _rupiah(double nilai) {
  final teks = nilai.round().toString();
  final berTitik = teks.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (m) => '.',
  );
  return 'Rp $berTitik';
}

void main() {
  final daftar = <Produk>[
    Produk(nama: 'Laptop Gaming', harga: 11500000, diskon: 10),
    Produk(nama: 'Mouse Wireless', harga: 150000, diskon: 25),
    Produk(nama: 'Kabel USB', harga: 20000), // diskon tidak diisi (null)
  ];

  for (final p in daftar) {
    print(p);
  }

  final total = daftar.fold<double>(0, (jumlah, p) => jumlah + p.hargaAkhir);
  print('Total belanja: ${_rupiah(total)}');
}