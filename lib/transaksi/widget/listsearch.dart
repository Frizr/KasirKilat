import 'dart:ui';

import 'package:cashier/controller/barangcontroller.dart';
import 'package:cashier/manage/formater.dart';
import 'package:cashier/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ListSearch extends StatefulWidget {
  final String id;
  final String kode;
  final String nama;
  final int harga;
  final int stock;
  final bool x;
  final int i;
  final int? jumbel;
  ListSearch(
      {required this.id,
      required this.kode,
      required this.nama,
      required this.harga,
      required this.stock,
      required this.x,
      required this.i,
      this.jumbel});
  @override
  _ListSearchState createState() => _ListSearchState();
}

class _ListSearchState extends State<ListSearch> {
  final Getbarang b = Get.put(Getbarang());
  TextEditingController jumbel = TextEditingController();

  Widget by() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.nama,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              uang.format(widget.harga),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.bgLight,
                border: Border.all(color: AppColors.teal.withOpacity(0.3)),
              ),
              child: TextField(
                keyboardType: TextInputType.number,
                autofocus: true,
                onChanged: (value) {
                  setState(() {});
                },
                cursorColor: AppColors.navy,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                controller: jumbel,
                decoration: InputDecoration(
                  suffixIcon: InkWell(
                    onTap: () {
                      if (Get.isBottomSheetOpen == true) Get.back();
                      b.addbeli(
                        id: widget.id,
                        kode: widget.kode,
                        nama: widget.nama,
                        harga: widget.harga,
                        jumlah: widget.stock,
                        jumlahbeli: int.tryParse(jumbel.text) ?? 0,
                        tot: widget.harga * (int.tryParse(jumbel.text) ?? 0),
                      );
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.teal,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 20),
                    ),
                  ),
                  hintText: 'Jumlah barang',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.navy.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.inventory_2_outlined,
                color: AppColors.navy, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  uang.format(widget.harga),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              widget.x
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'x${widget.jumbel}',
                        style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  : jumbel.text.isNotEmpty
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.navy,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            jumbel.text,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.white),
                          ),
                        )
                      : const SizedBox.shrink(),
              const SizedBox(width: 10),
              InkWell(
                onTap: () {
                  if (widget.x) {
                    b.hapusbeli(i: widget.i);
                  } else {
                    FocusScope.of(context).requestFocus(FocusNode());
                    Get.bottomSheet(by());
                  }
                },
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: widget.x
                        ? AppColors.danger.withOpacity(0.1)
                        : AppColors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    widget.x ? Icons.close_rounded : Icons.add_rounded,
                    color: widget.x ? AppColors.danger : AppColors.teal,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
