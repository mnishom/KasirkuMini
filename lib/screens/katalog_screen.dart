import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  /// [Pertemuan 6 · Mixin] Contoh nyata `ProdukPromo` (extends
  /// `ProdukMakanan` + `with BisaDiskon`) dipakai langsung di layar ini
  /// untuk menampilkan banner promo — bukan hanya diuji lewat unit test.
  /// Produk promo ini sengaja tidak disimpan ke database, hanya untuk
  /// demonstrasi tampilan harga setelah diskon lewat `hargaPromo`.
  final ProdukPromo _promoHariIni = ProdukPromo(
    'PROMO001',
    'Paket Hemat Combo',
    'Promo',
    20000,
    99,
    persenPromo: 10,
  );

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

  Widget _buildBannerPromo() {
    final formatRupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      color: Colors.teal.shade50,
      child: ListTile(
        leading: const Icon(Icons.local_offer),
        title: Text('${_promoHariIni.nama} — diskon ${_promoHariIni.persenPromo.toStringAsFixed(0)}%'),
        subtitle: Text(
          '${formatRupiah.format(_promoHariIni.harga)} → ${formatRupiah.format(_promoHariIni.hargaPromo)}',
        ),
      ),
    );
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
      body: Column(
        children: [
          _buildBannerPromo(),
          Expanded(
            child: produkDitampilkan.isEmpty
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
          ),
        ],
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
