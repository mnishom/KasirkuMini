import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';

/// [Pertemuan 11 · Widget & Event Handling] Kartu produk yang dipakai
/// berulang di `katalog_screen.dart`. Menampilkan badge "Stok menipis"
/// ketika stok di bawah ambang batas, dan memanggil [onTap] (event
/// handling yang terhubung ke logika navigasi, bukan sekadar `print()`)
/// saat kartu diketuk.
class ProdukCard extends StatelessWidget {
  static const ambangStokMenipis = 5;

  final Produk produk;
  final VoidCallback onTap;

  const ProdukCard({super.key, required this.produk, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final formatRupiah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    final stokMenipis = produk.stok > 0 && produk.stok < ambangStokMenipis;
    final habis = produk.stok == 0;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                produk.nama,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                produk.kategori,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              Text(formatRupiah.format(produk.harga)),
              const SizedBox(height: 4),
              if (habis)
                const Chip(
                  label: Text('Stok habis'),
                  visualDensity: VisualDensity.compact,
                )
              else if (stokMenipis)
                Chip(
                  label: Text('Stok menipis (${produk.stok})'),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: Colors.orange.shade100,
                )
              else
                Text('Stok: ${produk.stok}'),
            ],
          ),
        ),
      ),
    );
  }
}
