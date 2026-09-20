import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import '../services/katalog_service.dart';

/// [Pertemuan 11-12 · UI & Event Handling] Satu layar dengan DUA mode:
/// - `produk != null` → mode LIHAT DETAIL, tombol "Tambah ke Keranjang".
/// - `produk == null` → mode ADMIN, form tambah produk baru dengan
///   validasi input (Form + TextFormField.validator).
class DetailProdukScreen extends StatefulWidget {
  final KatalogService katalogService;
  final Keranjang keranjang;
  final VoidCallback onKeranjangBerubah;
  final Produk? produk;

  const DetailProdukScreen({
    super.key,
    required this.katalogService,
    required this.keranjang,
    required this.onKeranjangBerubah,
    required this.produk,
  });

  @override
  State<DetailProdukScreen> createState() => _DetailProdukScreenState();
}

class _DetailProdukScreenState extends State<DetailProdukScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kodeController = TextEditingController();
  final _namaController = TextEditingController();
  final _kategoriController = TextEditingController();
  final _hargaController = TextEditingController();
  final _stokController = TextEditingController();
  String _jenis = 'Makanan';
  int _jumlahKeranjang = 1;

  bool get _modeAdmin => widget.produk == null;

  @override
  void dispose() {
    _kodeController.dispose();
    _namaController.dispose();
    _kategoriController.dispose();
    _hargaController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  void _tambahKeKeranjang() {
    final produk = widget.produk!;
    widget.keranjang.tambah(produk, jumlah: _jumlahKeranjang);
    widget.onKeranjangBerubah();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$_jumlahKeranjang x ${produk.nama} ditambahkan ke keranjang')),
    );
    Navigator.of(context).pop();
  }

  /// [Pertemuan 10 · Exception Handling] Validasi input form lewat
  /// `TextFormField.validator` (Pertemuan 11), lalu validasi bisnis
  /// tambahan (harga/stok tidak boleh negatif) ditangkap lewat
  /// `try-catch` karena dilempar dari setter [Produk.harga].
  Future<void> _simpanProdukBaru() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final harga = double.parse(_hargaController.text);
      final stokAwal = int.parse(_stokController.text);

      final Produk produkBaru = _jenis == 'Makanan'
          ? ProdukMakanan.restok(
              _kodeController.text.trim(),
              _namaController.text.trim(),
              harga,
              stokAwal,
            )
          : ProdukMinuman.restok(
              _kodeController.text.trim(),
              _namaController.text.trim(),
              harga,
              stokAwal,
            );
      produkBaru.kategori = _kategoriController.text.trim();

      await widget.katalogService.tambahProduk(produkBaru);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk baru berhasil disimpan')),
      );
      Navigator.of(context).pop();
    } on ArgumentError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Input tidak valid: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan produk: $e')),
      );
    } finally {
      debugPrint('Percobaan simpan produk baru selesai diproses.');
    }
  }

  Future<void> _restokDialog() async {
    final jumlahController = TextEditingController();
    final catatanController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tambah Stok'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: jumlahController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Jumlah tambahan'),
            ),
            TextField(
              controller: catatanController,
              decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              final jumlah = int.tryParse(jumlahController.text);
              if (jumlah == null || jumlah <= 0) return;
              final navigator = Navigator.of(dialogContext);
              try {
                final catatan =
                    catatanController.text.trim().isEmpty ? null : catatanController.text.trim();
                await widget.katalogService.restokProduk(widget.produk!.kode, jumlah, catatan);
                navigator.pop();
                if (!mounted) return;
                setState(() {});
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal menambah stok: $e')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_modeAdmin) return _buildFormTambah();
    return _buildDetail();
  }

  Widget _buildDetail() {
    final produk = widget.produk!;
    final formatRupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: Text(produk.nama)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(produk.kategori, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Harga: ${formatRupiah.format(produk.harga)}'),
            Text('Stok: ${produk.stok}'),
            // [Pertemuan 7 · Polimorfisme] Nilai pajak berikut dihitung lewat
            // hitungPajak() milik subclass produk yang sebenarnya (10% untuk
            // ProdukMakanan, 6% untuk ProdukMinuman) tanpa layar ini perlu
            // tahu jenis produknya secara eksplisit.
            Text('Pajak per item: ${formatRupiah.format(produk.hitungPajak())}'),
            if (produk.catatan != null) Text('Catatan: ${produk.catatan}'),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  onPressed: _jumlahKeranjang > 1
                      ? () => setState(() => _jumlahKeranjang--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$_jumlahKeranjang', style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                  onPressed: () => setState(() => _jumlahKeranjang++),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: produk.stok == 0 ? null : _tambahKeKeranjang,
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Tambah ke Keranjang'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _restokDialog,
              icon: const Icon(Icons.inventory),
              label: const Text('Tambah Stok (Admin)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormTambah() {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Produk Baru')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _kodeController,
                decoration: const InputDecoration(labelText: 'Kode Produk'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Kode wajib diisi' : null,
              ),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              TextFormField(
                controller: _kategoriController,
                decoration: const InputDecoration(labelText: 'Kategori'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Kategori wajib diisi' : null,
              ),
              TextFormField(
                controller: _hargaController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final harga = double.tryParse(value ?? '');
                  if (harga == null) return 'Harga harus berupa angka';
                  if (harga < 0) return 'Harga tidak boleh negatif';
                  return null;
                },
              ),
              TextFormField(
                controller: _stokController,
                decoration: const InputDecoration(labelText: 'Stok Awal'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final stok = int.tryParse(value ?? '');
                  if (stok == null) return 'Stok harus berupa angka bulat';
                  if (stok < 0) return 'Stok tidak boleh negatif';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _jenis,
                decoration: const InputDecoration(labelText: 'Jenis Produk'),
                items: const [
                  DropdownMenuItem(value: 'Makanan', child: Text('Makanan')),
                  DropdownMenuItem(value: 'Minuman', child: Text('Minuman')),
                ],
                onChanged: (value) => setState(() => _jenis = value ?? 'Makanan'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _simpanProdukBaru,
                child: const Text('Simpan Produk'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
