import 'package:flutter/material.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/data/theme_service.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _isDarkMode = await ThemeService.isDarkMode();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    await ThemeService.toggleTheme();
    _isDarkMode = await ThemeService.isDarkMode();
    notifyListeners();
  }

  Future<void> setTheme(bool isDark) async {
    await ThemeService.setDarkMode(isDark);
    _isDarkMode = isDark;
    notifyListeners();
  }

  Future<void> clearTheme() async {
    await ThemeService.clearTheme();
    _isDarkMode = false;
    notifyListeners();
  }
}