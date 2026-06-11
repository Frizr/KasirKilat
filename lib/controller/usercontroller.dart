import 'dart:async';

import 'package:cashier/controller/authcontroller.dart';
import 'package:cashier/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  StreamSubscription? _sub;

  // Real-time list of users
  final RxList<Map<String, dynamic>> users = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // User list is admin-only. Start the listener from KelolaUserPage after
    // the logged-in role is known, not during app startup/login.
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  /// Sets up a real-time listener for the 'users' collection
  void fetchUsers() {
    final auth = Get.find<AuthController>();
    if (!auth.isAdmin) {
      debugPrint('[UserController] fetchUsers dibatalkan: bukan admin');
      stopListening();
      return;
    }

    _sub?.cancel();
    isLoading.value = true;
    _sub = _usersCollection
        .orderBy('createdAt', descending: true)
        .snapshots(includeMetadataChanges: true)
        .listen(
      (snap) {
        users.clear();
        for (var doc in snap.docs) {
          final data = doc.data() as Map<String, dynamic>;
          users.add({
            'id': doc.id,
            ...data,
          });
        }
        isLoading.value = false;
      },
      onError: (e) {
        isLoading.value = false;
        debugPrint('[UserController] fetchUsers error: $e');
      },
    );
  }

  void stopListening() {
    _sub?.cancel();
    _sub = null;
    users.clear();
    isLoading.value = false;
  }

  /// Creates a new user if the username is unique
  Future<bool> createUser({
    required String nama,
    required String username,
    required String password,
    required String role,
  }) async {
    if (isLoading.value) return false;
    isLoading.value = true;

    try {
      final normalizedNama = nama.trim();
      final normalizedUsername = username.trim().toLowerCase();
      final normalizedPassword = password.trim();
      final normalizedRole = role.trim().toLowerCase();

      if (normalizedNama.isEmpty ||
          normalizedUsername.isEmpty ||
          normalizedPassword.isEmpty) {
        _showError('Semua kolom harus diisi');
        return false;
      }

      if (normalizedRole != 'admin' && normalizedRole != 'karyawan') {
        _showError('Role tidak valid');
        return false;
      }

      // Check if username already exists
      final query = await _usersCollection
          .where('username', isEqualTo: normalizedUsername)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        _showError('Username sudah digunakan');
        return false;
      }

      await _usersCollection.add({
        'nama': normalizedNama,
        'username': normalizedUsername,
        'password': normalizedPassword,
        'role': normalizedRole,
        'aktif': true,
        'createdAt': Timestamp.now(),
      });

      _showSuccess('Pengguna berhasil ditambahkan');
      return true;
    } catch (e) {
      debugPrint('[UserController] createUser error: $e');
      _showError('Gagal menambahkan pengguna');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Deletes a user document
  Future<void> deleteUser(String docId) async {
    final auth = Get.find<AuthController>();

    // Prevent deleting oneself
    if (auth.currentUser.value?['id'] == docId) {
      _showError('Tidak dapat menghapus akun Anda sendiri yang sedang aktif');
      return;
    }

    try {
      await _usersCollection.doc(docId).delete();
      _showSuccess('Pengguna berhasil dihapus');
    } catch (e) {
      debugPrint('[UserController] deleteUser error: $e');
      _showError('Gagal menghapus pengguna');
    }
  }

  /// Toggles the 'aktif' status of a user
  Future<void> toggleAktif(String docId, bool currentValue) async {
    final auth = Get.find<AuthController>();

    // Prevent disabling oneself
    if (auth.currentUser.value?['id'] == docId) {
      _showError('Tidak dapat menonaktifkan akun Anda sendiri');
      return;
    }

    try {
      await _usersCollection.doc(docId).update({
        'aktif': !currentValue,
      });
      // No success snackbar needed here as the UI switch updates instantly
    } catch (e) {
      debugPrint('[UserController] toggleAktif error: $e');
      _showError('Gagal memperbarui status');
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  void _showError(String message) {
    Get.rawSnackbar(
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      backgroundColor: AppColors.danger,
      duration: const Duration(seconds: 3),
      icon: const Padding(
        padding: EdgeInsets.only(left: 12),
        child: Icon(Icons.error_outline_rounded, color: Colors.white, size: 26),
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

  void _showSuccess(String message) {
    Get.rawSnackbar(
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      backgroundColor: AppColors.success,
      duration: const Duration(seconds: 3),
      icon: const Padding(
        padding: EdgeInsets.only(left: 12),
        child: Icon(Icons.check_circle_outline_rounded,
            color: Colors.white, size: 26),
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
}
