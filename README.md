# KasirKu Mini

Aplikasi kasir mobile sederhana untuk warung/kios kecil — mencatat katalog produk,
mengelola keranjang & transaksi, dan menyimpan riwayat penjualan. Semua data
tersimpan lokal di perangkat lewat SQLite (`sqflite`), tanpa backend/API/internet.

Proyek ini adalah **contoh rujukan (reference implementation)** untuk mata kuliah
Pemrograman Berorientasi Objek (PBO) — dibangun sebagai kelanjutan langsung dari
`class Produk` yang mahasiswa buat bertahap di Pertemuan 1–3, lalu disempurnakan
dengan seluruh konsep OOP Pertemuan 4–15.

## Tech Stack

- **Bahasa/Framework**: Dart + Flutter (stable)
- **Penyimpanan data**: SQLite lewat `sqflite` + `path` (3 tabel: `produk`,
  `transaksi`, `item_transaksi`)
- **State management**: `setState` / `ChangeNotifier` bawaan Flutter (tanpa
  Provider/Riverpod/Bloc/GetX)
- **Format tampilan**: `intl` (Rupiah & tanggal)

## Cara Menjalankan

```bash
flutter pub get
flutter run
```

Jalankan `flutter analyze` untuk memastikan tidak ada error, dan `flutter test`
untuk menjalankan unit test model.

Aplikasi ditargetkan untuk Android/emulator. Saat pertama kali dibuka, katalog
otomatis diisi beberapa produk contoh jika database masih kosong.

## Struktur Proyek

```
lib/
├── main.dart                      # Entry point + navigasi BottomNavigationBar
├── models/                        # Seluruh model domain (OOP inti)
├── services/                      # DatabaseService (sqflite) & KatalogService
├── screens/                       # 4 layar utama
└── widgets/                       # Widget reusable (ProdukCard, RingkasanTransaksi)
```

## Peta Konsep Pertemuan → File/Class

Tabel ini merangkum komentar `[Pertemuan N · Konsep]` yang ditulis langsung di
atas class/method terkait di source code — dosen bisa membuka file yang
disebutkan dan menunjuk komentarnya langsung ke mahasiswa.

| Pertemuan | Konsep | File / Class |
|---|---|---|
| 2 | Constructor, Named Constructor & Initializer List | `models/produk.dart` → `Produk`, `Produk.baru`, `Produk.restok` |
| 3 | Parameter positional/named/optional & default value | `models/produk.dart` → `tambahStok`, `aturDiskon`, `cetakStruk`, `tampilkanInfo` |
| 4 | Asosiasi | `models/kasir.dart` → `Kasir.layani(Keranjang)` |
| 4 | Agregasi | `models/keranjang.dart` → `Keranjang` |
| 4 | Komposisi | `models/transaksi.dart`, `models/item_transaksi.dart` → `Transaksi`, `ItemTransaksi` |
| 4 | Collections (`List`, `Map`, `Set`) | `models/keranjang.dart` (`List`, `Map`), `services/katalog_service.dart` (`List`, `Map`, `Set`) |
| 5 | Abstraksi & Enkapsulasi | `models/produk.dart` → `abstract class Produk`, getter/setter `harga`/`stok` |
| 6 | Inheritance | `models/produk_makanan.dart`, `models/produk_minuman.dart` → `extends Produk` |
| 6 | Mixin | `models/diskon_mixin.dart` → `mixin BisaDiskon`, `ProdukPromo` |
| 7 | Polimorfisme (`@override`) | `models/produk_makanan.dart` & `produk_minuman.dart` → `hitungPajak()`; loop polimorfik di `screens/katalog_screen.dart` |
| 7 | Implicit Interface | `models/bisa_dicetak.dart` → `BisaDicetak`; `models/transaksi.dart` → `Transaksi implements BisaDicetak` |
| 9 | Dart Libraries & pubspec.yaml | `models/models.dart` (barrel file), struktur folder `lib/` |
| 10 | Custom Exception & try-catch-finally | `models/exceptions.dart`; alur checkout di `screens/keranjang_screen.dart` |
| 10 | Null Safety (`?`, `??`, `late`) | `models/produk.dart` (`String? catatan`, `DateTime? waktuRestockTerakhir`); `services/database_service.dart` (`late Database _db`) |
| 11-12 | Widget, Event Handling & Navigasi | `screens/*.dart`, `widgets/*.dart`, `main.dart` (`BottomNavigationBar`) |
| 13-14 | Git & Dokumentasi | `.gitignore`, `README.md` ini, riwayat commit bertahap |
| 15 | Data Persistence (SQLite/sqflite) | `services/database_service.dart`, `services/katalog_service.dart` |

## Definition of Done

- [x] `flutter analyze` tanpa error
- [x] Minimal 1 abstract class (`Produk`), 2 subclass konkret dengan `@override`
      berbeda perilaku (`ProdukMakanan`, `ProdukMinuman`), 1 mixin (`BisaDiskon`),
      1 implicit interface (`BisaDicetak`)
- [x] Asosiasi, agregasi, komposisi terstruktur berbeda
- [x] `List`, `Set`, `Map` dipakai bermakna
- [x] Custom exception ditangkap `try-catch-finally` di alur checkout
- [x] Null safety dipakai nyata (`?`, `??`, `late`)
- [x] Data produk & transaksi tersimpan permanen via SQLite (CRUD penuh)
- [x] Struktur folder sesuai spesifikasi, `pubspec.yaml` minimal
- [x] `.gitignore` & `README.md` tersedia
- [x] Komentar pemetaan minggu di tiap class/method inti
