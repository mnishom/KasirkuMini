import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import '../services/katalog_service.dart';
import '../widgets/ringkasan_transaksi.dart';

/// [Pertemuan 11-12 · UI & Event Handling] Layar keranjang & checkout.
/// Tombol "+"/"-" benar-benar memanggil method model ([Keranjang.ubahJumlah])
/// lalu `setState` me-refresh tampilan — bukan sekadar `print()`.
class KeranjangScreen extends StatefulWidget {
  final Keranjang keranjang;
  final KatalogService katalogService;
  final VoidCallback onKeranjangBerubah;

  const KeranjangScreen({
    super.key,
    required this.keranjang,
    required this.katalogService,
    required this.onKeranjangBerubah,
  });

  @override
  State<KeranjangScreen> createState() => _KeranjangScreenState();
}

class _KeranjangScreenState extends State<KeranjangScreen> {
  bool _sedangCheckout = false;

  /// [Pertemuan 4 · Asosiasi] `Kasir` dipakai di sini persis seperti
  /// relasi asosiasi yang dijelaskan di `models/kasir.dart`: hanya
  /// "meminjam" [Keranjang] lewat parameter method [Kasir.layani], tidak
  /// menyimpannya secara permanen.
  final Kasir _kasir = Kasir('Kasir 1');

  double get _totalPajak {
    var total = 0.0;
    for (final produk in widget.keranjang.isi) {
      final jumlah = widget.keranjang.jumlahPerProduk[produk.kode] ?? 0;
      total += produk.hitungPajak() * jumlah;
    }
    return total;
  }

  /// [Pertemuan 10 · try-catch-finally di alur nyata] Checkout adalah TITIK
  /// UTAMA custom exception ditangani: [StokTidakCukupException] dan
  /// [KeranjangKosongException] ditangkap terpisah supaya pesan ke
  /// pengguna relevan dengan masalahnya, sementara `finally` selalu
  /// menjalankan cleanup UI (mematikan indikator loading) apa pun hasilnya.
  Future<void> _checkout() async {
    setState(() => _sedangCheckout = true);
    try {
      final transaksi = _kasir.layani(widget.keranjang);
      await widget.katalogService.simpanTransaksi(transaksi);
      widget.onKeranjangBerubah();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout berhasil! ID: ${transaksi.idTransaksi}')),
      );
    } on StokTidakCukupException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.pesan), backgroundColor: Colors.red),
      );
    } on KeranjangKosongException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.pesan), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _sedangCheckout = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatRupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    final keranjang = widget.keranjang;

    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang')),
      body: keranjang.kosong
          ? const Center(child: Text('Keranjang masih kosong'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: keranjang.isi.length,
                    itemBuilder: (context, index) {
                      final produk = keranjang.isi[index];
                      final jumlah = keranjang.jumlahPerProduk[produk.kode] ?? 0;
                      return ListTile(
                        title: Text(produk.nama),
                        subtitle: Text(formatRupiah.format(produk.harga)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => setState(
                                () => keranjang.ubahJumlah(produk, jumlah - 1),
                              ),
                            ),
                            Text('$jumlah'),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => setState(
                                () => keranjang.ubahJumlah(produk, jumlah + 1),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => setState(() => keranjang.hapus(produk)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      RingkasanTransaksi(
                        subtotal: keranjang.totalSementara,
                        pajak: _totalPajak,
                        grandTotal: keranjang.totalSementara + _totalPajak,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _sedangCheckout ? null : _checkout,
                        child: _sedangCheckout
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Checkout'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
