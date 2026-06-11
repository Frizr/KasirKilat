import 'dart:ui';

import 'package:cashier/controller/barangcontroller.dart';
import 'package:cashier/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddBaranG extends StatefulWidget {
  @override
  _AddBaranGState createState() => _AddBaranGState();
}

class _AddBaranGState extends State<AddBaranG> {
  TextEditingController nama = TextEditingController();
  TextEditingController harga = TextEditingController();
  TextEditingController jumlah = TextEditingController();
  TextEditingController modal = TextEditingController();
  Getbarang b = Get.find<Getbarang>();

  Widget _inputField({
    required String label,
    required String hint,
    required TextEditingController c,
    required TextInputType tp,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.bgLight,
            border: Border.all(color: AppColors.navy.withOpacity(0.08)),
          ),
          child: TextField(
            keyboardType: tp,
            onChanged: (value) {
              setState(() {});
            },
            cursorColor: AppColors.navy,
            style: const TextStyle(fontSize: 14),
            controller: c,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
              border: InputBorder.none,
              icon: Icon(icon, color: AppColors.navy, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  bool get _isValid =>
      nama.text.isNotEmpty && harga.text.isNotEmpty && jumlah.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        margin: const EdgeInsets.only(top: 80),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_business_rounded,
                        color: AppColors.teal, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Tambah Produk',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _inputField(
                label: 'Nama Produk',
                hint: 'Contoh: Gula Pasir 1kg',
                c: nama,
                tp: TextInputType.text,
                icon: Icons.label_outline_rounded,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _inputField(
                      label: 'Harga Jual',
                      hint: '0',
                      c: harga,
                      tp: TextInputType.number,
                      icon: Icons.sell_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _inputField(
                      label: 'Modal',
                      hint: '0',
                      c: modal,
                      tp: TextInputType.number,
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _inputField(
                label: 'Jumlah Stok',
                hint: '0',
                c: jumlah,
                tp: TextInputType.number,
                icon: Icons.inventory_2_outlined,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isValid
                      ? () {
                          b.addbarang(
                            bar: '',
                            nama: nama.text,
                            harga: int.tryParse(harga.text) ?? 0,
                            jumlah: int.tryParse(jumlah.text) ?? 0,
                            modal: int.tryParse(modal.text) ?? 0,
                          );
                          if (Get.isBottomSheetOpen == true) Get.back();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isValid ? AppColors.teal : Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: _isValid ? 2 : 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.save_rounded,
                        color: _isValid ? Colors.white : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Simpan Produk',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: _isValid ? Colors.white : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
