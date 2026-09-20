/// [Pertemuan 7 · Implicit Interface] Di Dart, setiap class SECARA OTOMATIS
/// juga menjadi sebuah interface implisit. `BisaDicetak` sengaja dibuat
/// sebagai abstract class kosong-perilaku (hanya deklarasi method, tanpa
/// implementasi) agar jelas dipakai sebagai KONTRAK lewat kata kunci
/// `implements`, bukan sebagai induk yang diwariskan lewat `extends`.
///
/// Bedanya dengan `extends`: class yang melakukan `implements BisaDicetak`
/// TIDAK mewarisi perilaku apa pun dari `BisaDicetak` (karena memang tidak
/// ada). Ia hanya berjanji akan menyediakan implementasi PENUH untuk setiap
/// method yang dideklarasikan di sini — dalam hal ini `cetakStruk()`.
abstract class BisaDicetak {
  String cetakStruk();
}
