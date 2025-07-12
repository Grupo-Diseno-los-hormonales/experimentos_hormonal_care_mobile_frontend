// select_user_type.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/iam/presentation/pages/sign_up_doctor.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/iam/presentation/pages/sign_up_patient.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/core/utils/usecases/jwt_storage.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/providers/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SelectUserType extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text(
              AppLocalizations.of(context)?.selectUserType ?? 'Select Your User Type',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tarjeta para Patient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: themeProvider.isDarkMode
                            ? Colors.black.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person,
                        size: 60,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)?.patient ?? 'Patient',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)?.registerAsAPatientForAccess ?? 'Register as a patient to access medical services',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.isDarkMode
                              ? Colors.white70
                              : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignUpPatient()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(AppLocalizations.of(context)?.registerAsAPatient ?? 'Register as Patient'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Tarjeta para Doctor
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: themeProvider.isDarkMode
                            ? Colors.black.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.medical_services,
                        size: 60,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)?.doctorText ?? 'Doctor',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)?.registerAsADoctorForAccess ?? 'Register as a doctor to provide medical services',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.isDarkMode
                              ? Colors.white70
                              : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignUpDoctor()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(AppLocalizations.of(context)?.registerAsADoctor ?? 'Register as Doctor'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}