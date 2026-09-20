import 'bisa_dicetak.dart';
import 'item_transaksi.dart';
import 'produk.dart';

/// [Pertemuan 4 · Komposisi] `Transaksi` adalah pemilik ("whole") dari
/// daftar [ItemTransaksi] ("part"). Ciri komposisi yang wajib ada di sini:
/// 1. List `_items` bersifat PRIVATE dan hanya diisi lewat method
///    [tambahItem] milik `Transaksi` sendiri — bukan lewat constructor
///    yang menerima `List<ItemTransaksi>` siap pakai dari luar.
/// 2. Siklus hidup `ItemTransaksi` menyatu dengan `Transaksi`-nya: begitu
///    sebuah `Transaksi` tidak dipakai lagi, seluruh `ItemTransaksi` di
///    dalamnya ikut tidak berarti — tidak ada yang memegang referensi ke
///    `ItemTransaksi` itu dari luar `Transaksi`.
///
/// [Pertemuan 7 · Implicit Interface] `Transaksi implements BisaDicetak`
/// mewajibkan class ini menyediakan implementasi PENUH untuk
/// `cetakStruk()` sendiri, tanpa mewarisi apa pun dari `BisaDicetak`.
class Transaksi implements BisaDicetak {
  final String idTransaksi;
  final DateTime waktu;
  final List<ItemTransaksi> _items = [];

  Transaksi(this.idTransaksi) : waktu = DateTime.now();

  /// Daftar item hanya boleh DIBACA dari luar lewat getter tak-mutable ini,
  /// bukan diubah langsung — mempertahankan aturan komposisi di atas.
  List<ItemTransaksi> get items => List.unmodifiable(_items);

  /// Satu-satunya cara menambah item ke transaksi ini: `Transaksi` sendiri
  /// yang membuat objek `ItemTransaksi`-nya.
  void tambahItem(Produk produk, int jumlah) {
    _items.add(ItemTransaksi(produk, jumlah));
  }

  double get totalHarga => _items.fold(0.0, (sum, item) => sum + item.subtotal);

  double get totalPajak => _items.fold(0.0, (sum, item) => sum + item.pajak);

  double get grandTotal => totalHarga + totalPajak;

  /// [Pertemuan 7 · Implicit Interface] Implementasi wajib dari kontrak
  /// `BisaDicetak.cetakStruk()`.
  @override
  String cetakStruk() {
    final buffer = StringBuffer()
      ..writeln('=== STRUK TRANSAKSI ===')
      ..writeln('ID: $idTransaksi')
      ..writeln('Waktu: $waktu')
      ..writeln('------------------------');
    for (final item in _items) {
      buffer.writeln(item.toString());
    }
    buffer
      ..writeln('------------------------')
      ..writeln('Subtotal: Rp${totalHarga.toStringAsFixed(0)}')
      ..writeln('Pajak: Rp${totalPajak.toStringAsFixed(0)}')
      ..writeln('TOTAL: Rp${grandTotal.toStringAsFixed(0)}');
    return buffer.toString();
  }
}
