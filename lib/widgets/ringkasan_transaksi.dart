import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// [Pertemuan 11 · Widget Reusable] Menampilkan ringkasan subtotal, pajak,
/// dan grand total. Dipakai di `keranjang_screen.dart` (sebelum checkout)
/// maupun `riwayat_screen.dart` (saat melihat detail transaksi lama), jadi
/// dijadikan satu widget terpisah alih-alih ditulis ulang di dua tempat.
class RingkasanTransaksi extends StatelessWidget {
  final double subtotal;
  final double pajak;
  final double grandTotal;

  const RingkasanTransaksi({
    super.key,
    required this.subtotal,
    required this.pajak,
    required this.grandTotal,
  });

  @override
  Widget build(BuildContext context) {
    final formatRupiah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    Widget baris(String label, double nilai, {bool tebal = false}) {
      final style = tebal
          ? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
          : Theme.of(context).textTheme.bodyMedium;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: style),
            Text(formatRupiah.format(nilai), style: style),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        baris('Subtotal', subtotal),
        baris('Pajak', pajak),
        const Divider(),
        baris('Total', grandTotal, tebal: true),
      ],
    );
  }
}
