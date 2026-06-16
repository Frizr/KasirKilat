import 'dart:async';

import 'package:cashier/controller/barangcontroller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransaksiController extends GetxController {
  List transaksi = [];
  StreamSubscription? _sub;
  CollectionReference dbtransaksi =
      FirebaseFirestore.instance.collection('transaksi');

  /// Menambahkan transaksi baru (Checkout).
  /// Fungsi ini akan memvalidasi stok, menyimpan data ke koleksi 'transaksi',
  /// dan mengurangi stok barang secara atomik (menggunakan Firestore Transaction).
  Future<bool> addtransaksi({
    required var data,
    required int bayar,
    String metode = 'Cash',
  }) async {
    if (bayar <= 0) {
      _showError('Total transaksi tidak valid');
      return false;
    }

    final items = _prepareItems(data);
    if (items.isEmpty) {
      _showError('Keranjang masih kosong');
      return false;
    }

    final qtyMap = _buildQtyMap(items);
    if (qtyMap.isEmpty) {
      _showError('Jumlah beli tidak valid');
      return false;
    }

    final firestore = FirebaseFirestore.instance;
    final barangCollection = firestore.collection('barang');

    try {
      await firestore.runTransaction((transaction) async {
        final currentStockById = <String, int>{};
        final currentModalById = <String, int>{};

        for (final entry in qtyMap.entries) {
          final productId = entry.key;
          final requestedQty = entry.value;
          final productRef = barangCollection.doc(productId);
          final productSnap = await transaction.get(productRef);

          if (!productSnap.exists) {
            throw _TransaksiValidationException(
              'Produk ${_itemName(items, productId)} tidak ditemukan',
            );
          }

          final productData = productSnap.data();
          final currentStock = _toInt(productData?['jumlah']);
          final currentModal = _toInt(productData?['modal']);
          if (currentStock < requestedQty) {
            throw _TransaksiValidationException(
              'Stok ${_itemName(items, productId)} tidak cukup. '
              'Sisa stok: $currentStock',
            );
          }

          currentStockById[productId] = currentStock;
          currentModalById[productId] = currentModal;
        }

        final itemsToSave = items.map((item) {
          final productId = _itemId(item);
          return {
            ...item,
            'modal': currentModalById[productId] ?? 0,
          };
        }).toList();

        final transaksiRef = dbtransaksi.doc();
        transaction.set(transaksiRef, {
          'data': itemsToSave,
          'bayar': bayar,
          'metode': metode,
          'tgl': Timestamp.now(),
        });

        for (final entry in qtyMap.entries) {
          final productId = entry.key;
          final updatedStock = currentStockById[productId]! - entry.value;
          transaction.update(
            barangCollection.doc(productId),
            {'jumlah': updatedStock},
          );
        }
      });

      try {
        final gb = Get.find<Getbarang>();
        gb.getbarang();
      } catch (_) {}

      update();
      return true;
    } on _TransaksiValidationException catch (e) {
      _debugTransaksi('Validasi checkout gagal: ${e.message}');
      _showError(e.message);
      return false;
    } on FirebaseException catch (e) {
      _debugTransaksi(
        'FirebaseException checkout: code=${e.code}, message=${e.message}',
      );
      _showError(_firebaseTransactionMessage(e));
      return false;
    } catch (e, stack) {
      _debugTransaksi('Unexpected checkout error: $e');
      if (kDebugMode) {
        debugPrint(stack.toString());
      }
      _showError(
        kDebugMode
            ? 'Transaksi gagal: ${e.runtimeType}'
            : 'Transaksi gagal. Coba lagi.',
      );
      return false;
    }
  }

  /// Mengambil data seluruh riwayat transaksi secara realtime dari Firestore.
  /// Diurutkan dari yang terbaru ke terlama.
  void gettransaksi() {
    _sub?.cancel();
    transaksi.clear();
    _sub = dbtransaksi
        .orderBy('tgl', descending: true)
        .snapshots(includeMetadataChanges: true)
        .listen(
      (querySnapshot) {
        transaksi.clear();
        for (final res in querySnapshot.docs) {
          transaksi.add(
            {
              'id': res.id,
              'data': res.data(),
            },
          );
        }
        update();
      },
      onError: (e) {
        _debugTransaksi('gettransaksi error: $e');
      },
    );
  }

  /// Menyaring daftar transaksi berdasarkan rentang waktu tertentu.
  /// Dimulai dari [startInclusive] hingga sebelum [endExclusive].
  List getTransaksiByDateRange(
    DateTime startInclusive,
    DateTime endExclusive,
  ) {
    return transaksi.where((wrap) {
      try {
        final trx = wrap['data'] as Map<String, dynamic>;
        final tgl = _toDateTime(trx['tgl']);
        if (tgl == null) return false;
        return !tgl.isBefore(startInclusive) && tgl.isBefore(endExclusive);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  /// Mengambil daftar transaksi yang terjadi pada hari ini.
  List getTodayTransactions() {
    final start = _startOfDay(DateTime.now());
    final end = start.add(const Duration(days: 1));
    return getTransaksiByDateRange(start, end);
  }

  /// Mengambil daftar transaksi yang terjadi di bulan ini.
  List getMonthTransactions() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);
    return getTransaksiByDateRange(start, end);
  }

  /// Mengambil daftar transaksi selama seminggu terakhir (minggu ini).
  List getWeekTransactions() {
    final now = DateTime.now();
    final startOfToday = _startOfDay(now);
    final start = startOfToday.subtract(Duration(days: now.weekday - 1));
    final end = start.add(const Duration(days: 7));
    return getTransaksiByDateRange(start, end);
  }

  /// Menghitung total nominal pendapatan dari sebuah daftar transaksi.
  int calculateTotal(List trxList) {
    int total = 0;
    for (final wrap in trxList) {
      final trx = wrap['data'] as Map<String, dynamic>;
      total += _toInt(trx['bayar']);
    }
    return total;
  }

  /// Menghitung total nominal pendapatan per hari untuk 7 hari terakhir.
  /// Berguna untuk menampilkan grafik.
  List<Map<String, dynamic>> getLast7DaysTotals() {
    final result = <Map<String, dynamic>>[];
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final start = _startOfDay(day);
      final end = start.add(const Duration(days: 1));
      final dayTrx = getTransaksiByDateRange(start, end);
      result.add({
        'date': day,
        'total': calculateTotal(dayTrx),
        'count': dayTrx.length,
      });
    }
    return result;
  }

  /// Menyiapkan data keranjang (mengubahnya menjadi format List of Maps) sebelum disimpan
  List<Map<String, dynamic>> _prepareItems(dynamic data) {
    final sourceItems = data is Iterable ? data : const [];
    final items = <Map<String, dynamic>>[];

    for (final item in sourceItems) {
      if (item is! Map) continue;

      items.add(Map<String, dynamic>.from(item));
    }

    return items;
  }

  /// Mengelompokkan dan menghitung total jumlah (qty) tiap barang yang dibeli
  Map<String, int> _buildQtyMap(List<Map<String, dynamic>> items) {
    final qtyMap = <String, int>{};
    for (final item in items) {
      final idb = _itemId(item);
      final qty = _toInt(item['jumlahbeli']);
      if (idb.isNotEmpty && qty > 0) {
        qtyMap[idb] = (qtyMap[idb] ?? 0) + qty;
      }
    }
    return qtyMap;
  }

  String _itemId(Map item) {
    return (item['idb'] ?? item['id'] ?? '').toString();
  }

  String _itemName(List<Map<String, dynamic>> items, String productId) {
    for (final item in items) {
      if (_itemId(item) == productId) {
        final name = (item['nama'] ?? '').toString().trim();
        if (name.isNotEmpty) return name;
      }
    }
    return productId;
  }

  int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  String _firebaseTransactionMessage(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return kDebugMode
            ? 'Transaksi ditolak rules Firestore. (${e.code})'
            : 'Transaksi ditolak. Hubungi admin.';
      case 'unavailable':
      case 'deadline-exceeded':
        return 'Koneksi ke Firestore bermasalah. Coba lagi.';
      default:
        return kDebugMode
            ? 'Transaksi gagal: ${e.message ?? e.code} (${e.code})'
            : 'Transaksi gagal. Coba lagi.';
    }
  }

  /// Mencetak pesan log khusus transaksi saat aplikasi berjalan dalam mode Debug
  void _debugTransaksi(String message) {
    if (kDebugMode) {
      debugPrint('[TransaksiController] $message');
    }
  }

  /// Menampilkan pesan error di layar menggunakan Snackbar berwarna merah
  void _showError(String message) {
    Get.rawSnackbar(
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      backgroundColor: const Color(0xFFEF4444),
      duration: const Duration(seconds: 4),
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

class _TransaksiValidationException implements Exception {
  _TransaksiValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
