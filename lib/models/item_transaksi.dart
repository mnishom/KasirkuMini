import 'produk.dart';

/// [Pertemuan 4 · Komposisi] `ItemTransaksi` adalah "bagian" dari sebuah
/// [Transaksi] (lihat transaksi.dart) dan tidak dirancang untuk berdiri
/// sendiri di luar transaksi induknya — objek ini hanya pernah dibuat dari
/// dalam constructor/method `Transaksi`, tidak pernah diterima langsung
/// dari luar (misalnya dari UI) lalu ditempel ke transaksi manapun.
///
/// `produk` di sini adalah REFERENSI ke objek [Produk] yang sama dengan
/// yang ada di katalog (bukan salinan), sehingga `namaSaatTransaksi` dan
/// `hargaSaatTransaksi` sengaja disalin manual saat item dibuat — supaya
/// riwayat transaksi tetap akurat meski harga produk di katalog berubah
/// di kemudian hari.
class ItemTransaksi {
  final Produk produk;
  final int jumlah;
  final String namaSaatTransaksi;
  final double hargaSaatTransaksi;

  /// [Pertemuan 3 · Optional Named Parameter] `namaOverride`/`hargaOverride`
  /// hanya dipakai saat merekonstruksi item LAMA dari database (lihat
  /// `KatalogService.transaksiLengkap`), supaya nama & harga yang tampil
  /// tetap sesuai catatan historis meski data produk di katalog sudah
  /// berubah sejak transaksi itu terjadi. Untuk transaksi baru dari
  /// checkout, kedua parameter ini diabaikan dan nilainya diambil
  /// langsung dari `produk` saat ini.
  ItemTransaksi(this.produk, this.jumlah, {String? namaOverride, double? hargaOverride})
      : namaSaatTransaksi = namaOverride ?? produk.nama,
        hargaSaatTransaksi = hargaOverride ?? produk.harga;

  double get subtotal => hargaSaatTransaksi * jumlah;

  double get pajak => produk.hitungPajak() * jumlah;

  @override
  String toString() =>
      '$namaSaatTransaksi x$jumlah = Rp${subtotal.toStringAsFixed(0)}';
}
