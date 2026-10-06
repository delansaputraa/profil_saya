typedef Matkul = Map<String, dynamic>;

final List<Matkul> daftarMatkul = [
{'kode': 'TKO101', 'nama': 'Pemrograman Mobile', 'sks': 3},
{'kode': 'TKO102', 'nama': 'Jaringan Komputer', 'sks': 3},
{'kode': 'TKO103', 'nama': 'Computer Vision', 'sks': 3},
{'kode': 'TKO104', 'nama': 'Deep Learning', 'sks': 2},
{'kode': 'TKO105', 'nama': 'Sistem Tertanam', 'sks': 4},
{'kode': 'TKO106', 'nama': 'Struktur Data', 'sks': 3},
{'kode': 'TKO107', 'nama': 'Pemrograman Web', 'sks': 2},
{'kode': 'TKO108', 'nama': 'Keamanan Jaringan', 'sks': 2},
];

/// Mencari mata kuliah yang nama atau kodenya memuat [kataKunci].
List<Matkul> cari(List<Matkul> data, String kataKunci) {
final kunci = kataKunci.toLowerCase();
return data
    .where((m) =>
(m['nama'] as String).toLowerCase().contains(kunci) ||
(m['kode'] as String).toLowerCase().contains(kunci))
    .toList();
}

/// Menyaring mata kuliah berdasarkan jumlah SKS.
List<Matkul> filterSks(List<Matkul> data, int sks) {
return data.where((m) => m['sks'] == sks).toList();
}

/// Mengurutkan berdasarkan nama (A-Z, atau Z-A jika [menurun] true).
/// Data asli tidak diubah karena disalin dahulu dengan spread operator.
List<Matkul> urutkanNama(List<Matkul> data, {bool menurun = false}) {
final hasil = [...data]..sort((a, b) {
final banding = (a['nama'] as String)
    .toLowerCase()
    .compareTo((b['nama'] as String).toLowerCase());
return menurun ? -banding : banding;
});
return hasil;
}

/// Total SKS dari sekumpulan mata kuliah.
int totalSks(List<Matkul> data) {
if (data.isEmpty) return 0;
return data.map((m) => m['sks'] as int).reduce((a, b) => a + b);
}

/// Mencetak hasil dalam bentuk tabel sederhana.
void tampilkan(String judul, List<Matkul> data) {
print('\n=== $judul ===');
if (data.isEmpty) {
print('(tidak ada data)');
return;
}
print('${'Kode'.padRight(8)}${'Nama'.padRight(24)}SKS');
print('-' * 38);
data
    .map((m) =>
'${m['kode'].toString().padRight(8)}'
'${m['nama'].toString().padRight(24)}'
'${m['sks']}')
    .forEach(print);
print('-' * 38);
print('Jumlah: ${data.length} mata kuliah, total ${totalSks(data)} SKS');
}

void main() {
tampilkan('Semua mata kuliah', daftarMatkul);

tampilkan('Pencarian: "jaringan"', cari(daftarMatkul, 'jaringan'));
tampilkan('Pencarian: "learning"', cari(daftarMatkul, 'learning'));
tampilkan('Pencarian: "tko10"', cari(daftarMatkul, 'tko10'));
tampilkan('Pencarian: "xyz" (tidak ada)', cari(daftarMatkul, 'xyz'));

tampilkan('Filter: 3 SKS', filterSks(daftarMatkul, 3));
tampilkan('Filter: 2 SKS', filterSks(daftarMatkul, 2));

tampilkan('Urut nama A-Z', urutkanNama(daftarMatkul));
tampilkan('Urut nama Z-A', urutkanNama(daftarMatkul, menurun: true));

// Kombinasi: cari -> filter -> urutkan (method chaining antar fungsi)
final kombinasi = urutkanNama(filterSks(cari(daftarMatkul, 'pemrograman'), 2));
tampilkan('Kombinasi: "pemrograman" + 2 SKS + urut', kombinasi);

// Contoh any / every
final adaEmpatSks = daftarMatkul.any((m) => m['sks'] == 4);
final semuaMinimal2 = daftarMatkul.every((m) => (m['sks'] as int) >= 2);
print('\nAda matkul 4 SKS? $adaEmpatSks');
print('Semua matkul minimal 2 SKS? $semuaMinimal2');
}
