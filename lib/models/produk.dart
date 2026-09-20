import 'exceptions.dart';

/// [Pertemuan 5 · Abstraksi & Enkapsulasi] `Produk` adalah abstract class:
/// mendefinisikan "bentuk" umum sebuah produk tanpa bisa diinstansiasi
/// langsung (`Produk p = Produk(...)` tidak sah). Setiap jenis produk nyata
/// (lihat `ProdukMakanan`, `ProdukMinuman`) wajib melanjutkan (extends)
/// class ini dan mengisi bagian yang belum lengkap, yaitu [hitungPajak].
///
/// Enkapsulasi terlihat pada [_harga] dan [_stok]: keduanya library-private
/// (diawali garis bawah) sehingga tidak bisa diubah sembarangan dari luar
/// file ini. Perubahan nilai wajib lewat getter/setter yang memvalidasi,
/// bukan lewat akses field langsung.
abstract class Produk {
  final String kode;
  String nama;
  String kategori;
  double _harga;
  int _stok;
  bool tersedia;

  /// [Pertemuan 3 · Optional Named Parameter] `catatan` bersifat opsional
  /// dan nullable (`String?`) — memenuhi null safety yang genuinely dipakai,
  /// bukan formalitas: setiap kali stok direstok, boleh disertai catatan,
  /// boleh juga tidak.
  String? catatan;

  /// [Pertemuan 10 · Null Safety] Nullable karena produk yang baru dibuat
  /// (lihat [Produk.baru]) belum pernah direstok sama sekali.
  DateTime? waktuRestockTerakhir;

  /// [Pertemuan 2 · Constructor & Initializer List] Constructor utama.
  /// `tersedia` dihitung otomatis dari stok awal lewat initializer list
  /// (bagian setelah tanda titik dua `:`), bukan di dalam body constructor.
  Produk(this.kode, this.nama, this.kategori, this._harga, this._stok)
      : tersedia = _stok > 0;

  /// [Pertemuan 2 · Named Constructor] Dipakai saat mendaftarkan produk
  /// baru ke katalog yang stoknya belum diisi (stok awal = 0). Named
  /// constructor ini mendelegasikan ke constructor utama lewat `this(...)`.
  Produk.baru(String kode, String nama, String kategori, double harga)
      : this(kode, nama, kategori, harga, 0);

  /// [Pertemuan 2 · Named Constructor] Dipakai saat produk langsung
  /// didaftarkan dengan stok awal (mis. hasil restok pertama dari supplier).
  Produk.restok(
    String kode,
    String nama,
    String kategori,
    double harga,
    int stokAwal,
  ) : this(kode, nama, kategori, harga, stokAwal);

  /// [Pertemuan 5 · Enkapsulasi] Getter untuk membaca harga dari luar class.
  double get harga => _harga;

  /// [Pertemuan 5 · Enkapsulasi] Setter memvalidasi input sebelum benar-benar
  /// mengubah field private `_harga`. Tanpa setter ini, siapa pun bisa
  /// mengisi harga negatif langsung ke field.
  set harga(double nilai) {
    if (nilai < 0) {
      throw ArgumentError('Harga tidak boleh negatif');
    }
    _harga = nilai;
  }

  /// [Pertemuan 5 · Enkapsulasi] Stok hanya boleh dibaca dari luar class.
  /// Perubahan stok wajib lewat method [tambahStok] atau [kurangiStok] agar
  /// aturan bisnis (mis. tidak boleh minus) selalu ditegakkan.
  int get stok => _stok;

  /// [Pertemuan 3 · Optional Positional Parameter] `catatan` diapit kurung
  /// siku `[...]` sehingga boleh dipanggil dengan 1 atau 2 argumen:
  /// `tambahStok(10)` maupun `tambahStok(10, 'kiriman supplier A')`.
  void tambahStok(int jumlah, [String? catatan]) {
    if (jumlah <= 0) {
      throw ArgumentError('Jumlah tambah stok harus lebih dari 0');
    }
    _stok += jumlah;
    tersedia = _stok > 0;
    waktuRestockTerakhir = DateTime.now();
    if (catatan != null) {
      this.catatan = catatan;
    }
  }

  /// [Pertemuan 10 · Exception Handling] Dipanggil saat checkout. Melempar
  /// [StokTidakCukupException] alih-alih diam-diam membiarkan stok minus,
  /// supaya pemanggil (UI) wajib menangani kondisi gagal ini secara eksplisit.
  void kurangiStok(int jumlah) {
    if (jumlah > _stok) {
      throw StokTidakCukupException(
        'Stok $nama tidak cukup (tersedia: $_stok, diminta: $jumlah)',
      );
    }
    _stok -= jumlah;
    tersedia = _stok > 0;
  }

  /// [Pertemuan 3 · Named Parameter Wajib] `persen` wajib diisi (`required`)
  /// karena tanpa nilai diskon, method ini tidak bermakna. `alasan`
  /// tetap opsional karena hanya informasi tambahan untuk struk/log.
  void aturDiskon({required double persen, String? alasan}) {
    if (persen < 0 || persen > 100) {
      throw ArgumentError('Persen diskon harus di antara 0-100');
    }
    final potongan = _harga * persen / 100;
    _harga -= potongan;
    final catatanDiskon = alasan != null ? ' ($alasan)' : '';
    catatan = 'Diskon $persen% diterapkan$catatanDiskon';
  }

  /// [Pertemuan 3 · Optional Named Parameter dengan Default Value]
  /// `includeDiskon` punya nilai default `false`, sehingga pemanggil boleh
  /// mengabaikannya kalau tidak butuh info diskon di struk.
  String cetakStruk({bool includeDiskon = false}) {
    final buffer = StringBuffer()
      ..writeln('$nama ($kategori)')
      ..writeln('Harga: Rp${_harga.toStringAsFixed(0)}')
      ..writeln('Stok tersisa: $_stok');
    if (includeDiskon && catatan != null) {
      buffer.writeln('Catatan: $catatan');
    }
    return buffer.toString();
  }

  /// [Pertemuan 3 · Positional Parameter Biasa] Method sederhana dengan
  /// parameter wajib biasa (tanpa kurung siku/kurawal) sebagai pembanding
  /// terhadap gaya parameter lain di class ini.
  String tampilkanInfo(String prefix) => '$prefix$nama - Rp${_harga.toStringAsFixed(0)}';

  /// [Pertemuan 7 · Abstraksi → Polimorfisme] Method abstrak: class ini
  /// sengaja TIDAK memberi implementasi. Setiap subclass WAJIB
  /// meng-override method ini dengan aturan pajaknya masing-masing. Inilah
  /// jembatan menuju polimorfisme: kode yang memanggil `produk.hitungPajak()`
  /// tidak perlu tahu jenis produk apa yang sedang dipegang.
  double hitungPajak();

  @override
  String toString() => 'Produk($kode, $nama, Rp${_harga.toStringAsFixed(0)}, stok=$_stok)';
}
