import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/favorit_model.dart';
import '../models/keranjang_model.dart';
import '../models/produk.dart';

class HalamanKatalog extends StatefulWidget {
  final VoidCallback onLihatPesanan;
  const HalamanKatalog({super.key, required this.onLihatPesanan});

  @override
  State<HalamanKatalog> createState() => _HalamanKatalogState();
}

class _HalamanKatalogState extends State<HalamanKatalog> {
  final _cari = TextEditingController();
  String _kategori = 'Semua';

  @override
  void dispose() {
    _cari.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fav = context.watch<FavoritModel>();
    final keranjang = context.watch<KeranjangModel>();
    final q = _cari.text.toLowerCase();
    final hasil = daftarProduk.where((p) {
      final cocok = _kategori == 'Semua' ||
          (_kategori == 'Favorit' ? fav.punya(p.id) : p.kategori == _kategori);
      return cocok && p.nama.toLowerCase().contains(q);
    }).toList();

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: TextField(
                controller: _cari,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Mau ngopi apa hari ini?',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _cari.text.isEmpty
                      ? null
                      : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(_cari.clear),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: kategoriMenu.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final k = kategoriMenu[i];
                  return ChoiceChip(
                    label: Text(k == 'Favorit' ? '❤️ Favorit' : k),
                    selected: _kategori == k,
                    onSelected: (_) => setState(() => _kategori = k),
                  );
                },
              ),
            ),
            Expanded(
              child: hasil.isEmpty
                  ? const Center(child: Text('Menu tidak ditemukan 🔍'))
                  : GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                itemCount: hasil.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 220,
                ),
                itemBuilder: (_, i) => _KartuMenu(
                  produk: hasil[i],
                  favorit: fav.punya(hasil[i].id),
                ),
              ),
            ),
          ],
        ),
        // Bar pesanan melayang, muncul saat keranjang berisi
        Positioned(
          left: 16,
          right: 16,
          bottom: 12,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (c, a) => SlideTransition(
              position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(a),
              child: FadeTransition(opacity: a, child: c),
            ),
            child: keranjang.kosong
                ? const SizedBox.shrink(key: ValueKey('kosong'))
                : _BarPesanan(
              key: const ValueKey('ada'),
              jumlah: keranjang.jumlahItem,
              total: keranjang.total,
              onTap: widget.onLihatPesanan,
            ),
          ),
        ),
      ],
    );
  }
}

class _BarPesanan extends StatelessWidget {
  final int jumlah, total;
  final VoidCallback onTap;
  const _BarPesanan({super.key, required this.jumlah, required this.total, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final w = Theme.of(context).colorScheme;
    return Material(
      color: w.primary,
      borderRadius: BorderRadius.circular(18),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.shopping_bag, color: w.onPrimary),
              const SizedBox(width: 10),
              Text('$jumlah item',
                  style: TextStyle(color: w.onPrimary, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(rupiah(total),
                  style: TextStyle(color: w.onPrimary, fontWeight: FontWeight.w800)),
              Icon(Icons.chevron_right, color: w.onPrimary),
            ],
          ),
        ),
      ),
    );
  }
}

class _KartuMenu extends StatelessWidget {
  final Produk produk;
  final bool favorit;
  const _KartuMenu({required this.produk, required this.favorit});

  @override
  Widget build(BuildContext context) {
    final w = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: w.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: InkWell(
        onTap: () => bukaDetail(context, produk),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: w.primaryContainer,
                      alignment: Alignment.center,
                      child: Text(produk.emoji, style: const TextStyle(fontSize: 54)),
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: IconButton(
                      onPressed: () => context.read<FavoritModel>().toggle(produk.id),
                      icon: Icon(
                        favorit ? Icons.favorite : Icons.favorite_border,
                        color: favorit ? Colors.redAccent : w.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(produk.nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Row(children: [
                    const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                    Text(' ${produk.rating}', style: Theme.of(context).textTheme.bodySmall),
                  ]),
                  const SizedBox(height: 6),
                  Row(children: [
                    Expanded(
                      child: Text(rupiah(produk.harga),
                          style: TextStyle(color: w.primary, fontWeight: FontWeight.w700)),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(color: w.primary, shape: BoxShape.circle),
                      child: Icon(Icons.add, size: 18, color: w.onPrimary),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void bukaDetail(BuildContext context, Produk p) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => _DetailMenu(produk: p),
  );
}

class _DetailMenu extends StatefulWidget {
  final Produk produk;
  const _DetailMenu({required this.produk});

  @override
  State<_DetailMenu> createState() => _DetailMenuState();
}

class _DetailMenuState extends State<_DetailMenu> {
  String _ukuran = 'Medium', _gula = 'Normal', _suhu = 'Dingin';
  int _jumlah = 1;
  final _catatan = TextEditingController();

  @override
  void dispose() {
    _catatan.dispose();
    super.dispose();
  }

  int get _harga =>
      (widget.produk.harga + (widget.produk.berOpsi ? tambahanUkuran[_ukuran]! : 0)) *
          _jumlah;

  Widget _grup(String judul, List<String> opsi, String dipilih,
      ValueChanged<String> onPilih, {String Function(String)? label}) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(judul, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              for (final o in opsi)
                ChoiceChip(
                  label: Text(label?.call(o) ?? o),
                  selected: dipilih == o,
                  onSelected: (_) => setState(() => onPilih(o)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _tambah() {
    final p = widget.produk;
    final pesan = ScaffoldMessenger.of(context);
    context.read<KeranjangModel>().tambah(
      p,
      ukuran: p.berOpsi ? _ukuran : '',
      gula: p.berOpsi ? _gula : '',
      suhu: p.berOpsi ? _suhu : '',
      catatan: _catatan.text.trim(),
      jumlah: _jumlah,
    );
    Navigator.pop(context);
    pesan
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('${p.emoji} $_jumlah × ${p.nama} masuk pesanan'),
        duration: const Duration(seconds: 2),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.produk;
    final w = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: w.primaryContainer, borderRadius: BorderRadius.circular(18)),
                child: Text(p.emoji, style: const TextStyle(fontSize: 34)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.nama,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  Row(children: [
                    const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                    Text(' ${p.rating} · ${p.kategori}'),
                  ]),
                ]),
              ),
            ]),
            const SizedBox(height: 12),
            Text(p.deskripsi),
            if (p.berOpsi) ...[
              _grup('Ukuran', tambahanUkuran.keys.toList(), _ukuran,
                      (v) => _ukuran = v,
                  label: (o) => tambahanUkuran[o] == 0 ? o : '$o  +${rupiah(tambahanUkuran[o]!)}'),
              _grup('Gula', pilihanGula, _gula, (v) => _gula = v),
              _grup('Suhu', pilihanSuhu, _suhu, (v) => _suhu = v),
            ],
            const SizedBox(height: 14),
            TextField(
              controller: _catatan,
              decoration: const InputDecoration(hintText: 'Catatan (opsional)'),
            ),
            const SizedBox(height: 16),
            Row(children: [
              IconButton.filledTonal(
                onPressed: _jumlah > 1 ? () => setState(() => _jumlah--) : null,
                icon: const Icon(Icons.remove),
              ),
              SizedBox(
                width: 40,
                child: Text('$_jumlah',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              IconButton.filledTonal(
                onPressed: () => setState(() => _jumlah++),
                icon: const Icon(Icons.add),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _tambah,
                  child: Text('Tambah · ${rupiah(_harga)}'),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
