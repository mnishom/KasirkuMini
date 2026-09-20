import 'produk_makanan.dart';

/// [Pertemuan 6 · Mixin] `BisaDiskon` adalah mixin — kumpulan method yang
/// bisa "dicampurkan" ke class mana pun lewat kata kunci `with`, tanpa
/// class tersebut harus mewarisi (extends) `BisaDiskon` sebagai induknya.
///
/// Ini berbeda dari inheritance biasa: sebuah class hanya boleh `extends`
/// SATU superclass, tapi boleh `with` BANYAK mixin sekaligus. Mixin dipakai
/// untuk membagikan kemampuan (behavior) lintas class yang tidak punya
/// hubungan hierarki "is-a" yang jelas.
mixin BisaDiskon {
  /// Menghitung harga akhir setelah dipotong `persenDiskon` persen.
  double terapkanDiskon(double harga, double persenDiskon) {
    if (persenDiskon < 0 || persenDiskon > 100) {
      throw ArgumentError('Persen diskon harus di antara 0-100');
    }
    return harga - (harga * persenDiskon / 100);
  }
}

/// [Pertemuan 6 · Inheritance + Mixin Digabung] `ProdukPromo` MEWARISI
/// [ProdukMakanan] lewat `extends` (jadi tetap sebuah "makanan" yang punya
/// [ProdukMakanan.hitungPajak]) SEKALIGUS mencampurkan kemampuan
/// [BisaDiskon] lewat `with`. Contoh nyata bagaimana `extends` (relasi
/// "is-a" tunggal) dan `with` (kemampuan tambahan, bisa lebih dari satu)
/// dipakai bersamaan pada satu class.
class ProdukPromo extends ProdukMakanan with BisaDiskon {
  double persenPromo;

  ProdukPromo(
    super.kode,
    super.nama,
    super.kategori,
    super.harga,
    super.stok, {
    required this.persenPromo,
  });

  /// Harga setelah promo, memanfaatkan method [terapkanDiskon] yang
  /// didapat dari mixin [BisaDiskon].
  double get hargaPromo => terapkanDiskon(harga, persenPromo);
}
