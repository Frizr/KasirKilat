import 'dart:ui';

import 'package:cashier/controller/barangcontroller.dart';
import 'package:cashier/manage/listfilter.dart';
import 'package:cashier/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Filte extends StatefulWidget {
  @override
  _FilteState createState() => _FilteState();
}

class _FilteState extends State<Filte> {
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filter Produk',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var a in filters)
                  GetBuilder<Getbarang>(
                    init: Getbarang(),
                    builder: (b) {
                      bool isSelected = b.sortOptionBarang == a;
                      return InkWell(
                        onTap: () {
                          b.setSortOptionBarang(a);
                          Get.back();
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.navy : AppColors.navy.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            a,
                            style: TextStyle(
                              fontSize: 13,
                              color: isSelected ? Colors.white : AppColors.navy,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
