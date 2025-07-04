import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'dark_mode_global';
  
  static Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }
  
  static Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }
  
  static Future<void> toggleTheme() async {
    final currentMode = await isDarkMode();
    await setDarkMode(!currentMode);
  }

  static Future<void> clearTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_themeKey);
  }
}