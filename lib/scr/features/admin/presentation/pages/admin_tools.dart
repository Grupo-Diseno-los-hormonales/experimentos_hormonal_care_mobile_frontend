import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/admin/presentation/widgets/admin_chat_section.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'send_notice.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/iam/domain/services/auth_service.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/core/utils/usecases/jwt_storage.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/iam/presentation/pages/sign_in.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class AdminToolsScreen extends StatefulWidget {
  @override
  State<AdminToolsScreen> createState() => _AdminToolsScreenState();
}

class _AdminToolsScreenState extends State<AdminToolsScreen> with TickerProviderStateMixin {
  
  late TabController _tabController;
  late AnimationController _animationController;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    _tabController = TabController(length: 5, vsync: this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    super.initState();
  }

  Future<void> _logout() async {
    // NO limpiar el tema - se mantiene global
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SignIn()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: AppBar(
                backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                elevation: 0,
                titleSpacing: 0,
                title: Row(
                  children: [
                    const SizedBox(width: 16),
                    Text(
                      'Admin Panel',
                      style: TextStyle(
                        color: Theme.of(context).appBarTheme.foregroundColor,
                      ),
                    ),
                    const Spacer(),
                    // Solo botón de logout - SIN botón de modo oscuro
                    IconButton(
                      icon: Icon(
                        Icons.logout,
                        color: Theme.of(context).appBarTheme.foregroundColor,
                      ),
                      onPressed: _logout,
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(50),
                  child: Container(
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      isScrollable: true,
                      tabs: const [
                        Tab(text: 'Dashboard'),
                        Tab(text: 'Stats'),
                        Tab(text: 'Logs'),
                        Tab(text: 'Notices'),
                        Tab(text: 'Support'),
                      ],
                    ),
                  ),
                ),
              ),
              body: Stack(
                children: [
                  AnimatedGradientBackground(
                    animation: _animationController,
                    isDarkMode: themeProvider.isDarkMode,
                  ),
                  TabBarView(
                    controller: _tabController,
                    children: [
                      _DashboardSection(
                        animation: _animationController,
                        isDarkMode: themeProvider.isDarkMode,
                      ),
                      _StatsSection(
                        animation: _animationController,
                        isDarkMode: themeProvider.isDarkMode,
                      ),
                      _LogsSection(
                        animation: _animationController,
                        isDarkMode: themeProvider.isDarkMode,
                      ),
                      SendNoticeScreen(),
                      const AdminGlobalChatSection(),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// Actualiza el fondo animado
class AnimatedGradientBackground extends StatelessWidget {
  final Animation<double> animation;
  final bool isDarkMode;
  
  const AnimatedGradientBackground({
    required this.animation,
    required this.isDarkMode,
  });
  
  @override
  Widget build(BuildContext context) {
    final t = animation.value;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  Color(0xFF1E1E1E),
                  Color(0xFF2D2D2D),
                  Color(0xFF4A4A4A),
                ]
              : [
                  Color(0xFFF3EAF7).withOpacity(0.8 + 0.2 * sin(t * 2 * pi)),
                  Color(0xFFE2D1F4).withOpacity(0.6 + 0.3 * cos(t * 3 * pi)),
                  Color(0xFFD1C2E8).withOpacity(0.7 + 0.2 * sin(t * 4 * pi)),
                ],
        ),
      ),
    );
  }
}

// Actualiza las secciones existentes para modo oscuro
class _DashboardSection extends StatelessWidget {
  final Animation<double> animation;
  final bool isDarkMode;
  
  _DashboardSection({required this.animation, required this.isDarkMode});

  final stats = const [
    {'label': 'Avisos enviados', 'value': '15,000'},
    {'label': 'Logs registrados', 'value': '45,633'},
    {'label': 'Pacientes reasignados', 'value': '3,012'},
    {'label': 'Intentos fallidos', 'value': '87'},
    {'label': 'Nuevos usuarios', 'value': '124'},
    {'label': 'Tiempo resp. prom.', 'value': '2h 14m'},
    {'label': 'Tickets abiertos', 'value': '16'},
  ];

  final recent = const [
    '[06/06 14:20] User ana99 cambió contraseña',
    '[06/06 14:10] Aviso enviado a todos los doctores',
    '[06/06 13:58] Nuevo usuario juanita23 registrado',
    '[06/06 13:45] Doctor rmendoza reasignado a paciente #303',
    '[06/06 13:30] Ticket de soporte resuelto',
  ];

  final errors = const [
    '🔴 [06/06 14:00] 500 Error en /api/assign-doctor',
    '🔴 [06/06 13:40] Timeout en /api/support',
  ];

  final ips = const [
    '⚠️ 192.168.1.44 — 5 intentos fallidos',
    '⚠️ 190.12.55.88 — 3 intentos fallidos',
  ];

  final alerts = const [
    '🕵️ admin1 inició sesión desde ubicación inusual',
    '🕵️ Intento de acceso no autorizado a /admin/reassign',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 Estadísticas Rápidas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Color(0xFF4B006E),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: stats.map((stat) => _StatCard(
              label: stat['label']!,
              value: stat['value']!,
              animation: animation,
              isDarkMode: isDarkMode,
            )).toList(),
          ),
          const SizedBox(height: 32),
          Text(
            '📋 Actividad Reciente',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Color(0xFF4B006E),
            ),
          ),
          const SizedBox(height: 12),
          _CurvedCard(
            animation: animation,
            isDarkMode: isDarkMode,
            child: Column(
              children: recent.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: isDarkMode ? Colors.white70 : Color(0xFF8F7193)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDarkMode ? Colors.white70 : Color(0xFF4B006E),
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔴 Errores',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Color(0xFF4B006E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _CurvedCard(
                      animation: animation,
                      isDarkMode: isDarkMode,
                      child: Column(
                        children: errors.map((error) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            error,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode ? Colors.red[300] : Colors.red[700],
                            ),
                          ),
                        )).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚠️ IPs Sospechosas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Color(0xFF4B006E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _CurvedCard(
                      animation: animation,
                      isDarkMode: isDarkMode,
                      child: Column(
                        children: ips.map((ip) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            ip,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode ? Colors.orange[300] : Colors.orange[700],
                            ),
                          ),
                        )).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '🕵️ Alertas de Seguridad',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Color(0xFF4B006E),
            ),
          ),
          const SizedBox(height: 8),
          _CurvedCard(
            animation: animation,
            isDarkMode: isDarkMode,
            child: Column(
              children: alerts.map((alert) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  alert,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.yellow[300] : Colors.orange[800],
                  ),
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Animation<double> animation;
  final bool isDarkMode;
  
  const _StatCard({
    required this.label,
    required this.value,
    required this.animation,
    required this.isDarkMode,
  });
  
  @override
  Widget build(BuildContext context) {
    return _CurvedCard(
      animation: animation,
      width: 150,
      isDarkMode: isDarkMode,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Color(0xFF4B006E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: isDarkMode ? Colors.white70 : Color(0xFF8F7193),
            ),
          ),
        ],
      ),
    );
  }
}

// STATS
class _StatsSection extends StatelessWidget {
  final Animation<double> animation;
  final bool isDarkMode;
  
  _StatsSection({required this.animation, required this.isDarkMode});
  
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '📈 Gráficos y Estadísticas',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Color(0xFF4B006E),
          ),
        ),
        const SizedBox(height: 24),
        _CurvedCard(
          animation: animation,
          isDarkMode: isDarkMode,
          child: Column(
            children: [
              Text(
                'Usuarios Activos por Mes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Color(0xFF4B006E),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) => Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: isDarkMode ? Colors.white70 : Color(0xFF8F7193),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) => Text(
                            ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun'][value.toInt()],
                            style: TextStyle(
                              color: isDarkMode ? Colors.white70 : Color(0xFF8F7193),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          FlSpot(0, 30),
                          FlSpot(1, 45),
                          FlSpot(2, 42),
                          FlSpot(3, 55),
                          FlSpot(4, 60),
                          FlSpot(5, 58),
                        ],
                        isCurved: true,
                        color: Color(0xFF8F7193),
                        barWidth: 3,
                        belowBarData: BarAreaData(
                          show: true,
                          color: Color(0xFF8F7193).withOpacity(0.3),
                        ),
                        dotData: FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// LOGS
class _LogsSection extends StatelessWidget {
  final Animation<double> animation;
  final bool isDarkMode;
  
  _LogsSection({required this.animation, required this.isDarkMode});
  
  final logs = const [
    {
      'timestamp': '2025-06-13 22:14',
      'user': 'admin@hormonalcare.com',
      'event': 'Login Success',
      'ip': '192.168.0.12',
      'risk': 'Bajo',
      'details': 'Lima, Perú\nChrome en Windows'
    },
    {
      'timestamp': '2025-06-13 22:20',
      'user': 'ana.romero@hormonalcare.com',
      'event': 'Intento fallido',
      'ip': '10.0.0.5',
      'risk': 'Medio',
      'details': 'Lima, Perú\nEdge en Windows'
    },
    {
      'timestamp': '2025-06-13 22:25',
      'user': 'carlos.mendez@hormonalcare.com',
      'event': 'Password Reset',
      'ip': '172.16.0.8',
      'risk': 'Bajo',
      'details': 'Lima, Perú\nSafari en macOS'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '📋 Logs del Sistema',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Color(0xFF4B006E),
          ),
        ),
        const SizedBox(height: 16),
        ...logs.map((log) => _CurvedCard(
          animation: animation,
          isDarkMode: isDarkMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: isDarkMode ? Colors.white70 : Color(0xFF8F7193),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    log['timestamp']!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Color(0xFF4B006E),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: log['risk'] == 'Bajo'
                          ? Colors.green.withOpacity(0.2)
                          : log['risk'] == 'Medio'
                              ? Colors.orange.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      log['risk']!,
                      style: TextStyle(
                        fontSize: 10,
                        color: log['risk'] == 'Bajo'
                            ? Colors.green[700]
                            : log['risk'] == 'Medio'
                                ? Colors.orange[700]
                                : Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Usuario: ${log['user']}',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Color(0xFF8F7193),
                ),
              ),
              Text(
                'Evento: ${log['event']}',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Color(0xFF8F7193),
                ),
              ),
              Text(
                'IP: ${log['ip']}',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Color(0xFF8F7193),
                ),
              ),
              Text(
                'Detalles: ${log['details']}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.white60 : Colors.grey[600],
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }
}

// CARD CURVA REUTILIZABLE CON MARCO ANIMADO
class _CurvedCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final Animation<double> animation;
  final bool isDarkMode;
  
  const _CurvedCard({
    required this.child,
    this.width,
    required this.animation,
    required this.isDarkMode,
  });
  
  @override
  Widget build(BuildContext context) {
    final t = animation.value;
    return Container(
      width: width,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode 
              ? Color(0xFF4A4A4A)
              : Color(0xFF8F7193).withOpacity(0.6 + 0.4 * sin(t * 6 * pi)),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.3)
                : Color(0xFF8F7193).withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}