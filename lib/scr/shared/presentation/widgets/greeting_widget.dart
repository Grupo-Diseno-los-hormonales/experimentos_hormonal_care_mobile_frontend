import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/providers/theme_provider.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/core/utils/usecases/greeting_service.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/core/utils/usecases/greeting_session_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GreetingWidget extends StatefulWidget {
  const GreetingWidget({Key? key}) : super(key: key);

  @override
  State<GreetingWidget> createState() => _GreetingWidgetState();
}

class _GreetingWidgetState extends State<GreetingWidget> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _userName = 'User';
  String _greetingMessage = '';
  bool _isVisible = false; // ✅ Cambiado a false inicialmente
  bool _shouldShow = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkIfShouldShow();
  }

  // ✅ NUEVO: Verificar si debe mostrar el saludo
  Future<void> _checkIfShouldShow() async {
    final shouldShow = await GreetingSessionService.shouldShowGreeting();
    
    if (shouldShow && mounted) {
      setState(() {
        _shouldShow = true;
        _isVisible = true;
      });
      
      await _loadUserName();
      _animationController.forward();
      _startAutoHide();
      
      // Marcar como mostrado
      await GreetingSessionService.markGreetingAsShown();
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
    ));
  }

  Future<void> _loadUserName() async {
    try {
      final userName = await GreetingService.getUserName();
      final greetingMessage = GreetingService.getGreetingMessage(userName);
      
      if (mounted) {
        setState(() {
          _userName = userName;
          _greetingMessage = greetingMessage;
        });
      }
    } catch (e) {
      print('Error loading user name: $e');
      if (mounted) {
        setState(() {
          _greetingMessage = 'Welcome to HormonalCare!';
        });
      }
    }
  }

  void _startAutoHide() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _isVisible) {
        _animationController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _isVisible = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ No mostrar si no debe mostrarse o no es visible
    if (!_shouldShow || !_isVisible) {
      return const SizedBox.shrink();
    }

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: themeProvider.isDarkMode
                            ? [
                                const Color(0xFF8F7193).withOpacity(0.9),
                                const Color(0xFFA788AB).withOpacity(0.8),
                              ]
                            : [
                                const Color(0xFFA788AB).withOpacity(0.9),
                                const Color(0xFFDFCAE1).withOpacity(0.8),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: themeProvider.isDarkMode
                              ? Colors.black.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getGreetingIcon(),
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _greetingMessage.isNotEmpty ? _greetingMessage : 'Welcome to HormonalCare!',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(AppLocalizations.of(context)?.welcomeMessage ?? 'Welcome to HormonalCare!',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      return Icons.wb_sunny;
    } else if (hour < 18) {
      return Icons.wb_sunny_outlined;
    } else {
      return Icons.nightlight_round;
    }
  }
}