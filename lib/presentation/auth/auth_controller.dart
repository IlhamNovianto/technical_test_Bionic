import 'package:get/get.dart';
import 'package:technical_test/core/constants/app_routes.dart';
import 'package:technical_test/data/database/app_database.dart';
import 'package:technical_test/data/database/dao/user_dao.dart';
import 'package:technical_test/data/models/user_model.dart';
import 'package:technical_test/data/repositories/auth_repository_impl.dart';

class AuthController extends GetxController {
  final AuthRepositoryImpl _authRepository;

  AuthController(this._authRepository);

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final isLoadingAnn = false.obs;
  final errorMessageAnn = ''.obs;

  // ── Google Sign-In ──────────────────────────────────────────
  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final user = await _authRepository.signInWithGoogle();

      if (user != null) {
        // Simpan user ke SQLite
        await _saveUserToLocal(
          uid: user.uid,
          displayName: user.displayName,
          email: user.email,
          photoUrl: user.photoURL,
          isGuest: false,
        );

        Get.offAllNamed(AppRoutes.news);
      }
    } on Exception catch (e) {
      errorMessage.value = _parseError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ── Guest Login ─────────────────────────────────────────────
  Future<void> signInAsGuest() async {
    isLoadingAnn.value = true;
    errorMessageAnn.value = '';

    try {
      final user = await _authRepository.signInAsGuest();

      if (user != null) {
        // Simpan user guest ke SQLite
        await _saveUserToLocal(
          uid: user.uid,
          displayName: 'Tamu',
          email: null,
          photoUrl: null,
          isGuest: true,
        );

        Get.offAllNamed(AppRoutes.news);
      }
    } on Exception catch (e) {
      errorMessageAnn.value = _parseError(e.toString());
    } finally {
      isLoadingAnn.value = false;
    }
  }

  // ── Sign Out ────────────────────────────────────────────────
  Future<void> signOut() async {
    try {
      // Hapus data lokal saat logout
      await AppDatabase().clearAll();
      await _authRepository.signOut();

      Get.offAllNamed(AppRoutes.login);
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.reset();
      });
    } on Exception catch (e) {
      isLoading.value = false;
      isLoadingAnn.value = false;
      errorMessage.value = _parseError(e.toString());
    }
  }

  // ── Helper: simpan user ke SQLite ───────────────────────────
  Future<void> _saveUserToLocal({
    required String uid,
    String? displayName,
    String? email,
    String? photoUrl,
    required bool isGuest,
  }) async {
    final userModel = UserModel(
      uid: uid,
      displayName: displayName,
      email: email,
      photoUrl: photoUrl,
      isGuest: isGuest,
    );
    await UserDao(AppDatabase()).insertOrUpdate(userModel);
  }

  // ── Helper: parse pesan error Firebase ──────────────────────
  String _parseError(String error) {
    if (error.contains('network')) return 'Tidak ada koneksi internet.';
    if (error.contains('account-exists')) {
      return 'Akun sudah terdaftar dengan metode login lain.';
    }
    if (error.contains('cancelled') || error.contains('canceled')) {
      return 'Login dibatalkan.';
    }
    if (error.contains('sign_in_failed')) {
      return 'Google Sign-In gagal. Coba lagi.';
    }
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }
}
