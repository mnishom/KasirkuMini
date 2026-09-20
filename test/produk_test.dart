import 'package:flutter_test/flutter_test.dart';
import 'package:kasirku_mini/models/models.dart';

/// [Pertemuan 7 · Polimorfisme] Unit test ini adalah pembuktian nyata
/// bahwa `hitungPajak()` yang dipanggil lewat referensi tipe `Produk`
/// (bukan `ProdukMakanan`/`ProdukMinuman` secara eksplisit) tetap
/// menjalankan implementasi milik subclass yang sebenarnya.
void main() {
  group('Produk - constructor & enkapsulasi', () {
    test('Produk.baru membuat produk dengan stok 0 dan tidak tersedia', () {
      final produk = ProdukMakanan.baru('MKN100', 'Donat', 5000);
      expect(produk.stok, 0);
      expect(produk.tersedia, isFalse);
    });

    test('Produk.restok membuat produk dengan stok awal dan tersedia', () {
      final produk = ProdukMinuman.restok('MNM100', 'Jus Jeruk', 10000, 5);
      expect(produk.stok, 5);
      expect(produk.tersedia, isTrue);
    });

    test('setter harga menolak nilai negatif', () {
      final produk = ProdukMakanan.baru('MKN101', 'Kue', 3000);
      expect(() => produk.harga = -100, throwsArgumentError);
    });

    test('tambahStok menambah stok & mencatat waktu restock', () {
      final produk = ProdukMakanan.baru('MKN102', 'Bakso', 12000);
      produk.tambahStok(10, 'kiriman pagi');
      expect(produk.stok, 10);
      expect(produk.tersedia, isTrue);
      expect(produk.catatan, 'kiriman pagi');
      expect(produk.waktuRestockTerakhir, isNotNull);
    });

    test('kurangiStok melempar StokTidakCukupException jika kurang', () {
      final produk = ProdukMakanan.restok('MKN103', 'Sate', 20000, 2);
      expect(
        () => produk.kurangiStok(5),
        throwsA(isA<StokTidakCukupException>()),
      );
    });
  });

  group('Polimorfisme - hitungPajak berbeda per subclass', () {
    test('ProdukMakanan kena pajak 10%', () {
      final Produk produk = ProdukMakanan.restok('MKN200', 'Nasi Uduk', 10000, 5);
      expect(produk.hitungPajak(), 1000);
    });

    test('ProdukMinuman kena pajak 6%', () {
      final Produk produk = ProdukMinuman.restok('MNM200', 'Es Jeruk', 10000, 5);
      expect(produk.hitungPajak(), 600);
    });

    test('loop polimorfik menghasilkan pajak berbeda per jenis produk', () {
      final katalog = <Produk>[
        ProdukMakanan.restok('MKN201', 'Ayam Goreng', 15000, 5),
        ProdukMinuman.restok('MNM201', 'Teh Botol', 5000, 5),
      ];
      final hasilPajak = katalog.map((p) => p.hitungPajak()).toList();
      expect(hasilPajak, [1500, 300]);
    });
  });

  group('Keranjang - agregasi & checkout', () {
    test('checkout mengurangi stok produk & mengosongkan keranjang', () {
      final produk = ProdukMakanan.restok('MKN300', 'Mie Ayam', 12000, 10);
      final keranjang = Keranjang()..tambah(produk, jumlah: 3);

      final transaksi = keranjang.checkout();

      expect(produk.stok, 7);
      expect(keranjang.kosong, isTrue);
      expect(transaksi.items.length, 1);
      expect(transaksi.items.first.jumlah, 3);
    });

    test('checkout melempar StokTidakCukupException jika qty melebihi stok', () {
      final produk = ProdukMakanan.restok('MKN301', 'Gado-gado', 13000, 1);
      final keranjang = Keranjang()..tambah(produk, jumlah: 5);

      expect(() => keranjang.checkout(), throwsA(isA<StokTidakCukupException>()));
    });

    test('checkout melempar KeranjangKosongException jika keranjang kosong', () {
      final keranjang = Keranjang();
      expect(() => keranjang.checkout(), throwsA(isA<KeranjangKosongException>()));
    });
  });

  group('Transaksi - komposisi & implicit interface', () {
    test('cetakStruk (BisaDicetak) menampilkan total & pajak', () {
      final produk = ProdukMinuman.restok('MNM400', 'Kopi Susu', 18000, 5);
      final transaksi = Transaksi('TRX-TEST-1')..tambahItem(produk, 2);

      final struk = transaksi.cetakStruk();

      expect(struk, contains('Kopi Susu'));
      expect(transaksi.totalHarga, 36000);
      expect(transaksi.totalPajak, closeTo(2160, 0.01));
    });
  });

  group('Mixin BisaDiskon', () {
    test('ProdukPromo menghitung harga promo lewat mixin', () {
      final promo = ProdukPromo(
        'MKN500',
        'Paket Hemat',
        'Makanan',
        20000,
        5,
        persenPromo: 10,
      );
      expect(promo.hargaPromo, 18000);
    });
  });
}
