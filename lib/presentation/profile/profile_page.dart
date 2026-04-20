import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technical_test/core/theme/theme_controller.dart';
import 'package:technical_test/data/datasources/remote/auth_remote_datasource.dart';
import 'package:technical_test/data/repositories/auth_repository_impl.dart';
import 'package:technical_test/presentation/auth/auth_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final themeController = Get.find<ThemeController>();
    final isGuest = user?.isAnonymous ?? true;
    final authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(
            AuthController(AuthRepositoryImpl(AuthRemoteDataSourceImpl())),
            permanent: true,
          );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Akun',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Avatar & Info User ─────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF2C2C2C)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: Theme.of(context).brightness == Brightness.dark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(
                      0xFF6C3EE8,
                    ).withValues(alpha: 0.1),
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? Icon(
                            isGuest ? Icons.person_outline : Icons.person,
                            size: 40,
                            color: const Color(0xFF6C3EE8),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Nama
                  Text(
                    isGuest ? 'Tamu' : (user?.displayName ?? 'Pengguna'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Email
                  Text(
                    isGuest ? 'Login sebagai Tamu' : (user?.email ?? ''),
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 12),

                  // Badge tipe akun
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isGuest
                          ? Colors.orange.withValues(alpha: 0.1)
                          : const Color(0xFF6C3EE8).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isGuest ? 'Akun Tamu' : 'Akun Google',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isGuest
                            ? Colors.orange.shade700
                            : const Color(0xFF6C3EE8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Pengaturan ─────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF2C2C2C)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: Theme.of(context).brightness == Brightness.dark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Column(
                children: [
                  // Toggle Dark/Light Mode
                  Obx(
                    () => _SettingTile(
                      icon: themeController.isDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      iconColor: const Color(0xFF6C3EE8),
                      title: 'Tampilan',
                      subtitle:
                          themeController.isDark ? 'Mode Gelap' : 'Mode Terang',
                      trailing: Switch(
                        value: themeController.isDark,
                        onChanged: (_) => themeController.toggleTheme(),
                        activeColor: const Color(0xFF6C3EE8),
                      ),
                    ),
                  ),

                  _Divider(),

                  // Versi App
                  const _SettingTile(
                    icon: Icons.info_outline,
                    iconColor: Colors.blue,
                    title: 'Versi Aplikasi',
                    subtitle: '1.0.0',
                    trailing: SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Tombol Logout ──────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF2C2C2C)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: Theme.of(context).brightness == Brightness.dark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: _SettingTile(
                icon: Icons.logout,
                iconColor: Colors.red,
                title: 'Logout',
                subtitle: 'Keluar dari aplikasi',
                titleColor: Colors.red,
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.red,
                ),
                onTap: () => _showLogoutDialog(context, authController),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Apakah kamu yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: authController.isLoading.value
                  ? null
                  : () {
                      Get.back();
                      authController.signOut();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: authController.isLoading.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable Setting Tile ──────────────────────────────────────
class _SettingTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: titleColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
      ),
      trailing: trailing,
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 68,
      endIndent: 16,
      color: Colors.grey.shade200,
    );
  }
}
