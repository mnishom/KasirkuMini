import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/katalog_service.dart';
import '../widgets/produk_card.dart';
import 'detail_produk_screen.dart';

/// [Pertemuan 11-12 · UI & Event Handling] Layar utama: grid katalog
/// produk dengan filter kategori. Tap kartu produk membuka
/// [DetailProdukScreen] untuk melihat detail / menambah ke keranjang.
class KatalogScreen extends StatefulWidget {
  final KatalogService katalogService;
  final Keranjang keranjang;
  final VoidCallback onKeranjangBerubah;

  const KatalogScreen({
    super.key,
    required this.katalogService,
    required this.keranjang,
    required this.onKeranjangBerubah,
  });

  @override
  State<KatalogScreen> createState() => _KatalogScreenState();
}

class _KatalogScreenState extends State<KatalogScreen> {
  String _kategoriTerpilih = 'Semua';

  @override
  void initState() {
    super.initState();
    widget.katalogService.addListener(_onKatalogBerubah);
    _cetakLaporanPajakPolimorfik();
  }

  @override
  void dispose() {
    widget.katalogService.removeListener(_onKatalogBerubah);
    super.dispose();
  }

  void _onKatalogBerubah() {
    if (mounted) setState(() {});
  }

  /// [Pertemuan 7 · Polimorfisme] Loop yang sama (`for produk in katalog`)
  /// memanggil `hitungPajak()` yang sama namanya, tapi hasilnya berbeda
  /// tergantung apakah objeknya `ProdukMakanan` (10%) atau `ProdukMinuman`
  /// (6%) — dipanggil sekali saat katalog pertama kali tampil.
  void _cetakLaporanPajakPolimorfik() {
    for (final produk in widget.katalogService.katalog) {
      debugPrint('${produk.nama} (${produk.runtimeType}): pajak Rp${produk.hitungPajak()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final daftarKategori = ['Semua', ...widget.katalogService.kategoriUnik];
    final produkDitampilkan = widget.katalogService.filterByKategori(
      _kategoriTerpilih == 'Semua' ? null : _kategoriTerpilih,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('KasirKu Mini'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: daftarKategori.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final kategori = daftarKategori[index];
                  return ChoiceChip(
                    label: Text(kategori),
                    selected: _kategoriTerpilih == kategori,
                    onSelected: (_) => setState(() => _kategoriTerpilih = kategori),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      body: produkDitampilkan.isEmpty
          ? const Center(child: Text('Belum ada produk di kategori ini'))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: produkDitampilkan.length,
              itemBuilder: (context, index) {
                final produk = produkDitampilkan[index];
                return ProdukCard(
                  produk: produk,
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DetailProdukScreen(
                          katalogService: widget.katalogService,
                          keranjang: widget.keranjang,
                          onKeranjangBerubah: widget.onKeranjangBerubah,
                          produk: produk,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DetailProdukScreen(
                katalogService: widget.katalogService,
                keranjang: widget.keranjang,
                onKeranjangBerubah: widget.onKeranjangBerubah,
                produk: null,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
      ),
    );
  }
}
