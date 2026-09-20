import 'exceptions.dart';
import 'produk.dart';
import 'transaksi.dart';

/// [Pertemuan 4 · Agregasi] `Keranjang` berisi REFERENSI ke objek [Produk]
/// yang tetap ada & tetap dikelola oleh katalog, terlepas dari keranjang
/// ini. Ciri agregasi yang membedakannya dari komposisi (lihat
/// transaksi.dart): kalau `Keranjang.kosongkan()` dipanggil, objek `Produk`
/// di dalamnya TIDAK ikut hancur — ia tetap hidup di katalog karena memang
/// bukan `Keranjang` yang menciptakan/memiliki siklus hidup `Produk`.
///
/// [Pertemuan 4 · Collections] Dua jenis collection dipakai bermakna di
/// sini: `List<Produk>` untuk urutan produk yang ditambahkan, dan
/// `Map<String, int>` (kode produk → jumlah) untuk lookup qty per produk
/// secara cepat tanpa perlu scan list satu-satu.
class Keranjang {
  final List<Produk> isi = [];
  final Map<String, int> jumlahPerProduk = {};

  void tambah(Produk produk, {int jumlah = 1}) {
    if (jumlah <= 0) {
      throw ArgumentError('Jumlah harus lebih dari 0');
    }
    if (!jumlahPerProduk.containsKey(produk.kode)) {
      isi.add(produk);
      jumlahPerProduk[produk.kode] = jumlah;
    } else {
      jumlahPerProduk[produk.kode] = jumlahPerProduk[produk.kode]! + jumlah;
    }
  }

  void ubahJumlah(Produk produk, int jumlahBaru) {
    if (jumlahBaru <= 0) {
      hapus(produk);
      return;
    }
    jumlahPerProduk[produk.kode] = jumlahBaru;
  }

  void hapus(Produk produk) {
    isi.removeWhere((p) => p.kode == produk.kode);
    jumlahPerProduk.remove(produk.kode);
  }

  /// Mengosongkan keranjang. Objek [Produk] di dalamnya TIDAK dihapus dari
  /// katalog — hanya referensinya yang dilepas dari keranjang ini
  /// (perilaku khas agregasi).
  void kosongkan() {
    isi.clear();
    jumlahPerProduk.clear();
  }

  bool get kosong => isi.isEmpty;

  double get totalSementara {
    var total = 0.0;
    for (final produk in isi) {
      final jumlah = jumlahPerProduk[produk.kode] ?? 0;
      total += produk.harga * jumlah;
    }
    return total;
  }

  /// [Pertemuan 10 · Exception Handling] Checkout divalidasi DUA TAHAP:
  /// pertama memastikan seluruh item stoknya cukup (tanpa mengubah apa
  /// pun), baru kemudian benar-benar mengurangi stok & menyusun
  /// [Transaksi]. Kalau ada satu saja yang stoknya kurang,
  /// [StokTidakCukupException] dilempar SEBELUM stok produk lain sempat
  /// berubah.
  Transaksi checkout() {
    if (kosong) {
      throw KeranjangKosongException('Keranjang masih kosong, tidak bisa checkout');
    }

    for (final produk in isi) {
      final jumlah = jumlahPerProduk[produk.kode] ?? 0;
      if (jumlah > produk.stok) {
        throw StokTidakCukupException(
          'Stok ${produk.nama} tidak cukup (tersedia: ${produk.stok}, diminta: $jumlah)',
        );
      }
    }

    final idTransaksi = 'TRX${DateTime.now().millisecondsSinceEpoch}';
    final transaksi = Transaksi(idTransaksi);
    for (final produk in isi) {
      final jumlah = jumlahPerProduk[produk.kode] ?? 0;
      produk.kurangiStok(jumlah);
      transaksi.tambahItem(produk, jumlah);
    }

    kosongkan();
    return transaksi;
  }
}
