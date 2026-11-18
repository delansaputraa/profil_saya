import 'package:flutter/foundation.dart';
import 'produk.dart';

class BarisPesanan {
  final Produk produk;
  final String ukuran, gula, suhu, catatan;
  int jumlah;
  BarisPesanan(this.produk, this.ukuran, this.gula, this.suhu, this.catatan,
      this.jumlah);

  String get kunci => '${produk.id}|$ukuran|$gula|$suhu|$catatan';
  int get hargaSatuan => produk.harga + (tambahanUkuran[ukuran] ?? 0);
  int get subtotal => hargaSatuan * jumlah;
  String get ringkasOpsi {
    final cat = catatan.isEmpty ? '' : ' · $catatan';
    return produk.berOpsi ? '$ukuran · $gula · $suhu$cat' : 'Tanpa opsi$cat';
  }
}

class Pesanan {
  final String nomor, tipe;
  final int total, jumlah;
  Pesanan(this.nomor, this.tipe, this.total, this.jumlah);
}

class KeranjangModel extends ChangeNotifier {
  final List<BarisPesanan> _baris = [];
  final List<Pesanan> _riwayat = [];
  BarisPesanan? _terakhir;
  int _idxTerakhir = 0;
  String? _kodePromo;
  int _urut = 0;

  List<BarisPesanan> get baris => List.unmodifiable(_baris);
  List<Pesanan> get riwayat => List.unmodifiable(_riwayat);
  String? get kodePromo => _kodePromo;
  bool get kosong => _baris.isEmpty;
  int get jumlahItem => _baris.fold(0, (s, e) => s + e.jumlah);
  int get subtotal => _baris.fold(0, (s, e) => s + e.subtotal);
  int get diskon {
    if (_kodePromo == 'KOPI10') return (subtotal * 0.1).round();
    if (_kodePromo == 'HEMAT5') return subtotal < 5000 ? subtotal : 5000;
    return 0;
  }

  int get total => subtotal - diskon;

  void tambah(Produk p,
      {String ukuran = '',
        String gula = '',
        String suhu = '',
        String catatan = '',
        int jumlah = 1}) {
    final baru = BarisPesanan(p, ukuran, gula, suhu, catatan, jumlah);
    final i = _baris.indexWhere((e) => e.kunci == baru.kunci);
    if (i == -1) {
      _baris.add(baru);
    } else {
      _baris[i].jumlah += jumlah;
    }
    notifyListeners();
  }

  void ubahJumlah(BarisPesanan b, int delta) {
    b.jumlah += delta;
    if (b.jumlah <= 0) _baris.remove(b);
    notifyListeners();
  }

  void hapus(BarisPesanan b) {
    _idxTerakhir = _baris.indexOf(b);
    _terakhir = b;
    _baris.remove(b);
    notifyListeners();
  }

  void urungkanHapus() {
    final b = _terakhir;
    if (b == null) return;
    final i = _idxTerakhir > _baris.length ? _baris.length : _idxTerakhir;
    _baris.insert(i, b);
    _terakhir = null;
    notifyListeners();
  }

  bool pakaiPromo(String kode) {
    final k = kode.trim().toUpperCase();
    if (k != 'KOPI10' && k != 'HEMAT5') return false;
    _kodePromo = k;
    notifyListeners();
    return true;
  }

  void hapusPromo() {
    _kodePromo = null;
    notifyListeners();
  }

  Pesanan checkout(String tipe) {
    final p = Pesanan('#${(++_urut).toString().padLeft(3, '0')}', tipe, total,
        jumlahItem);
    _riwayat.insert(0, p);
    _baris.clear();
    _kodePromo = null;
    notifyListeners();
    return p;
  }
}
