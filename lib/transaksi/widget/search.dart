import 'package:cashier/controller/barangcontroller.dart';
import 'package:cashier/transaksi/widget/listsearch.dart';
import 'package:cashier/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  Getbarang b = Get.put(Getbarang());
  TextEditingController barang = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          b.temu.clear();
          Get.back();
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
          backgroundColor: AppColors.bgLight,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: true,
            iconTheme: const IconThemeData(color: AppColors.navy),
            title: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navy.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    b.cari(cari: value);
                  });
                },
                cursorColor: AppColors.navy,
                style: const TextStyle(fontSize: 14),
                controller: barang,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Cari barang...',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                ),
              ),
            ),
          ),
          body: SizedBox.expand(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  GetBuilder<Getbarang>(
                    init: Getbarang(),
                    builder: (val) {
                      if (val.temu.isEmpty && barang.text.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 48,
                                color: AppColors.textSecondary.withOpacity(0.3),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Barang tidak ditemukan',
                                style: TextStyle(
                                  color: AppColors.textSecondary.withOpacity(0.5),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return Column(
                        children: [
                          for (var a in val.temu)
                            ListSearch(
                              kode: (a['data'] != null &&
                                      (a['data']['bar'] ?? '') != null)
                                  ? (a['data']['bar'] ?? '').toString()
                                  : (a['bar'] ?? '').toString(),
                              id: (a['id'] ?? '').toString(),
                              nama: (a['data'] != null &&
                                      (a['data']['nama'] ?? '') != null)
                                  ? (a['data']['nama'] ?? '').toString()
                                  : '',
                              harga: (a['data'] != null &&
                                      a['data']['harga'] != null)
                                  ? (a['data']['harga'] as num).toInt()
                                  : 0,
                              stock: (a['data'] != null &&
                                      a['data']['jumlah'] != null)
                                  ? (a['data']['jumlah'] as num).toInt()
                                  : 0,
                              x: false,
                              i: 0,
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
