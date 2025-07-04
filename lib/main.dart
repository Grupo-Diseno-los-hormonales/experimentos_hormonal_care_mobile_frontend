import 'package:flutter/material.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/iam/presentation/pages/sign_in.dart';
import 'package:intl/date_symbol_data_local.dart'; // Importa el paquete para la localización
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa la configuración de la localización
  await initializeDateFormatting('es_ES', null);

  // Ejecuta la aplicación
  runApp(MyApp());
}