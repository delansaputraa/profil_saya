// Latihan 3: var, final, const, dan late
// Contoh yang dipakai: data seorang mahasiswa di kampus.

void main() {
  // ===== 1. var =====
  // Artinya : variabel biasa, isinya boleh diganti kapan saja.
  // Contoh  : jumlah kehadiran, bertambah setiap pertemuan.
  // Alasan  : nilainya memang berubah-ubah, jadi cocok pakai var.
  var jumlahHadir = 0;
  jumlahHadir = jumlahHadir + 5;
  print('Jumlah hadir: $jumlahHadir');

  // ===== 2. final =====
  // Artinya : diisi satu kali saja, setelah itu tidak boleh diganti.
  // Contoh  : waktu mahasiswa login ke aplikasi.
  // Alasan  : waktunya baru diketahui saat program dijalankan,
  //           tapi setelah tercatat tidak perlu diubah lagi.
  //           Tidak bisa pakai const karena waktu sekarang
  //           belum ada saat program dikompilasi.
  final waktuLogin = DateTime.now();
  print('Login pada tahun: ${waktuLogin.year}');
  // waktuLogin = DateTime.now(); // ERROR: final tidak boleh diisi dua kali

  // ===== 3. const =====
  // Artinya : nilai tetap yang sudah pasti sejak awal.
  // Contoh  : nama kampus, tidak akan berubah selama program berjalan.
  // Alasan  : nilainya sudah jelas sebelum program jalan,
  //           jadi paling aman dan paling ketat pakai const.
  const namaKampus = 'Universitas Warmadewa';
  print('Kampus: $namaKampus');
  // namaKampus = 'Kampus Lain'; // ERROR: const tidak boleh diubah

  // ===== 4. late =====
  // Artinya : "nilainya menyusul, tapi pasti terisi sebelum dipakai".
  // Contoh  : kode mata kuliah yang baru diketahui setelah mahasiswa memilih.
  // Alasan  : saat dideklarasikan nilainya belum ada, tapi kita tidak
  //           mau tipenya jadi String? (boleh kosong).
  late String kodeMataKuliah;
  kodeMataKuliah = 'TKO-4021'; // diisi kemudian
  print('Kode mata kuliah: $kodeMataKuliah');
}