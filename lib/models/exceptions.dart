/// [Pertemuan 10 · Custom Exception] Exception buatan sendiri dengan
/// `implements Exception`. Dipakai di alur checkout ketika jumlah yang
/// diminta pembeli melebihi stok yang tersedia di [Produk].
///
/// Membuat exception khusus (bukan sekadar `throw 'error'` atau
/// `throw Exception('...')` generik) membuat kode pemanggil bisa menangkap
/// kasus ini secara spesifik lewat `on StokTidakCukupException catch (e)`,
/// terpisah dari jenis error lain.
class StokTidakCukupException implements Exception {
  final String pesan;
  StokTidakCukupException(this.pesan);

  @override
  String toString() => 'StokTidakCukupException: $pesan';
}

/// [Pertemuan 10 · Custom Exception] Dilempar saat mencoba checkout
/// keranjang yang masih kosong.
class KeranjangKosongException implements Exception {
  final String pesan;
  KeranjangKosongException(this.pesan);

  @override
  String toString() => 'KeranjangKosongException: $pesan';
}

/// [Pertemuan 10 · Custom Exception] Dilempar saat kode produk yang dicari
/// tidak ditemukan di katalog (mis. lookup lewat `Map<String, Produk>`).
class ProdukTidakDitemukanException implements Exception {
  final String pesan;
  ProdukTidakDitemukanException(this.pesan);

  @override
  String toString() => 'ProdukTidakDitemukanException: $pesan';
}
