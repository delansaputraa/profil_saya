import 'package:flutter/material.dart';

/// Pengaturan tampilan & profil: mode gelap, warna aksen, nama, tipe pesanan.
class TemaModel extends ChangeNotifier {
  static const namaAksen = ['Espresso', 'Matcha', 'Karamel', 'Berry'];
  static const warnaAksen = [
    Color(0xFF6F4E37),
    Color(0xFF4C7A3F),
    Color(0xFFC0762D),
    Color(0xFF8E3B5A),
  ];

  ThemeMode _mode = ThemeMode.light;
  int _aksen = 0;
  String _nama = 'Kawan Ngopi';
  String _tipe = 'Dine in';

  ThemeMode get mode => _mode;
  bool get gelap => _mode == ThemeMode.dark;
  int get aksen => _aksen;
  Color get warna => warnaAksen[_aksen];
  String get nama => _nama.trim().isEmpty ? 'Kawan Ngopi' : _nama.trim();
  String get tipe => _tipe;

  void setGelap(bool v) {
    _mode = v ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setAksen(int i) {
    _aksen = i;
    notifyListeners();
  }

  void setNama(String v) {
    _nama = v;
    notifyListeners();
  }

  void setTipe(String v) {
    _tipe = v;
    notifyListeners();
  }
}
