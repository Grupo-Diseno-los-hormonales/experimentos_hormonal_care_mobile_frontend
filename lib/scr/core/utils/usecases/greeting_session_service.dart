import 'package:shared_preferences/shared_preferences.dart';

class GreetingSessionService {
  static const String _greetingShownKey = 'greeting_shown_today';
  static const String _lastLoginDateKey = 'last_login_date';
  
  // Verificar si ya se mostró el saludo en esta sesión
  static Future<bool> shouldShowGreeting() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0]; // Solo fecha YYYY-MM-DD
    final lastLoginDate = prefs.getString(_lastLoginDateKey);
    final greetingShown = prefs.getBool('${_greetingShownKey}_$today') ?? false;
    
    // Si es un nuevo día o una nueva sesión, mostrar saludo
    if (lastLoginDate != today || !greetingShown) {
      return true;
    }
    
    return false;
  }
  
  // Marcar que el saludo ya se mostró
  static Future<void> markGreetingAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setBool('${_greetingShownKey}_$today', true);
    await prefs.setString(_lastLoginDateKey, today);
  }
  
  // Limpiar al cerrar sesión
  static Future<void> clearGreetingSession() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.remove('${_greetingShownKey}_$today');
    await prefs.remove(_lastLoginDateKey);
  }
  
  // Marcar nueva sesión (llamar al hacer login)
  static Future<void> markNewSession() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString(_lastLoginDateKey, today);
    // No marcar greeting como shown, para que se muestre
    await prefs.remove('${_greetingShownKey}_$today');
  }
}