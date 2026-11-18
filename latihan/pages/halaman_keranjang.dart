import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/keranjang_model.dart';
import '../models/produk.dart';
import '../models/tema_model.dart';

class HalamanKeranjang extends StatefulWidget {
  const HalamanKeranjang({super.key});

  @override
  State<HalamanKeranjang> createState() => _HalamanKeranjangState();
}

class _HalamanKeranjangState extends State<HalamanKeranjang> {
  final _promo = TextEditingController();

  @override
  void dispose() {
    _promo.dispose();
    super.dispose();
  }

  void _pakaiPromo() {
    final ok = context.read<KeranjangModel>().pakaiPromo(_promo.text);
    if (ok) {
      _promo.clear();
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Kode promo tidak valid')));
    }
  }

  void _pesan() {
    final nama = context.read<TemaModel>().nama;
    final tipe = context.read<TemaModel>().tipe;
    final p = context.read<KeranjangModel>().checkout(tipe);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Text('🎉', style: TextStyle(fontSize: 40)),
        title: const Text('Pesanan diterima!'),
        content: Text(
          'Terima kasih, $nama.\nPesanan ${p.nomor} · ${p.jumlah} item · ${rupiah(p.total)}\n'
              '($tipe) Kami kabari kalau sudah siap ☕',
          textAlign: TextAlign.center,
        ),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Siap!')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final k = context.watch<KeranjangModel>();
    final tipe = context.watch<TemaModel>().tipe;
    final w = Theme.of(context).colorScheme;

    if (k.kosong) return _Kosong(riwayat: k.riwayat);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final b in k.baris)
                Padding(
                  key: ValueKey(b.kunci),
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Dismissible(
                    key: ValueKey('d-${b.kunci}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      decoration: BoxDecoration(
                          color: w.errorContainer, borderRadius: BorderRadius.circular(20)),
                      child: Icon(Icons.delete_outline, color: w.onErrorContainer),
                    ),
                    onDismissed: (_) {
                      context.read<KeranjangModel>().hapus(b);
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(
                          content: Text('${b.produk.nama} dihapus'),
                          action: SnackBarAction(
                            label: 'Urungkan',
                            onPressed: () => context.read<KeranjangModel>().urungkanHapus(),
                          ),
                        ));
                    },
                    child: _KartuBaris(baris: b),
                  ),
                ),
              const SizedBox(height: 6),
              if (k.kodePromo != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: InputChip(
                    avatar: const Icon(Icons.local_offer, size: 18),
                    label: Text('Promo ${k.kodePromo} aktif'),
                    onDeleted: () => context.read<KeranjangModel>().hapusPromo(),
                  ),
                )
              else
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _promo,
                      textCapitalization: TextCapitalization.characters,
                      onSubmitted: (_) => _pakaiPromo(),
                      decoration: const InputDecoration(
                        hintText: 'Kode promo (coba KOPI10)',
                        prefixIcon: Icon(Icons.local_offer_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonal(onPressed: _pakaiPromo, child: const Text('Pakai')),
                ]),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          decoration: BoxDecoration(
            color: w.surfaceContainerLow,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Baris('Subtotal', rupiah(k.subtotal)),
              if (k.diskon > 0) _Baris('Diskon', '- ${rupiah(k.diskon)}', warna: Colors.green),
              const Divider(height: 20),
              _Baris('Total', rupiah(k.total), tebal: true),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _pesan,
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text('Pesan sekarang · $tipe'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Baris extends StatelessWidget {
  final String kiri, kanan;
  final bool tebal;
  final Color? warna;
  const _Baris(this.kiri, this.kanan, {this.tebal = false, this.warna});

  @override
  Widget build(BuildContext context) {
    final gaya = TextStyle(
      fontSize: tebal ? 18 : 14,
      fontWeight: tebal ? FontWeight.w800 : FontWeight.normal,
      color: warna,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Text(kiri, style: gaya),
        const Spacer(),
        Text(kanan, style: gaya),
      ]),
    );
  }
}

class _KartuBaris extends StatelessWidget {
  final BarisPesanan baris;
  const _KartuBaris({required this.baris});

  @override
  Widget build(BuildContext context) {
    final w = Theme.of(context).colorScheme;
    final model = context.read<KeranjangModel>();
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: w.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: w.primaryContainer, borderRadius: BorderRadius.circular(14)),
            child: Text(baris.produk.emoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(baris.produk.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(baris.ringkasOpsi,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 2),
              Text(rupiah(baris.subtotal),
                  style: TextStyle(color: w.primary, fontWeight: FontWeight.w700)),
            ]),
          ),
          Container(
            decoration: BoxDecoration(
                color: w.surfaceContainerHigh, borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.remove, size: 18),
                onPressed: () => model.ubahJumlah(baris, -1),
              ),
              Text('${baris.jumlah}', style: const TextStyle(fontWeight: FontWeight.w700)),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.add, size: 18),
                onPressed: () => model.ubahJumlah(baris, 1),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Kosong extends StatelessWidget {
  final List<Pesanan> riwayat;
  const _Kosong({required this.riwayat});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 40),
        const Center(child: Text('☕', style: TextStyle(fontSize: 64))),
        const SizedBox(height: 12),
        Center(
          child: Text('Belum ada pesanan',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800)),
        ),
        const Center(child: Text('Pilih menu favoritmu dulu ya')),
        if (riwayat.isNotEmpty) ...[
          const SizedBox(height: 32),
          const Text('Riwayat pesanan', style: TextStyle(fontWeight: FontWeight.w700)),
          for (final p in riwayat)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.check)),
              title: Text('Pesanan ${p.nomor}'),
              subtitle: Text('${p.jumlah} item · ${p.tipe}'),
              trailing: Text(rupiah(p.total),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
        ],
      ],
    );
  }
}
