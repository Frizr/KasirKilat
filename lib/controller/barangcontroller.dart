import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Getbarang extends GetxController {
  CollectionReference dbbarang =
      FirebaseFirestore.instance.collection('barang');
  StreamSubscription? _sub;
  List barang = [];
  List temu = [];
  List beli = [];
  List sortgl = [];
  String searchQueryBarang = '';
  String sortOptionBarang = 'terbaru';

  /// Mengatur kata kunci pencarian produk dan memperbarui UI
  void setSearchQueryBarang(String q) {
    searchQueryBarang = q.toLowerCase();
    update();
  }

  /// Mengatur opsi pengurutan (sort) daftar produk dan memperbarui UI
  void setSortOptionBarang(String option) {
    sortOptionBarang = option;
    update();
  }

  /// Mengambil daftar produk yang sudah difilter dan diurutkan
  /// berdasarkan opsi pencarian dan pengurutan yang aktif
  List get displayBarang {
    List result = List.from(barang);
    if (searchQueryBarang.isNotEmpty) {
      result = result.where((element) {
        try {
          final data = element['data'] as Map<String, dynamic>?;
          final name = (data?['nama'] ?? '').toString().toLowerCase();
          final code = (data?['bar'] ?? '').toString().toLowerCase();
          return name.contains(searchQueryBarang) ||
              code.contains(searchQueryBarang);
        } catch (e) {
          return element.toString().toLowerCase().contains(searchQueryBarang);
        }
      }).toList();
    }

    // Sort
    if (sortOptionBarang == 'lama') {
      result.sort((a, b) {
        final dateA =
            (a['data']?['tgl'] as Timestamp?)?.toDate() ?? DateTime.now();
        final dateB =
            (b['data']?['tgl'] as Timestamp?)?.toDate() ?? DateTime.now();
        return dateA.compareTo(dateB);
      });
    } else if (sortOptionBarang == 'terbaru') {
      result.sort((a, b) {
        final dateA =
            (a['data']?['tgl'] as Timestamp?)?.toDate() ?? DateTime.now();
        final dateB =
            (b['data']?['tgl'] as Timestamp?)?.toDate() ?? DateTime.now();
        return dateB.compareTo(dateA);
      });
    } else if (sortOptionBarang == 'stock banyak') {
      result.sort((a, b) => ((b['data']?['jumlah'] ?? 0) as num)
          .compareTo((a['data']?['jumlah'] ?? 0) as num));
    } else if (sortOptionBarang == 'stock sedikit') {
      result.sort((a, b) => ((a['data']?['jumlah'] ?? 0) as num)
          .compareTo((b['data']?['jumlah'] ?? 0) as num));
    } else if (sortOptionBarang == 'harga tinggi') {
      result.sort((a, b) => ((b['data']?['harga'] ?? 0) as num)
          .compareTo((a['data']?['harga'] ?? 0) as num));
    } else if (sortOptionBarang == 'harga rendah') {
      result.sort((a, b) => ((a['data']?['harga'] ?? 0) as num)
          .compareTo((b['data']?['harga'] ?? 0) as num));
    }

    return result;
  }

  /// Menghapus semua barang dari keranjang belanja
  hapusbeliall() {
    beli.clear();
    update();
  }

  /// Menghapus satu barang tertentu dari keranjang belanja berdasarkan index
  hapusbeli({required int i}) {
    beli.removeAt(i);
    print(beli);
    update();
  }

  /// Menambahkan barang ke dalam keranjang belanja.
  /// Memeriksa ketersediaan stok sebelum menambahkan barang.
  bool addbeli(
      {required String kode,
      required String nama,
      required int harga,
      required int jumlah,
      required String id,
      required int jumlahbeli,
      required int tot}) {
    if (jumlah <= 0) {
      _showError('Stok $nama habis');
      return false;
    }

    if (jumlahbeli <= 0) {
      _showError('Jumlah beli harus lebih dari 0');
      return false;
    }

    final existingQty = beli.where((item) {
      final itemId = (item['idb'] ?? item['id'] ?? '').toString();
      return itemId == id;
    }).fold<int>(
      0,
      (total, item) => total + ((item['jumlahbeli'] as num?)?.toInt() ?? 0),
    );

    if (existingQty + jumlahbeli > jumlah) {
      _showError('Stok $nama tidak cukup. Sisa stok: $jumlah');
      return false;
    }

    beli.add({
      'idb': id,
      'kode': kode,
      'nama': nama,
      'harga': harga,
      'jumlah': jumlah,
      'jumlahbeli': jumlahbeli,
      'totharga': tot,
    });
    temu.clear();
    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }
    update();
    return true;
  }

  /// Mencari produk berdasarkan nama atau kode barcode secara spesifik
  /// Hasil pencarian disimpan dalam variabel `temu`
  cari({required String cari}) async {
    final q = cari.trim().toLowerCase();
    if (q.isEmpty) {
      temu = [];
      update();
      return;
    }

    temu = barang.where((element) {
      try {
        final data = element['data'] as Map<String, dynamic>?;
        final name = (data?['nama'] ?? '').toString().toLowerCase();
        final code = (data?['bar'] ?? '').toString().toLowerCase();
        return name.contains(q) || code.contains(q);
      } catch (e) {
        // fallback to string match if structure unexpected
        return element.toString().toLowerCase().contains(q);
      }
    }).toList();
    update();
  }

  /// Membaca/mengambil data produk secara realtime dari Firestore.
  /// Data disortir berdasarkan tanggal (terbaru) dan disimpan di list `barang`.
  void getbarang() {
    _sub?.cancel();
    barang.clear();
    _sub = dbbarang
        .orderBy('tgl', descending: true)
        .snapshots(includeMetadataChanges: true)
        .listen(
      (querySnapshot) {
        barang.clear();
        querySnapshot.docs.forEach(
          (res) {
            barang.add(
              {
                'id': res.id,
                'data': res.data(),
              },
            );
          },
        );
        update();
      },
    );
  }

  /// Menambahkan produk baru ke database Firestore
  addbarang(
      {required String bar,
      required String nama,
      required int harga,
      required int jumlah,
      required int modal}) async {
    await dbbarang.add({
      'bar': bar,
      'nama': nama,
      'harga': harga,
      'jumlah': jumlah,
      'modal': modal,
      'tgl': DateTime.now(),
    });
    update();
  }

  /// Mengubah/mengupdate data produk yang sudah ada di database
  editbarang(
      {required String id,
      required String nama,
      required int harga,
      required int stock,
      required int modal}) async {
    await dbbarang.doc(id).update({
      'nama': nama,
      'harga': harga,
      'jumlah': stock,
      'modal': modal,
    });
    update();
  }

  /// Menghapus produk dari database berdasarkan ID dan menampilkan notifikasi
  deletbarang({required String id, required String nama}) async {
    await dbbarang.doc(id).delete();
    Get.rawSnackbar(
      margin: const EdgeInsets.all(15),
      borderRadius: 15,
      backgroundColor: Colors.red,
      forwardAnimationCurve: Curves.elasticInOut,
      reverseAnimationCurve: Curves.elasticOut,
      messageText: Row(
        children: [
          const Icon(
            Icons.delete_outline_rounded,
            color: Colors.white,
          ),
          Text(
            "$nama berhasil dihapus",
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
    update();
  }

  /// Mengambil daftar produk yang stoknya menipis (di bawah batas tertentu)
  List<Map<String, dynamic>> getLowStockProducts({int threshold = 5}) {
    List<Map<String, dynamic>> lowStock = [];
    for (var item in barang) {
      final data = item['data'] as Map<String, dynamic>?;
      if (data != null) {
        int stock = (data['jumlah'] as num?)?.toInt() ?? 0;
        if (stock <= threshold) {
          lowStock.add({
            'id': item['id'],
            'nama': data['nama'] ?? '',
            'stock': stock,
          });
        }
      }
    }
    return lowStock;
  }

  /// Menghitung total jumlah stok semua produk
  int getTotalStock() {
    int total = 0;
    for (var item in barang) {
      final data = item['data'] as Map<String, dynamic>?;
      if (data != null) {
        total += (data['jumlah'] as num?)?.toInt() ?? 0;
      }
    }
    return total;
  }

  /// Menampilkan pesan error di layar menggunakan Snackbar
  void _showError(String message) {
    Get.rawSnackbar(
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 3),
      messageText: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
