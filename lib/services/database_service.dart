import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/models.dart';

/// [Pertemuan 15 · Data Persistence] Lapisan paling bawah yang berbicara
/// langsung dengan SQLite lewat package `sqflite`. Semua query SQL mentah
/// hidup di sini saja — layar (screens) tidak pernah menulis SQL sendiri,
/// mereka memanggil method Dart biasa lewat [KatalogService].
///
/// Tiga tabel dibuat: `produk`, `transaksi`, `item_transaksi`, sesuai
/// struktur relasi komposisi `Transaksi` → `ItemTransaksi` di model.
class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();

  /// [Pertemuan 10 · Null Safety - `late`] `_db` belum bisa diisi saat
  /// object `DatabaseService` pertama kali dibuat (constructor tidak bisa
  /// `async`), jadi dideklarasikan `late` dan baru benar-benar diisi lewat
  /// [_open] saat pertama kali dibutuhkan.
  late Database _db;
  bool _sudahDibuka = false;

  Future<Database> get database async {
    if (!_sudahDibuka) {
      _db = await _open();
      _sudahDibuka = true;
    }
    return _db;
  }

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'kasirku_mini.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE produk (
            kode TEXT PRIMARY KEY,
            nama TEXT NOT NULL,
            kategori TEXT NOT NULL,
            jenis TEXT NOT NULL,
            harga REAL NOT NULL,
            stok INTEGER NOT NULL,
            tersedia INTEGER NOT NULL,
            catatan TEXT,
            dingin INTEGER,
            tanggalKedaluwarsa TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE transaksi (
            idTransaksi TEXT PRIMARY KEY,
            waktu TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE item_transaksi (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            idTransaksi TEXT NOT NULL,
            kodeProduk TEXT NOT NULL,
            namaSaatTransaksi TEXT NOT NULL,
            hargaSaatTransaksi REAL NOT NULL,
            jumlah INTEGER NOT NULL,
            FOREIGN KEY (idTransaksi) REFERENCES transaksi (idTransaksi)
          )
        ''');
      },
    );
  }

  // ---------------------------------------------------------------------
  // CRUD Produk
  // ---------------------------------------------------------------------

  /// [Pertemuan 7 · Polimorfisme lewat data] `jenis` menyimpan tipe konkret
  /// produk ('makanan' / 'minuman') supaya saat dibaca kembali dari
  /// database, baris yang sama bisa direkonstruksi menjadi objek
  /// [ProdukMakanan] atau [ProdukMinuman] yang tepat.
  Future<void> insertProduk(Produk produk) async {
    try {
      final db = await database;
      await db.insert(
        'produk',
        _produkToMap(produk),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Gagal menyimpan produk: $e');
    }
  }

  Future<void> updateProduk(Produk produk) async {
    try {
      final db = await database;
      await db.update(
        'produk',
        _produkToMap(produk),
        where: 'kode = ?',
        whereArgs: [produk.kode],
      );
    } catch (e) {
      throw Exception('Gagal memperbarui produk: $e');
    }
  }

  Future<void> deleteProduk(String kode) async {
    try {
      final db = await database;
      await db.delete('produk', where: 'kode = ?', whereArgs: [kode]);
    } catch (e) {
      throw Exception('Gagal menghapus produk: $e');
    }
  }

  Future<List<Produk>> getAllProduk() async {
    try {
      final db = await database;
      final rows = await db.query('produk');
      return rows.map(_produkFromMap).toList();
    } catch (e) {
      throw Exception('Gagal membaca daftar produk: $e');
    }
  }

  Map<String, dynamic> _produkToMap(Produk produk) {
    return {
      'kode': produk.kode,
      'nama': produk.nama,
      'kategori': produk.kategori,
      'jenis': produk is ProdukMakanan ? 'makanan' : 'minuman',
      'harga': produk.harga,
      'stok': produk.stok,
      'tersedia': produk.tersedia ? 1 : 0,
      'catatan': produk.catatan,
      'dingin': produk is ProdukMinuman ? (produk.dingin ? 1 : 0) : null,
      'tanggalKedaluwarsa': produk is ProdukMakanan
          ? produk.tanggalKedaluwarsa?.toIso8601String()
          : null,
    };
  }

  /// [Pertemuan 7 · Polimorfisme] Baris database yang sama diproses lewat
  /// satu method, tapi menghasilkan jenis objek `Produk` yang berbeda
  /// tergantung nilai kolom `jenis`.
  Produk _produkFromMap(Map<String, dynamic> map) {
    final jenis = map['jenis'] as String;
    final Produk produk;
    if (jenis == 'makanan') {
      final makanan = ProdukMakanan(
        map['kode'] as String,
        map['nama'] as String,
        map['kategori'] as String,
        map['harga'] as double,
        map['stok'] as int,
      );
      final tanggal = map['tanggalKedaluwarsa'] as String?;
      if (tanggal != null) {
        makanan.tanggalKedaluwarsa = DateTime.parse(tanggal);
      }
      produk = makanan;
    } else {
      produk = ProdukMinuman(
        map['kode'] as String,
        map['nama'] as String,
        map['kategori'] as String,
        map['harga'] as double,
        map['stok'] as int,
        dingin: (map['dingin'] as int? ?? 0) == 1,
      );
    }
    produk.tersedia = (map['tersedia'] as int) == 1;
    produk.catatan = map['catatan'] as String?;
    return produk;
  }

  // ---------------------------------------------------------------------
  // CRUD Transaksi
  // ---------------------------------------------------------------------

  Future<void> insertTransaksi(Transaksi transaksi) async {
    try {
      final db = await database;
      await db.transaction((txn) async {
        await txn.insert('transaksi', {
          'idTransaksi': transaksi.idTransaksi,
          'waktu': transaksi.waktu.toIso8601String(),
        });
        for (final item in transaksi.items) {
          await txn.insert('item_transaksi', {
            'idTransaksi': transaksi.idTransaksi,
            'kodeProduk': item.produk.kode,
            'namaSaatTransaksi': item.namaSaatTransaksi,
            'hargaSaatTransaksi': item.hargaSaatTransaksi,
            'jumlah': item.jumlah,
          });
        }
      });
    } catch (e) {
      throw Exception('Gagal menyimpan transaksi: $e');
    }
  }

  /// Membaca seluruh riwayat transaksi beserta ringkasan jumlah item &
  /// totalnya. Detail per-item dibaca terpisah lewat [getItemUntukTransaksi]
  /// agar riwayat_screen bisa menampilkan daftar ringkas dulu.
  Future<List<Map<String, dynamic>>> getAllTransaksiRingkas() async {
    try {
      final db = await database;
      return db.rawQuery('''
        SELECT t.idTransaksi, t.waktu,
               COUNT(i.id) AS jumlahItem,
               COALESCE(SUM(i.hargaSaatTransaksi * i.jumlah), 0) AS total
        FROM transaksi t
        LEFT JOIN item_transaksi i ON i.idTransaksi = t.idTransaksi
        GROUP BY t.idTransaksi, t.waktu
        ORDER BY t.waktu DESC
      ''');
    } catch (e) {
      throw Exception('Gagal membaca riwayat transaksi: $e');
    }
  }

  Future<Map<String, dynamic>?> getTransaksiById(String idTransaksi) async {
    try {
      final db = await database;
      final rows = await db.query(
        'transaksi',
        where: 'idTransaksi = ?',
        whereArgs: [idTransaksi],
      );
      return rows.isEmpty ? null : rows.first;
    } catch (e) {
      throw Exception('Gagal membaca transaksi: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getItemUntukTransaksi(String idTransaksi) async {
    try {
      final db = await database;
      return db.query(
        'item_transaksi',
        where: 'idTransaksi = ?',
        whereArgs: [idTransaksi],
      );
    } catch (e) {
      throw Exception('Gagal membaca item transaksi: $e');
    }
  }
}
