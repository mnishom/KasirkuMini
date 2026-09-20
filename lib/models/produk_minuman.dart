import 'produk.dart';

/// [Pertemuan 6 · Inheritance] `ProdukMinuman` mewarisi [Produk] sama seperti
/// [ProdukMakanan], namun menambah atribut spesifik minuman ([dingin]) dan
/// meng-override [hitungPajak] dengan aturan pajak yang BERBEDA (6%),
/// bukan sekadar mengembalikan angka yang sama — inilah yang membuat
/// polimorfisme terlihat nyata saat dua jenis produk diperlakukan seragam.
class ProdukMinuman extends Produk {
  bool dingin;

  ProdukMinuman(
    super.kode,
    super.nama,
    super.kategori,
    super.harga,
    super.stok, {
    this.dingin = false,
  });

  /// [Pertemuan 2 · Named Constructor via Inheritance]
  ProdukMinuman.baru(String kode, String nama, double harga, {this.dingin = false})
      : super.baru(kode, nama, 'Minuman', harga);

  /// [Pertemuan 2 · Named Constructor via Inheritance]
  ProdukMinuman.restok(
    String kode,
    String nama,
    double harga,
    int stokAwal, {
    this.dingin = false,
  }) : super.restok(kode, nama, 'Minuman', harga, stokAwal);

  /// [Pertemuan 7 · Polimorfisme] Aturan pajak minuman: 6% dari harga —
  /// method sama namanya dengan `ProdukMakanan.hitungPajak()`, tapi
  /// perilakunya berbeda karena diterapkan pada objek yang berbeda jenis.
  @override
  double hitungPajak() => harga * 0.06;
}
