import 'package:flutter/foundation.dart';

import '../models/models.dart';
import 'database_service.dart';

/// [Pertemuan 4 · Collections] `KatalogService` adalah satu-satunya tempat
/// katalog produk disimpan di memori selama aplikasi berjalan, memakai
/// ketiga jenis collection Dart secara bermakna:
/// - `List<Produk>` : urutan tampil produk di layar katalog.
/// - `Map<String, Produk>` : lookup cepat produk berdasarkan `kode`
///   (dipakai saat keranjang perlu tahu detail produk dari kodenya).
/// - `Set<String>` : daftar kategori UNIK — otomatis tidak ada duplikat
///   walau banyak produk berbagi kategori yang sama.
///
/// Extends `ChangeNotifier` (state management sederhana bawaan Flutter,
/// bukan Provider/Riverpod/Bloc) supaya widget yang `listen` bisa
/// otomatis rebuild saat katalog berubah.
class KatalogService extends ChangeNotifier {
  final DatabaseService _db;
  final List<Produk> _katalog = [];
  final Map<String, Produk> _indexKode = {};
  final Set<String> _kategoriUnik = {};

  KatalogService({DatabaseService? databaseService})
      : _db = databaseService ?? DatabaseService.instance;

  List<Produk> get katalog => List.unmodifiable(_katalog);
  Set<String> get kategoriUnik => Set.unmodifiable(_kategoriUnik);

  /// [Pertemuan 15 · Data Persistence] Katalog dimuat dari SQLite saat
  /// aplikasi dibuka — bukan data hardcoded yang hilang tiap restart.
  Future<void> muatDariDatabase() async {
    final daftar = await _db.getAllProduk();
    _katalog
      ..clear()
      ..addAll(daftar);
    _reindex();
    notifyListeners();
  }

  void _reindex() {
    _indexKode
      ..clear()
      ..addEntries(_katalog.map((p) => MapEntry(p.kode, p)));
    _kategoriUnik
      ..clear()
      ..addAll(_katalog.map((p) => p.kategori));
  }

  /// [Pertemuan 10 · Exception Handling] Melempar [ProdukTidakDitemukanException]
  /// jika kode tidak ada di katalog, alih-alih mengembalikan `null` diam-diam.
  Produk cariByKode(String kode) {
    final produk = _indexKode[kode];
    if (produk == null) {
      throw ProdukTidakDitemukanException('Produk dengan kode $kode tidak ditemukan');
    }
    return produk;
  }

  List<Produk> filterByKategori(String? kategori) {
    if (kategori == null || kategori == 'Semua') return katalog;
    return _katalog.where((p) => p.kategori == kategori).toList();
  }

  Future<void> tambahProduk(Produk produk) async {
    await _db.insertProduk(produk);
    _katalog.add(produk);
    _reindex();
    notifyListeners();
  }

  Future<void> simpanPerubahan(Produk produk) async {
    await _db.updateProduk(produk);
    notifyListeners();
  }

  Future<void> restokProduk(String kode, int jumlah, [String? catatan]) async {
    final produk = cariByKode(kode);
    produk.tambahStok(jumlah, catatan);
    await _db.updateProduk(produk);
    notifyListeners();
  }

  Future<void> hapusProduk(String kode) async {
    await _db.deleteProduk(kode);
    _katalog.removeWhere((p) => p.kode == kode);
    _reindex();
    notifyListeners();
  }

  /// [Pertemuan 15 · Data Persistence] Menyimpan hasil checkout ke SQLite
  /// dan menyinkronkan stok produk yang berkurang ke database juga.
  Future<void> simpanTransaksi(Transaksi transaksi) async {
    await _db.insertTransaksi(transaksi);
    for (final item in transaksi.items) {
      await _db.updateProduk(item.produk);
    }
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> riwayatTransaksiRingkas() {
    return _db.getAllTransaksiRingkas();
  }

  Future<List<Map<String, dynamic>>> itemUntukTransaksi(String idTransaksi) {
    return _db.getItemUntukTransaksi(idTransaksi);
  }

  /// [Pertemuan 7 · Implicit Interface] Merekonstruksi objek [Transaksi]
  /// lengkap dari baris-baris database, supaya `riwayat_screen.dart` bisa
  /// memanggil `cetakStruk()` (kontrak `BisaDicetak`) yang sama persis
  /// dengan yang dipakai untuk transaksi baru.
  Future<Transaksi?> transaksiLengkap(String idTransaksi) async {
    final rowTransaksi = await _db.getTransaksiById(idTransaksi);
    if (rowTransaksi == null) return null;

    final transaksi = Transaksi(
      idTransaksi,
      waktu: DateTime.parse(rowTransaksi['waktu'] as String),
    );

    final rowsItem = await _db.getItemUntukTransaksi(idTransaksi);
    for (final rowItem in rowsItem) {
      final kodeProduk = rowItem['kodeProduk'] as String;
      Produk produk;
      try {
        produk = cariByKode(kodeProduk);
      } on ProdukTidakDitemukanException {
        // Produk sudah dihapus dari katalog: pakai placeholder minimal
        // supaya struk lama tetap bisa ditampilkan.
        produk = ProdukMakanan(kodeProduk, rowItem['namaSaatTransaksi'] as String, '-', 0, 0);
      }
      transaksi.tambahItem(
        produk,
        rowItem['jumlah'] as int,
        namaOverride: rowItem['namaSaatTransaksi'] as String,
        hargaOverride: rowItem['hargaSaatTransaksi'] as double,
      );
    }
    return transaksi;
  }
}
