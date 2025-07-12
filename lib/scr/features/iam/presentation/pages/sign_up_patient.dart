import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/iam/domain/services/patient_signup_service.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/presentation/widgets/puzzle_captcha_dialog.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/providers/theme_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignUpPatient extends StatefulWidget {
  @override
  _SignUpPatientState createState() => _SignUpPatientState();
}

class _SignUpPatientState extends State<SignUpPatient> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _typeOfBloodController = TextEditingController();
  final TextEditingController _doctorIdController = TextEditingController();
  String _image = '';
  String? _gender;
  bool _captchaVerified = false;
  bool _termsAccepted = false;

  void _showTermsDialog() async {
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Dialog(
            backgroundColor: Theme.of(context).dialogBackgroundColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              padding: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxHeight: 500, maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)!.termsAndConditionsTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        '''HormonalCare 2025 5.2.4 Acuerdo de Servicio - SaaS

El presente Acuerdo de Servicio (el "Acuerdo") establece los términos y condiciones bajo los cuales los usuarios podrán acceder y utilizar la plataforma HormonalCare como parte del servicio SaaS (Software as a Service) proporcionado por Los Hormonales. Este Acuerdo es aplicable a todos los usuarios que utilicen el servicio, ya sea de manera gratuita o mediante suscripción.

1. Definiciones
"Plataforma": Se refiere al servicio en línea proporcionado por Los Hormonales para la gestión de enfermedades hormonales, disponible a través de la web y la aplicación móvil HormonalCare.
"Usuario": Cualquier persona que acceda a la plataforma HormonalCare para utilizar los servicios ofrecidos.
"Servicios": Los servicios proporcionados por la plataforma HormonalCare, incluyendo acceso a consultas médicas, seguimiento de tratamientos, gestión de citas médicas, entre otros.

2. Derechos y Obligaciones del Usuario
El usuario tiene el derecho de utilizar la plataforma HormonalCare de acuerdo con las funcionalidades proporcionadas.
El usuario es responsable de proporcionar información precisa y actualizada al registrarse y utilizar el servicio.
El usuario se compromete a utilizar la plataforma únicamente para fines legales y en conformidad con los términos del presente Acuerdo.
El usuario deberá cumplir con las políticas de privacidad y seguridad aplicables, protegiendo su cuenta de acceso.

3. Licencia de Uso
Los Hormonales concede al usuario una licencia no exclusiva, intransferible y limitada para acceder y utilizar la plataforma HormonalCare durante el período de validez del servicio contratado.

4. Obligaciones de Los Hormonales
Los Hormonales se comprometen a garantizar la disponibilidad y accesibilidad del servicio, sujeto a mantenimiento programado y circunstancias fuera de su control.
Los Hormonales garantizan que los datos del usuario serán tratados conforme a su Política de Privacidad y las normativas aplicables en materia de protección de datos.

5. Limitaciones de Responsabilidad
Los Hormonales no serán responsables por daños directos, indirectos, incidentales, especiales o consecuentes derivados del uso o la imposibilidad de uso de la plataforma HormonalCare, incluyendo, pero no limitado a, la pérdida de datos o interrupciones en el servicio.

6. Suspensión o Terminación de Servicios
Los Hormonales se reservan el derecho de suspender o terminar el acceso de un usuario a la plataforma HormonalCare en caso de violaciones de este Acuerdo, incluyendo el uso inapropiado de la plataforma, o el incumplimiento de las políticas establecidas.
El usuario puede cancelar su cuenta en cualquier momento, sujeto a los términos de cancelación aplicables.

7. Confidencialidad
Ambas partes se comprometen a mantener la confidencialidad de cualquier información confidencial intercambiada durante la duración del Acuerdo, y a no divulgar dicha información sin el consentimiento expreso de la otra parte, excepto cuando lo exija la ley.

8. Modificaciones del Acuerdo
Los Hormonales se reservan el derecho de modificar este Acuerdo en cualquier momento. Las modificaciones se publicarán en la sección de "Términos y Condiciones" de la plataforma HormonalCare, y el usuario será notificado de las actualizaciones.

9. Cumplimiento Normativo
El uso de la plataforma HormonalCare debe cumplir con todas las leyes y regulaciones aplicables, incluidas aquellas relacionadas con la protección de datos personales, propiedad intelectual y otros derechos de propiedad.

10. Resolución de Conflictos
En caso de controversias derivadas del uso de la plataforma HormonalCare, ambas partes acuerdan resolver los conflictos mediante un proceso de mediación antes de recurrir a procedimientos legales.

11. Vigencia
Este Acuerdo entrará en vigencia desde el momento en que el usuario acceda por primera vez a la plataforma HormonalCare y continuará en vigor hasta que sea terminado por cualquiera de las partes, conforme a las disposiciones del Acuerdo.''',
                        style: TextStyle(
                          fontSize: 12,
                          color: themeProvider.isDarkMode 
                              ? Colors.white70
                              : Colors.grey[700],
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(AppLocalizations.of(context)!.acceptTermsButton),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      AppLocalizations.of(context)!.rejectTermsButton,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    if (accepted == true) {
      setState(() {
        _termsAccepted = true;
      });
    }
  }
  
  Future<void> _verifyCaptcha() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => PuzzleCaptchaDialog(),
    );
    if (result == true) {
      setState(() {
        _captchaVerified = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.captchaVerifiedSuccess),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_captchaVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseVerifyCaptcha)),
      );
      return;
    }
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.mustAcceptTermsAndConditions)),
      );
      return;
    }

    try {
      await PatientSignUpService.signUpPatient(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _gender ?? '',
        _phoneNumberController.text.trim(),
        _image,
        _birthdayController.text.trim(),
        _typeOfBloodController.text.trim(),
        int.parse(_doctorIdController.text.trim()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.registrationSuccessful),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.registrationErrorPrefix}$e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: themeProvider.isDarkMode 
                    ? [
                        Color(0xFF1E1E1E),
                        Color(0xFF2D2D2D),
                        Color(0xFF1E1E1E),
                      ]
                    : [
                        Color(0xFFE5DDE6),
                        Color(0xFFF3EAF7),
                        Color(0xFFE2D1F4),
                      ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // Header con logo y título
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 30),
                      child: Column(
                        children: [
                          // Logo
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFA788AB),
                                  Color(0xFF8F7193),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF8F7193).withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.person_add,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            AppLocalizations.of(context)!.patientRegistrationTitle,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.createAccountDescription,
                            style: TextStyle(
                              fontSize: 16,
                              color: themeProvider.isDarkMode 
                                  ? Colors.white70 
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Formulario en Card
                    Container(
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode 
                            ? Color(0xFF2D2D2D).withOpacity(0.9)
                            : Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(28),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // First Name
                            _buildTextField(
                              controller: _firstNameController,
                              label: AppLocalizations.of(context)!.firstNameLabel,
                              hint: AppLocalizations.of(context)!.enterFirstNameHint,
                              icon: Icons.person_outline,
                              validator: (value) => value?.isEmpty ?? true ? AppLocalizations.of(context)!.pleaseEnterFirstName : null,
                              themeProvider: themeProvider,
                            ),
                            const SizedBox(height: 20),

                            // Last Name
                            _buildTextField(
                              controller: _lastNameController,
                              label: AppLocalizations.of(context)!.lastNameLabel,
                              hint: AppLocalizations.of(context)!.enterLastNameHint,
                              icon: Icons.person_outline,
                              validator: (value) => value?.isEmpty ?? true ? AppLocalizations.of(context)!.pleaseEnterLastName : null,
                              themeProvider: themeProvider,
                            ),
                            const SizedBox(height: 20),

                            // Username (en lugar de email)
                            _buildTextField(
                              controller: _usernameController,
                              label: AppLocalizations.of(context)!.usernameLabel,
                              hint: AppLocalizations.of(context)!.enterUsernameHint,
                              icon: Icons.account_circle_outlined,
                              validator: (value) {
                                if (value?.isEmpty ?? true) return AppLocalizations.of(context)!.pleaseEnterUsername;
                                if (value!.length < 3) return AppLocalizations.of(context)!.usernameMinLength;
                                if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                                  return AppLocalizations.of(context)!.usernameInvalidChars;
                                }
                                return null;
                              },
                              themeProvider: themeProvider,
                            ),
                            const SizedBox(height: 20),

                            // Password
                            _buildTextField(
                              controller: _passwordController,
                              label: AppLocalizations.of(context)!.passwordLabel,
                              hint: AppLocalizations.of(context)!.enterPasswordHint,
                              icon: Icons.lock_outline,
                              obscureText: true,
                              validator: (value) {
                                if (value?.isEmpty ?? true) return AppLocalizations.of(context)!.pleaseEnterPassword;
                                if (value!.length < 6) return AppLocalizations.of(context)!.passwordMinLength;
                                return null;
                              },
                              themeProvider: themeProvider,
                            ),
                            const SizedBox(height: 20),

                            // Phone Number
                            _buildTextField(
                              controller: _phoneNumberController,
                              label: AppLocalizations.of(context)!.phoneNumberLabel,
                              hint: AppLocalizations.of(context)!.enterPhoneNumberHint,
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (value) => value?.isEmpty ?? true ? AppLocalizations.of(context)!.pleaseEnterPhoneNumber : null,
                              themeProvider: themeProvider,
                            ),
                            const SizedBox(height: 20),

                            // Gender
                            _buildGenderDropdown(themeProvider),
                            const SizedBox(height: 20),

                            // Birthday
                            _buildBirthdayField(themeProvider),
                            const SizedBox(height: 20),

                            // Blood Type
                            _buildTextField(
                              controller: _typeOfBloodController,
                              label: AppLocalizations.of(context)!.bloodTypeLabel,
                              hint: AppLocalizations.of(context)!.enterBloodTypeHint,
                              icon: Icons.bloodtype_outlined,
                              validator: (value) => value?.isEmpty ?? true ? AppLocalizations.of(context)!.pleaseEnterBloodType : null,
                              themeProvider: themeProvider,
                            ),
                            const SizedBox(height: 20),

                            // Doctor ID
                            _buildTextField(
                              controller: _doctorIdController,
                              label: AppLocalizations.of(context)!.doctorIdLabel,
                              hint: AppLocalizations.of(context)!.enterDoctorIdHint,
                              icon: Icons.medical_services_outlined,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: (value) {
                                if (value?.isEmpty ?? true) return AppLocalizations.of(context)!.pleaseEnterDoctorId;
                                final id = int.tryParse(value!);
                                if (id == null || id < 1 || id > 10) {
                                  return AppLocalizations.of(context)!.doctorIdRangeError;
                                }
                                return null;
                              },
                              themeProvider: themeProvider,
                            ),
                            const SizedBox(height: 30),

                            // CAPTCHA Section
                            _buildCaptchaSection(themeProvider),
                            const SizedBox(height: 20),

                            // Terms and Conditions
                            _buildTermsSection(themeProvider),
                            const SizedBox(height: 30),

                            // Register Button
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF8F7193), Color(0xFFA788AB)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF8F7193).withOpacity(0.4),
                                    blurRadius: 15,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: _submit,
                                  child: Center(
                                    child: Text(
                                      AppLocalizations.of(context)!.registerPatientButton,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Back to Login
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                AppLocalizations.of(context)!.alreadyHaveAccountSignIn,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    required ThemeProvider themeProvider,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              icon,
              color: Color(0xFF8F7193),
            ),
            hintStyle: TextStyle(
              color: themeProvider.isDarkMode 
                  ? Colors.white54 
                  : Colors.black54,
            ),
            filled: true,
            fillColor: themeProvider.isDarkMode 
                ? Color(0xFF4A4A4A) 
                : Color(0xFFF8F4F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Color(0xFF8F7193),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildGenderDropdown(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.genderLabel,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode 
                ? Color(0xFF4A4A4A) 
                : Color(0xFFF8F4F9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonFormField<String>(
            value: _gender,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.selectGenderHint,
              prefixIcon: Icon(
                Icons.person_outline,
                color: Color(0xFF8F7193),
              ),
              hintStyle: TextStyle(
                color: themeProvider.isDarkMode 
                    ? Colors.white54 
                    : Colors.black54,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            dropdownColor: themeProvider.isDarkMode 
                ? Color(0xFF4A4A4A) 
                : Colors.white,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            items: [
              AppLocalizations.of(context)!.maleGender,
              AppLocalizations.of(context)!.femaleGender,
              AppLocalizations.of(context)!.otherGender
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) => setState(() => _gender = value),
            validator: (value) => value == null ? AppLocalizations.of(context)!.pleaseSelectGender : null,
          ),
        ),
      ],
    );
  }

  Widget _buildBirthdayField(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.birthdayLabel,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: Theme.of(context).primaryColor,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() {
                _birthdayController.text = "${picked.toLocal()}".split(' ')[0];
              });
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              controller: _birthdayController,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.selectBirthdayHint,
                prefixIcon: Icon(
                  Icons.calendar_today,
                  color: Color(0xFF8F7193),
                ),
                hintStyle: TextStyle(
                  color: themeProvider.isDarkMode 
                      ? Colors.white54 
                      : Colors.black54,
                ),
                filled: true,
                fillColor: themeProvider.isDarkMode 
                    ? Color(0xFF4A4A4A) 
                    : Color(0xFFF8F4F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Color(0xFF8F7193),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              validator: (value) => value?.isEmpty ?? true ? AppLocalizations.of(context)!.pleaseSelectBirthday : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCaptchaSection(ThemeProvider themeProvider) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _captchaVerified ? Colors.green : Theme.of(context).primaryColor,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _captchaVerified ? Icons.check_circle : Icons.security,
            color: _captchaVerified ? Colors.green : Theme.of(context).primaryColor,
            size: 28,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              _captchaVerified ? AppLocalizations.of(context)!.captchaVerifiedStatus : AppLocalizations.of(context)!.verifyYouAreHuman,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          if (!_captchaVerified)
            ElevatedButton(
              onPressed: _verifyCaptcha,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(AppLocalizations.of(context)!.verifyButton),
            ),
        ],
      ),
    );
  }

  Widget _buildTermsSection(ThemeProvider themeProvider) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _termsAccepted ? Colors.green : Theme.of(context).primaryColor,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: _termsAccepted,
            onChanged: (value) => setState(() => _termsAccepted = value ?? false),
            activeColor: Theme.of(context).primaryColor,
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                children: [
                  TextSpan(text: AppLocalizations.of(context)!.iAcceptThe),
                  TextSpan(
                    text: AppLocalizations.of(context)!.termsAndConditions,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = _showTermsDialog,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}