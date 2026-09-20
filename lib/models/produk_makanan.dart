import 'produk.dart';

/// [Pertemuan 6 · Inheritance] `ProdukMakanan` mewarisi (extends) seluruh
/// atribut & method dari [Produk] — kode, nama, harga, stok, tambahStok,
/// dsb. tidak perlu ditulis ulang. Class ini hanya menambah hal yang
/// spesifik untuk makanan, lalu meng-override [hitungPajak] sesuai aturan
/// pajak makanan (10%).
class ProdukMakanan extends Produk {
  /// [Pertemuan 10 · Null Safety] Nullable karena tidak semua makanan
  /// memiliki tanggal kedaluwarsa yang wajib dicatat.
  DateTime? tanggalKedaluwarsa;

  ProdukMakanan(
    super.kode,
    super.nama,
    super.kategori,
    super.harga,
    super.stok, {
    this.tanggalKedaluwarsa,
  });

  /// [Pertemuan 2 · Named Constructor via Inheritance] Melanjutkan pola
  /// `Produk.baru` untuk membuat produk makanan baru dengan stok = 0.
  ProdukMakanan.baru(String kode, String nama, double harga)
      : this(kode, nama, 'Makanan', harga, 0);

  /// [Pertemuan 2 · Named Constructor via Inheritance] Melanjutkan pola
  /// `Produk.restok` untuk produk makanan dengan stok awal.
  ProdukMakanan.restok(String kode, String nama, double harga, int stokAwal)
      : this(kode, nama, 'Makanan', harga, stokAwal);

  /// [Pertemuan 7 · Polimorfisme] `@override` menandai bahwa method ini
  /// menggantikan implementasi abstrak di [Produk]. Aturan pajak makanan:
  /// 10% dari harga.
  @override
  double hitungPajak() => harga * 0.10;
}
