import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static const _key = 'theme_mode';

  // Default ikut sistem
  final _themeMode = ThemeMode.system.obs;
  ThemeMode get themeMode => _themeMode.value;

  // Cek apakah dark mode aktif
  bool get isDark {
    if (_themeMode.value == ThemeMode.system) {
      return Get.isPlatformDarkMode;
    }
    return _themeMode.value == ThemeMode.dark;
  }

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  // Load tema dari SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key) ?? 'system';
    _themeMode.value = _fromString(saved);
    Get.changeThemeMode(_themeMode.value);
  }

  // Toggle light ↔ dark
  Future<void> toggleTheme() async {
    if (isDark) {
      await setTheme(ThemeMode.light);
    } else {
      await setTheme(ThemeMode.dark);
    }
  }

  // Set tema
  Future<void> setTheme(ThemeMode mode) async {
    _themeMode.value = mode;
    Get.changeThemeMode(mode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _toString(mode));
  }

  String _toString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  ThemeMode _fromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
