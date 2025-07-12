import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MedicalRecordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFA788AB),
        title: Text(AppLocalizations.of(context)?.medicalRecordButton ?? 'Historial Médico'),
      ),
      body: Center(
        child: Text('Pantalla de Historial Médico'),
      ),
    );
  }
}
