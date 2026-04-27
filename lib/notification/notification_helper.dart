import 'package:cashier/controller/barangcontroller.dart';
import 'package:cashier/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationHelper {
  /// Get list of products with low stock (below threshold)
  static List<Map<String, dynamic>> getLowStockProducts({int threshold = 5}) {
    try {
      final Getbarang b = Get.find<Getbarang>();
      List<Map<String, dynamic>> lowStock = [];
      for (var item in b.barang) {
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
    } catch (e) {
      return [];
    }
  }

  /// Show low stock notification snackbar
  static void showLowStockAlert() {
    final lowStock = getLowStockProducts();
    if (lowStock.isEmpty) return;

    String message;
    if (lowStock.length == 1) {
      message = '${lowStock[0]['nama']} stok tinggal ${lowStock[0]['stock']}!';
    } else {
      message = '${lowStock.length} produk stok menipis!';
    }

    Get.rawSnackbar(
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      backgroundColor: AppColors.amber,
      duration: const Duration(seconds: 4),
      icon: const Padding(
        padding: EdgeInsets.only(left: 12),
        child: Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          fontFamily: 'm',
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Show transaction success notification
  static void showTransactionSuccess({required int total, required String metode}) {
    Get.rawSnackbar(
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      backgroundColor: AppColors.success,
      duration: const Duration(seconds: 3),
      icon: const Padding(
        padding: EdgeInsets.only(left: 12),
        child: Icon(Icons.check_circle_outline, color: Colors.white, size: 28),
      ),
      messageText: Text(
        'Transaksi berhasil! ($metode)',
        style: const TextStyle(
          fontFamily: 'm',
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Show generic notification
  static void showNotification({
    required String message,
    Color color = AppColors.navy,
    IconData icon = Icons.info_outline,
  }) {
    Get.rawSnackbar(
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      backgroundColor: color,
      duration: const Duration(seconds: 3),
      icon: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          fontFamily: 'm',
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }
}
