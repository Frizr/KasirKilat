import 'package:cashier/barang/widget/list/contentlist.dart';
import 'package:cashier/barang/widget/list/filte.dart';
import 'package:cashier/controller/barangcontroller.dart';
import 'package:cashier/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ListBarang extends StatefulWidget {
  @override
  _ListBarangState createState() => _ListBarangState();
}

class _ListBarangState extends State<ListBarang> {
  /// Membangun antarmuka yang menampilkan seluruh daftar produk.
  /// Menampilkan judul, tombol filter, dan iterasi data produk menggunakan widget Expa.
  /// Jika daftar produk kosong, akan menampilkan pesan 'Belum ada produk'.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Produk',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Get.bottomSheet(Filte());
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.navy.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.filter_alt_outlined,
                            color: AppColors.navy, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Filter',
                          style: TextStyle(
                            color: AppColors.navy,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          GetBuilder<Getbarang>(
            builder: (val) {
              if (val.displayBarang.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 48,
                          color: AppColors.textSecondary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada produk',
                          style: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  for (var a in val.displayBarang)
                    Expa(
                      kode: (a['data'] != null && a['data']['bar'] != null)
                          ? (a['data']['bar'] ?? '').toString()
                          : (a['bar'] ?? '').toString(),
                      id: (a['id'] ?? '').toString(),
                      nama: (a['data'] != null && a['data']['nama'] != null)
                          ? (a['data']['nama'] ?? '').toString()
                          : '',
                      harga: (a['data'] != null && a['data']['harga'] != null)
                          ? (a['data']['harga'] as num).toInt()
                          : 0,
                      stock: (a['data'] != null && a['data']['jumlah'] != null)
                          ? (a['data']['jumlah'] as num).toInt()
                          : 0,
                      modal: a['data'] != null && a['data'].containsKey('modal')
                          ? (a['data']['modal'] as num).toInt()
                          : 0,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
