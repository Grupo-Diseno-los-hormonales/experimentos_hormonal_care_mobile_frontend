import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/providers/theme_provider.dart';

// Provider global para el idioma
class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en', '');
  
  Locale get locale => _locale;
  
  void changeLanguage(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}

// Instancia global del provider
final LanguageProvider languageProvider = LanguageProvider();

class LanguageSwitcherApp extends StatefulWidget {
  final Widget child;

  const LanguageSwitcherApp({Key? key, required this.child}) : super(key: key);

  @override
  _LanguageSwitcherAppState createState() => _LanguageSwitcherAppState();
}

class _LanguageSwitcherAppState extends State<LanguageSwitcherApp> {
  @override
  void initState() {
    super.initState();
    languageProvider.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    languageProvider.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Hormonal Care',
          theme: _lightTheme,
          darkTheme: _darkTheme,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English
            Locale('es', ''), // Spanish
          ],
          locale: languageProvider.locale,
          home: widget.child,
        );
      },
    );
  }

  ThemeData get _lightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: Color(0xFFA78AAB),
    dialogBackgroundColor: Color(0xFFAEBBC3),
    scaffoldBackgroundColor: Color(0xFFF5F5F5),
    cardColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFFA78AAB),
      foregroundColor: Colors.white,
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(color: Colors.black87),
    ),
  );

  ThemeData get _darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: Color(0xFF8F7193),
    dialogBackgroundColor: Color(0xFF2D2D2D),
    scaffoldBackgroundColor: Color(0xFF1E1E1E),
    cardColor: Color(0xFF2D2D2D),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF8F7193),
      foregroundColor: Colors.white,
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
    ),
    iconTheme: IconThemeData(color: Colors.white70),
  );
}