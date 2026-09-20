import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'models/models.dart';
import 'screens/katalog_screen.dart';
import 'screens/keranjang_screen.dart';
import 'screens/riwayat_screen.dart';
import 'services/katalog_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const KasirKuMiniApp());
}

/// [Pertemuan 9 · Dart Libraries] Titik masuk aplikasi. Semua model &
/// service diimpor lewat barrel file `models/models.dart`, bukan satu per
/// satu — lihat komentar di `models/models.dart` untuk penjelasannya.
class KasirKuMiniApp extends StatelessWidget {
  const KasirKuMiniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KasirKu Mini',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const BerandaKasir(),
    );
  }
}

/// [Pertemuan 11 · Navigasi Antar Layar] Widget induk yang menampung
/// `BottomNavigationBar` dan menyimpan satu instance [Keranjang] serta
/// [KatalogService] yang dipakai bersama oleh ketiga layar utama —
/// keranjang harus tetap sama isinya walau pengguna berpindah tab.
class BerandaKasir extends StatefulWidget {
  const BerandaKasir({super.key});

  @override
  State<BerandaKasir> createState() => _BerandaKasirState();
}

class _BerandaKasirState extends State<BerandaKasir> {
  final KatalogService _katalogService = KatalogService();
  final Keranjang _keranjang = Keranjang();
  int _tabTerpilih = 0;
  bool _sedangMemuat = true;

  @override
  void initState() {
    super.initState();
    _muatKatalogAwal();
  }

  /// [Pertemuan 15 · Data Persistence] Katalog dimuat dari SQLite saat
  /// aplikasi dibuka. Jika database masih kosong (instalasi pertama kali),
  /// katalog diisi beberapa produk contoh supaya demo tidak kosong.
  Future<void> _muatKatalogAwal() async {
    try {
      await _katalogService.muatDariDatabase();
      if (_katalogService.katalog.isEmpty) {
        await _seedProdukContoh();
        await _katalogService.muatDariDatabase();
      }
    } catch (e) {
      debugPrint('Gagal memuat katalog: $e');
    } finally {
      if (mounted) setState(() => _sedangMemuat = false);
    }
  }

  Future<void> _seedProdukContoh() async {
    final produkContoh = <Produk>[
      ProdukMakanan.restok('MKN001', 'Nasi Goreng', 15000, 20)..kategori = 'Makanan Berat',
      ProdukMakanan.restok('MKN002', 'Roti Bakar', 8000, 15)..kategori = 'Camilan',
      ProdukMinuman.restok('MNM001', 'Es Teh Manis', 5000, 30, dingin: true)
        ..kategori = 'Minuman Dingin',
      ProdukMinuman.restok('MNM002', 'Kopi Hitam', 7000, 10, dingin: false)
        ..kategori = 'Minuman Panas',
    ];
    for (final produk in produkContoh) {
      await _katalogService.tambahProduk(produk);
    }
  }

  void _onKeranjangBerubah() => setState(() {});

  @override
  Widget build(BuildContext context) {
    if (_sedangMemuat) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final layar = [
      KatalogScreen(
        katalogService: _katalogService,
        keranjang: _keranjang,
        onKeranjangBerubah: _onKeranjangBerubah,
      ),
      KeranjangScreen(
        keranjang: _keranjang,
        katalogService: _katalogService,
        onKeranjangBerubah: _onKeranjangBerubah,
      ),
      RiwayatScreen(katalogService: _katalogService),
    ];

    return Scaffold(
      body: IndexedStack(index: _tabTerpilih, children: layar),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabTerpilih,
        onDestinationSelected: (index) => setState(() => _tabTerpilih = index),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.storefront), label: 'Katalog'),
          NavigationDestination(
            icon: Badge(
              label: Text('${_keranjang.isi.length}'),
              isLabelVisible: !_keranjang.kosong,
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Keranjang',
          ),
          const NavigationDestination(icon: Icon(Icons.history), label: 'Riwayat'),
        ],
      ),
    );
  }
}
