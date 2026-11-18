class Produk {
  final String id, nama, emoji, kategori, deskripsi;
  final int harga;
  final double rating;
  const Produk(this.id, this.nama, this.harga, this.emoji, this.kategori,
      this.rating, this.deskripsi);

  bool get berOpsi => kategori != 'Biji';
}

const kategoriMenu = ['Semua', 'Favorit', 'Kopi', 'Non-Kopi', 'Biji'];
const tambahanUkuran = {'Small': 0, 'Medium': 4000, 'Large': 8000};
const pilihanGula = ['Normal', 'Less sugar', 'No sugar'];
const pilihanSuhu = ['Panas', 'Dingin'];

const daftarProduk = [
  Produk('espresso', 'Espresso', 18000, '☕', 'Kopi', 4.7,
      'Satu shot kopi pekat dengan crema tebal. Untuk yang suka kuat.'),
  Produk('cappuccino', 'Cappuccino', 28000, '☕', 'Kopi', 4.8,
      'Espresso, susu steam, dan foam lembut setebal pas.'),
  Produk('latte', 'Caffe Latte', 30000, '🥛', 'Kopi', 4.8,
      'Susu creamy dengan espresso halus. Aman untuk pemula.'),
  Produk('kopsus', 'Es Kopi Susu Aren', 25000, '🧊', 'Kopi', 4.9,
      'Best seller. Kopi, susu segar, dan gula aren asli.'),
  Produk('v60', 'V60 Arabika', 32000, '🫖', 'Kopi', 4.6,
      'Seduh manual, rasa bersih dengan aroma floral.'),
  Produk('matcha', 'Matcha Latte', 29000, '🍵', 'Non-Kopi', 4.7,
      'Matcha Jepang dengan susu, manis dan earthy.'),
  Produk('coklat', 'Cokelat Panas', 26000, '🍫', 'Non-Kopi', 4.5,
      'Cokelat pekat yang hangat, cocok saat hujan.'),
  Produk('biji', 'Biji Arabika 250 g', 85000, '🌰', 'Biji', 4.6,
      'Roasting medium, siap digiling untuk diseduh di rumah.'),
];

String rupiah(int nilai) {
  final s = nilai.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (m) => '.',
  );
  return 'Rp $s';
}
