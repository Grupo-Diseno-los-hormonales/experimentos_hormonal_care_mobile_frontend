import 'package:flutter/material.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/appointment/presentation/pages/patients_list_screen.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/medical_record/medical_prescription/presentation/pages/patients_list_screen.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/medical_record/medical_prescription/presentation/pages/medical_prescription_screen.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/appointment/presentation/pages/appointment_screen.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/notifications/presentation/pages/notification_screen.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/profile/presentation/pages/doctor_profile_screen.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/profile/presentation/pages/patient_profile_screen.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/core/utils/notice_manager.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/core/utils/usecases/jwt_storage.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/data/theme_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? role;
  int? doctorId;
  bool _isDarkMode = false;

  List<Widget> _widgetOptions = [];

   @override
  void initState() {
    super.initState();
    _loadRoleAndDoctorId();
    _loadNotice();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final isDark = await ThemeService.isDarkMode();
    setState(() {
      _isDarkMode = isDark;
    });
  }

  Future<void> _loadRoleAndDoctorId() async {
    final storedRole = await JwtStorage.getRole();
    final storedDoctorId = await JwtStorage.getDoctorId();

    setState(() {
      role = storedRole;
      doctorId = storedDoctorId;

      _widgetOptions = [
        HomePatientsScreen(doctorId: doctorId ?? 0),
        PatientsListScreen(),
        AppointmentScreen(),
        NotificationScreen(doctorId: doctorId ?? 0),
        role == 'ROLE_DOCTOR' ? DoctorProfileScreen() : PatientProfileScreen(),
      ];
    });
  }

  Future<void> _loadNotice() async {
    await NoticeManager.loadNotice();
    setState(() {});
  }
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showNoticeDetail(Map<String, dynamic> notice) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: _isDarkMode ? Color(0xFF2D2D2D) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                notice['title'] ?? '',
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold, 
                  color: _isDarkMode ? Colors.white : Color(0xFF8F7193)
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                notice['body'] ?? '',
                style: TextStyle(
                  fontSize: 16, 
                  color: _isDarkMode ? Colors.white70 : Color(0xFF4B006E)
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  NoticeManager.clearNotice();
                  Navigator.of(context).pop();
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8F7193),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notice = NoticeManager.currentNotice;
    return Scaffold(
      backgroundColor: _isDarkMode ? Color(0xFF1E1E1E) : Color(0xFFF5F5F5),
      body: Column(
        children: [
          if (notice != null)
            Container(
              color: _isDarkMode ? Color(0xFF4A4A4A) : Color(0xFFFFF3CD),
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showNoticeDetail(notice),
                      child: Text(
                        notice['title'] ?? '',
                        style: TextStyle(
                          color: _isDarkMode ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close, 
                      color: _isDarkMode ? Colors.white : Colors.black
                    ),
                    onPressed: () {
                      setState(() {
                        NoticeManager.clearNotice();
                      });
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: _widgetOptions.isNotEmpty
                ? _widgetOptions[_selectedIndex]
                : Center(
                    child: CircularProgressIndicator(
                      color: _isDarkMode ? Colors.white : Color(0xFF8F7193),
                    )
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: _isDarkMode ? Color(0xFF2D2D2D) : Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFA788AB),
        unselectedItemColor: _isDarkMode ? Colors.white70 : Color(0xFF8F7193),
        onTap: _onItemTapped,
      ),
    );
  }
}