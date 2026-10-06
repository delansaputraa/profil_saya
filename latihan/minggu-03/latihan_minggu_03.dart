import 'dart:io';

void main() {
  int totalBelanja = 0;
  bool lanjut = true;

  print('=== APLIKASI MENU KANTIN ===');

  // Perulangan untuk menerima pesanan berulang
  while (lanjut) {
    print('\n--- MENU ---');
    print('1. Nasi Goreng  - Rp15000');
    print('2. Mie Ayam     - Rp12000');
    print('3. Ayam Geprek  - Rp18000');
    print('4. Es Teh       - Rp5000');
    print('5. Es Jeruk     - Rp6000');
    print('0. Selesai & bayar');
    stdout.write('Pilih menu: ');

    // try-catch untuk menangani masukan yang tidak valid
    try {
      int pilihan = int.parse(stdin.readLineSync()!);
      String nama = '';
      int harga = 0;

      // switch untuk memproses pilihan
      switch (pilihan) {
        case 1:
          nama = 'Nasi Goreng';
          harga = 15000;
          break;
        case 2:
          nama = 'Mie Ayam';
          harga = 12000;
          break;
        case 3:
          nama = 'Ayam Geprek';
          harga = 18000;
          break;
        case 4:
          nama = 'Es Teh';
          harga = 5000;
          break;
        case 5:
          nama = 'Es Jeruk';
          harga = 6000;
          break;
        case 0:
          lanjut = false;
          break;
        default:
          print('Pilihan tidak ada di menu!');
      }

      // harga > 0 artinya ada menu yang dipilih
      if (harga > 0) {
        stdout.write('Jumlah $nama: ');
        int jumlah = int.parse(stdin.readLineSync()!);

        if (jumlah <= 0) {
          throw ArgumentError('Jumlah harus lebih dari 0');
        }

        int subtotal = harga * jumlah;
        totalBelanja += subtotal;
        print('$nama x $jumlah = Rp$subtotal');
        print('Total sementara: Rp$totalBelanja');
      }
    } on FormatException {
      print('Input tidak valid! Masukkan angka saja.');
    } on ArgumentError catch (e) {
      print('Error: ${e.message}');
    } catch (e) {
      print('Terjadi kesalahan: $e');
    }
  }

  print('\n=============================');
  print('Total belanja: Rp$totalBelanja');
  print('Terima kasih sudah berbelanja! jangan lupa mampir lagi');
}
