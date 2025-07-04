import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/providers/theme_provider.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/presentation/pages/home_screen_patient.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/presentation/pages/home_screen.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/iam/presentation/pages/sign_in.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Hormonal Care',
          theme: themeProvider.isDarkMode ? _darkTheme : _lightTheme,
          home: SignIn(),
          debugShowCheckedModeBanner: false,
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