import 'keranjang.dart';
import 'transaksi.dart';

/// [Pertemuan 4 · Asosiasi] `Kasir` MENGGUNAKAN [Keranjang] lewat parameter
/// method [layani], tapi tidak memilikinya: `Kasir` tidak punya field
/// `Keranjang` sebagai bagian permanen dari dirinya, dan siklus hidup
/// `Keranjang` sama sekali tidak bergantung pada `Kasir` mana yang
/// melayaninya. Ini relasi paling longgar dibanding agregasi (lihat
/// keranjang.dart) maupun komposisi (lihat transaksi.dart) — sekadar
/// "kasir A memproses keranjang B", lalu selesai.
class Kasir {
  final String nama;

  Kasir(this.nama);

  /// Memproses checkout sebuah keranjang milik pembeli. `Keranjang` hanya
  /// "dipinjam" lewat parameter, tidak disimpan sebagai state `Kasir`.
  Transaksi layani(Keranjang keranjang) {
    return keranjang.checkout();
  }
}
