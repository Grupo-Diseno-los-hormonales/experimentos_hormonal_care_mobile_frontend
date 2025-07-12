import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/iam/domain/services/auth_service.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/presentation/pages/home_screen.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/presentation/pages/home_screen_patient.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/iam/presentation/pages/select_user_type.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/admin/presentation/pages/admin_tools.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/presentation/widgets/puzzle_captcha_dialog.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/providers/theme_provider.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/widgets/language_button.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController(); // ← CORREGIDO: usernameController
  final TextEditingController _passwordController = TextEditingController();
  bool _captchaVerified = false;
  bool _obscureText = true;
  final _authService = AuthService();
  
  // Controladores de animación
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Inicializar controladores de animación
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Configurar animaciones
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.bounceOut,
    ));
    
    // Iniciar animaciones
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _usernameController.dispose(); // ← CORREGIDO
    _passwordController.dispose();
    super.dispose();
  }

  void _verifyCaptcha() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PuzzleCaptchaDialog(),
    );
    if (result == true) {
      setState(() {
        _captchaVerified = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          duration: const Duration(seconds: 2),
          content: Row(
            children: [
              const Icon(Icons.verified, color: Colors.white, size: 28),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  '¡CAPTCHA verificado!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      setState(() {
        _captchaVerified = false;
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _captchaVerified) {
      // ✅ CORREGIDO: Usar username directamente
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      // Verifica si es el administrador
      if (username == 'admin' && password == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminToolsScreen()),
        );
        return;
      }

      // Lógica para usuarios normales
      try {
        final token = await _authService.signIn(username, password); // ← FUNCIONA CON USERNAME
        if (token != null) {
          final role = await _authService.getRole();
          if (role == 'ROLE_PATIENT') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreenPatient()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)?.invalidCredentialsMessage ?? 'Invalid credentials')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else if (!_captchaVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.pleaseVerifyCaptchaMessage ?? 'Please verify the CAPTCHA')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
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
            child: Stack(
              children: [
                // Elementos decorativos animados
                Positioned(
                  top: -50,
                  right: -50,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: themeProvider.isDarkMode 
                            ? Color(0xFF4A4A4A).withOpacity(0.1)
                            : Color(0xFFA788AB).withOpacity(0.1),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -100,
                  left: -100,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: themeProvider.isDarkMode 
                            ? Color(0xFF8F7193).withOpacity(0.05)
                            : Color(0xFF8F7193).withOpacity(0.1),
                      ),
                    ),
                  ),
                ),
                
                // Contenido principal
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
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
                            padding: const EdgeInsets.all(32),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Logo original con animación
                                  TweenAnimationBuilder(
                                    duration: const Duration(milliseconds: 1000),
                                    tween: Tween<double>(begin: 0, end: 1),
                                    builder: (context, double value, child) {
                                      return Transform.scale(
                                        scale: value,
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(0xFF8F7193).withOpacity(0.3),
                                                blurRadius: 20,
                                                offset: Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: Image.asset(
                                            'assets/images/newlogohormonalcare.png',
                                            height: 120,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  // Título con animación
                                  TweenAnimationBuilder(
                                    duration: const Duration(milliseconds: 1500),
                                    tween: Tween<double>(begin: 0, end: 1),
                                    builder: (context, double value, child) {
                                      return Opacity(
                                        opacity: value,
                                        child: Text(
                                          AppLocalizations.of(context)?.welcomeMessage ?? 'Welcome to HormonalCare',
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: themeProvider.isDarkMode 
                                                ? Colors.white 
                                                : Color(0xFF4B006E),
                                            letterSpacing: 1.2,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    AppLocalizations.of(context)?.continueText ?? "Sign in to continue",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: themeProvider.isDarkMode 
                                          ? Colors.white70 
                                          : Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  
                                  // ✅ CORREGIDO: Campo de USERNAME
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    child: TextFormField(
                                      controller: _usernameController, // ← CORREGIDO
                                      keyboardType: TextInputType.text, // ← CORREGIDO: text, no email
                                      style: TextStyle(
                                        color: themeProvider.isDarkMode 
                                            ? Colors.white 
                                            : Colors.black87,
                                        fontSize: 16,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: AppLocalizations.of(context)?.labelUsername ?? 'Username', // ← CORREGIDO: Username
                                        hintText: AppLocalizations.of(context)?.enterUsernameHint ?? 'Enter your username',
                                        prefixIcon: Icon(
                                          Icons.person_outline, // ← CORREGIDO: icono de persona
                                          color: Color(0xFF8F7193),
                                        ),
                                        labelStyle: TextStyle(
                                          color: themeProvider.isDarkMode 
                                              ? Colors.white70 
                                              : Color(0xFF8F7193),
                                        ),
                                        hintStyle: TextStyle(
                                          color: themeProvider.isDarkMode 
                                              ? Colors.white38 
                                              : Colors.grey[400],
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
                                      validator: (value) {
                                        if (value?.isEmpty ?? true) {
                                          return AppLocalizations.of(context)?.pleaseEnterYourUsername ?? 'Please enter your username'; // ← CORREGIDO
                                        }
                                        // ✅ VALIDACIÓN SIMPLE PARA USERNAME
                                        if (value!.length < 3) {
                                          return AppLocalizations.of(context)?.atLeast3Characters ?? 'Username must be at least 3 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  // Campo de contraseña (sin cambios)
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscureText,
                                    style: TextStyle(
                                      color: themeProvider.isDarkMode 
                                          ? Colors.white 
                                          : Colors.black87,
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)?.enterPasswordHint ?? 'Password',
                                      hintText: AppLocalizations.of(context)?.enterPasswordHint ?? 'Enter your password',
                                      prefixIcon: Icon(
                                        Icons.lock_outline,
                                        color: Color(0xFF8F7193),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: AnimatedSwitcher(
                                          duration: const Duration(milliseconds: 200),
                                          child: Icon(
                                            _obscureText 
                                                ? Icons.visibility_off_outlined 
                                                : Icons.visibility_outlined,
                                            key: ValueKey(_obscureText),
                                            color: themeProvider.isDarkMode 
                                                ? Colors.white70 
                                                : Colors.black54,
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureText = !_obscureText;
                                          });
                                        },
                                      ),
                                      labelStyle: TextStyle(
                                        color: themeProvider.isDarkMode 
                                            ? Colors.white70 
                                            : Color(0xFF8F7193),
                                      ),
                                      hintStyle: TextStyle(
                                        color: themeProvider.isDarkMode 
                                            ? Colors.white38 
                                            : Colors.grey[400],
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
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return AppLocalizations.of(context)?.pleaseEnterYourPassword ?? 'Please enter your password';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 32),
                                  
                                  // Botón CAPTCHA mejorado
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      gradient: _captchaVerified 
                                          ? LinearGradient(
                                              colors: [Colors.green, Colors.green[700]!],
                                            )
                                          : LinearGradient(
                                              colors: [Color(0xFF8F7193), Color(0xFFA788AB)],
                                            ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (_captchaVerified ? Colors.green : Color(0xFF8F7193))
                                              .withOpacity(0.4),
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                        onTap: _captchaVerified ? null : _verifyCaptcha,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              AnimatedSwitcher(
                                                duration: const Duration(milliseconds: 300),
                                                child: Icon(
                                                  _captchaVerified 
                                                      ? Icons.check_circle 
                                                      : Icons.security,
                                                  key: ValueKey(_captchaVerified),
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                _captchaVerified 
                                                    ? AppLocalizations.of(context)?.captchaVerified ?? 'CAPTCHA Verified ✓' 
                                                    : AppLocalizations.of(context)?.verifyCaptchaButton ?? 'Verify CAPTCHA',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  // Botón de login mejorado
                                  Container(
                                    width: double.infinity,
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
                                            AppLocalizations.of(context)?.signInText ?? "Sign In",
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
                                  const SizedBox(height: 32),
                                  
                                  // Enlace de registro mejorado
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SelectUserType(),
                                        ),
                                      );
                                    },
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: themeProvider.isDarkMode 
                                              ? Colors.white70 
                                              : Colors.grey[600],
                                        ),
                                        children: [
                                          TextSpan(text: AppLocalizations.of(context)?.dontHaveAccount ?? "Don't have an account? Register"),
                                          TextSpan(
                                            text: AppLocalizations.of(context)?.registerTexxt ?? "Register",
                                            style: TextStyle(
                                              color: Color(0xFF8F7193),
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // ✅ BOTÓN DE MODO OSCURO ENCIMA DE TODO
                Positioned(
                  top: 50,
                  right: 20,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode 
                            ? Color(0xFF2D2D2D) 
                            : Color(0xFFA788AB),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(25),
                          onTap: () {
                            themeProvider.toggleTheme();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Icon(
                                themeProvider.isDarkMode 
                                    ? Icons.light_mode 
                                    : Icons.dark_mode,
                                key: ValueKey(themeProvider.isDarkMode),
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: LanguageButton(),
        );
      },
    );
  }
}