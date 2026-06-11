import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  /// The currently logged-in user document (includes an injected `id` key).
  /// null means no user is logged in.
  final Rx<Map<String, dynamic>?> currentUser = Rx(null);

  /// True while a login/logout Firestore call is in progress.
  final RxBool isLoading = false.obs;

  String get role =>
      (currentUser.value?['role'] ?? '').toString().trim().toLowerCase();
  bool get isLoggedIn => currentUser.value != null;
  bool get isAdmin => role == 'admin';
  bool get isKaryawan => role == 'karyawan';
  String get displayName =>
      (currentUser.value?['nama'] ?? '').toString().trim();

  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');

  /// Queries Firestore by username, then compares the demo plaintext password.
  Future<void> login(String username, String password) async {
    if (isLoading.value) return;

    final normalizedUsername = username.trim().toLowerCase();
    final normalizedPassword = password.trim();

    if (normalizedUsername.isEmpty || normalizedPassword.isEmpty) {
      _showError('Username dan password tidak boleh kosong');
      return;
    }

    isLoading.value = true;
    try {
      _debugAuth('Mencoba login username=$normalizedUsername');

      final QuerySnapshot snap = await _users
          .where('username', isEqualTo: normalizedUsername)
          .limit(2)
          .get()
          .timeout(const Duration(seconds: 15));

      if (snap.docs.isEmpty) {
        _debugAuth('Login gagal: username tidak ditemukan');
        _showError('Username tidak ditemukan');
        return;
      }

      if (snap.docs.length > 1) {
        _debugAuth(
          'Peringatan: ditemukan ${snap.docs.length} dokumen untuk username yang sama',
        );
      }

      final doc = snap.docs.first;
      final rawData = doc.data();
      if (rawData is! Map<String, dynamic>) {
        _debugAuth('Login gagal: format dokumen users/${doc.id} tidak valid');
        _showError('Data akun tidak valid. Hubungi admin.');
        return;
      }

      final data = Map<String, dynamic>.from(rawData);
      final isActive = data['aktif'] == true;
      final storedPassword = (data['password'] ?? '').toString().trim();
      final normalizedRole =
          (data['role'] ?? '').toString().trim().toLowerCase();

      if (!isActive) {
        _debugAuth('Login gagal: akun nonaktif');
        _showError('Akun dinonaktifkan');
        return;
      }

      if (storedPassword != normalizedPassword) {
        _debugAuth('Login gagal: password salah');
        _showError('Password salah');
        return;
      }

      if (normalizedRole != 'admin' && normalizedRole != 'karyawan') {
        _debugAuth('Login gagal: role tidak valid ($normalizedRole)');
        _showError('Role akun tidak valid. Hubungi admin.');
        return;
      }

      currentUser.value = {
        ...data,
        'id': doc.id,
        'username': normalizedUsername,
        'role': normalizedRole,
      };

      _debugAuth('Login berhasil: $normalizedUsername ($normalizedRole)');
      Get.offAllNamed('/main');
    } on FirebaseException catch (e) {
      _debugAuth(
        'FirebaseException saat login: code=${e.code}, message=${e.message}',
      );
      _showError(_firebaseLoginMessage(e));
    } on TimeoutException catch (e) {
      _debugAuth('Timeout saat login: $e');
      _showError('Koneksi ke Firestore timeout. Coba lagi.');
    } catch (e, stack) {
      _debugAuth('Unexpected login error: $e');
      if (kDebugMode) {
        debugPrint(stack.toString());
      }
      _showError(
        kDebugMode
            ? 'Login gagal: ${e.runtimeType}'
            : 'Terjadi kesalahan saat login. Coba lagi.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Clears the current session and sends the user back to LoginPage.
  Future<void> logout() async {
    currentUser.value = null;
    _debugAuth('Logout berhasil');
    Get.offAllNamed('/login');
  }

  String _firebaseLoginMessage(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return kDebugMode
            ? 'Akses Firestore ditolak. Periksa rules collection users. (${e.code})'
            : 'Akses login ditolak. Hubungi admin.';
      case 'unavailable':
      case 'deadline-exceeded':
        return 'Koneksi ke Firestore bermasalah. Periksa internet lalu coba lagi.';
      case 'failed-precondition':
        return kDebugMode
            ? 'Query Firestore belum siap atau butuh index. (${e.code})'
            : 'Konfigurasi database belum siap. Hubungi admin.';
      case 'not-found':
        return kDebugMode
            ? 'Project/collection Firestore tidak ditemukan. (${e.code})'
            : 'Database tidak ditemukan. Hubungi admin.';
      default:
        return kDebugMode
            ? 'Login gagal: ${e.message ?? e.code} (${e.code})'
            : 'Terjadi kesalahan saat login. Coba lagi.';
    }
  }

  void _debugAuth(String message) {
    if (kDebugMode) {
      debugPrint('[AuthController] $message');
    }
  }

  void _showError(String message) {
    Get.rawSnackbar(
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      backgroundColor: const Color(0xFFEF4444),
      duration: const Duration(seconds: 4),
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
}
