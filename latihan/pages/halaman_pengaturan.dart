import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tema_model.dart';

class HalamanPengaturan extends StatelessWidget {
  const HalamanPengaturan({super.key});

  Widget _kartu(BuildContext context, Widget isi) => Card(
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 14),
    color: Theme.of(context).colorScheme.surfaceContainerLow,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    child: Padding(padding: const EdgeInsets.all(16), child: isi),
  );

  @override
  Widget build(BuildContext context) {
    final t = context.watch<TemaModel>();
    final model = context.read<TemaModel>();
    const judul = TextStyle(fontWeight: FontWeight.w800, fontSize: 16);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _kartu(
          context,
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Profil', style: judul),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: t.nama,
              onChanged: model.setNama,
              decoration: const InputDecoration(
                labelText: 'Nama kamu',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 14),
            const Text('Tipe pesanan'),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                      value: 'Dine in', icon: Icon(Icons.chair_outlined), label: Text('Dine in')),
                  ButtonSegment(
                      value: 'Take away',
                      icon: Icon(Icons.shopping_bag_outlined),
                      label: Text('Take away')),
                ],
                selected: {t.tipe},
                onSelectionChanged: (s) => model.setTipe(s.first),
              ),
            ),
          ]),
        ),
        _kartu(
          context,
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Tampilan', style: judul),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('Mode gelap'),
              subtitle: const Text('Berlaku untuk seluruh aplikasi'),
              value: t.gelap,
              onChanged: model.setGelap,
            ),
            const SizedBox(height: 8),
            const Text('Warna tema'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 18,
              children: [
                for (var i = 0; i < TemaModel.warnaAksen.length; i++)
                  GestureDetector(
                    onTap: () => model.setAksen(i),
                    child: Column(children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: TemaModel.warnaAksen[i],
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 3,
                            color: t.aksen == i
                                ? Theme.of(context).colorScheme.onSurface
                                : Colors.transparent,
                          ),
                        ),
                        child: t.aksen == i
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(height: 4),
                      Text(TemaModel.namaAksen[i],
                          style: Theme.of(context).textTheme.bodySmall),
                    ]),
                  ),
              ],
            ),
          ]),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text('Kedai Kopi · Flutter + Provider',
              style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}
