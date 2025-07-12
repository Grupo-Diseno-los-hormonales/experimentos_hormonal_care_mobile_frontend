import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/widgets/language_switcher_app.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/iam/presentation/pages/sign_in.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/app.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: LanguageSwitcherApp(child: SignIn()),
    ),
  );
}