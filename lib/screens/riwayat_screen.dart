import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/katalog_service.dart';

/// [Pertemuan 11-12 · UI & Event Handling] Daftar riwayat transaksi
/// tersimpan (dibaca dari SQLite lewat [KatalogService]). Tap item untuk
/// melihat detail struk lengkap lewat `cetakStruk()`.
class RiwayatScreen extends StatefulWidget {
  final KatalogService katalogService;

  const RiwayatScreen({super.key, required this.katalogService});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  late Future<List<Map<String, dynamic>>> _riwayatFuture;

  @override
  void initState() {
    super.initState();
    _riwayatFuture = widget.katalogService.riwayatTransaksiRingkas();
  }

  void _muatUlang() {
    setState(() {
      _riwayatFuture = widget.katalogService.riwayatTransaksiRingkas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatRupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        actions: [
          IconButton(onPressed: _muatUlang, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _riwayatFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat riwayat: ${snapshot.error}'));
          }
          final daftar = snapshot.data ?? [];
          if (daftar.isEmpty) {
            return const Center(child: Text('Belum ada transaksi'));
          }

          // [Update] Pengelompokkan transaksi berdasarkan tanggal
          final grouped = <String, List<Map<String, dynamic>>>{};
          for (final row in daftar) {
            final waktu = DateTime.parse(row['waktu'] as String);
            final tanggalKey = DateFormat('yyyy-MM-dd').format(waktu);
            grouped.putIfAbsent(tanggalKey, () => []).add(row);
          }

          final keys = grouped.keys.toList();

          return ListView.builder(
            itemCount: keys.length,
            itemBuilder: (context, index) {
              final tanggalKey = keys[index];
              final transaksiHariIni = grouped[tanggalKey]!;
              final totalHariIni = transaksiHariIni.fold<double>(
                0,
                (prev, element) => prev + (element['total'] as num).toDouble(),
              );

              final tanggalObj = DateTime.parse(tanggalKey);
              final labelTanggal = DateFormat('EEEE, d MMMM y', 'id_ID').format(tanggalObj);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.grey[200],
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          labelTanggal,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          formatRupiah.format(totalHariIni),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...transaksiHariIni.map((row) {
                    final waktu = DateTime.parse(row['waktu'] as String);
                    return ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: Text(row['idTransaksi'] as String),
                      subtitle: Text(
                        '${DateFormat('HH:mm').format(waktu)} • ${row['jumlahItem']} item',
                      ),
                      trailing: Text(formatRupiah.format((row['total'] as num).toDouble())),
                      onTap: () => _bukaDetailStruk(row['idTransaksi'] as String),
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _bukaDetailStruk(String idTransaksi) async {
    try {
      final transaksi = await widget.katalogService.transaksiLengkap(idTransaksi);
      if (!mounted) return;
      if (transaksi == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Detail transaksi tidak ditemukan')),
        );
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Struk ${transaksi.idTransaksi}'),
          // [Pertemuan 7 · Implicit Interface] cetakStruk() di sini adalah
          // implementasi kontrak BisaDicetak milik Transaksi.
          content: SingleChildScrollView(child: Text(transaksi.cetakStruk())),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka detail struk: $e')),
      );
    }
  }
}
