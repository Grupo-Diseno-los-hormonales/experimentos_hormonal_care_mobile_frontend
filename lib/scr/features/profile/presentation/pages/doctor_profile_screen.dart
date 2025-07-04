import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/admin/presentation/pages/support_chat_screen.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/admin/presentation/widgets/admin_chat_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/profile/data/data_sources/remote/profile_service.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/core/utils/usecases/jwt_storage.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/iam/domain/services/auth_service.dart';
import '../widgets/profile_picture_widget.dart';
import '../widgets/profile_field_widget.dart';
import '../widgets/edit_mode_doctor_widget.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/iam/presentation/pages/sign_in.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/providers/theme_provider.dart';

class DoctorProfileScreen extends StatefulWidget {
  @override
  _DoctorProfileScreenState createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  bool isEditing = false;
  Future<Map<String, dynamic>>? _doctorProfileDetails;
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();
  int? _doctorId;
  String? _role;
  bool _loadingRole = true;

  @override
  void initState() {
    super.initState();
    _loadDoctorProfileDetails();
    _loadRole();
  }

  Future<void> _loadDoctorProfileDetails() async {
    final profileId = await JwtStorage.getProfileId();

    if (profileId != null) {
      final profileDetails = await _profileService.fetchProfileDetails(profileId);
      final doctorProfessionalDetails = await _profileService.fetchDoctorProfessionalDetails(profileId);

      final combinedDetails = {
        ...profileDetails,
        ...doctorProfessionalDetails,
      };

      setState(() {
        _doctorProfileDetails = Future.value(combinedDetails);
        _doctorId = doctorProfessionalDetails['id'];
      });
    } else {
      print('Profile ID not found');
    }
  }

  Future<void> _loadRole() async {
    final role = await _authService.getRole();
    setState(() {
      _role = role;
      _loadingRole = false;
    });
  }

  void toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  Future<void> _logout() async {
    // Limpiar el tema al cerrar sesión
    Provider.of<ThemeProvider>(context, listen: false).clearTheme();
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SignIn()),
      (route) => false,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return AlertDialog(
              backgroundColor: themeProvider.isDarkMode ? Color(0xFF2D2D2D) : Colors.white,
              title: Text(
                'Confirm Logout',
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Color(0xFF8F7193),
                ),
              ),
              content: Text(
                'Are you sure you want to log out?',
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white70 : Color(0xFFA788AB),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.white70 : Color(0xFF8F7193),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(
                    'Yes',
                    style: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.white : Color(0xFF8F7193),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _logout();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openSupportChat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SupportChatScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.isDarkMode ? Color(0xFF1E1E1E) : Color(0xFFF5F5F5),
          appBar: AppBar(
            backgroundColor: themeProvider.isDarkMode ? Color(0xFF2D2D2D) : Color(0xFF8F7193),
            title: const Text(
              'Doctor Profile',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: themeProvider.isDarkMode ? Colors.white70 : Color(0xFFA788AB),
                      ),
                      onPressed: toggleEditMode,
                    ),
                    const SizedBox(width: 8.0),
                    FutureBuilder<Map<String, dynamic>>(
                      future: _doctorProfileDetails,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator(
                            color: themeProvider.isDarkMode ? Colors.white : Color(0xFF8F7193),
                          );
                        } else if (snapshot.hasError) {
                          return Icon(
                            Icons.error,
                            color: themeProvider.isDarkMode ? Colors.white : Color(0xFF8F7193),
                          );
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Icon(
                            Icons.person,
                            color: themeProvider.isDarkMode ? Colors.white : Color(0xFF8F7193),
                          );
                        } else {
                          final doctorProfile = snapshot.data!;
                          final imageUrl = doctorProfile['image'] as String?;
                          return ProfilePictureWidget(
                            isEditing: isEditing,
                            toggleEditMode: toggleEditMode,
                            imageUrl: imageUrl,
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 8.0),
                    IconButton(
                      icon: Icon(
                        Icons.logout,
                        color: themeProvider.isDarkMode ? Colors.white70 : Color(0xFFA788AB),
                      ),
                      onPressed: _showLogoutDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                
                // Botón de soporte solo si NO es admin
                if (!_loadingRole && _role != 'ROLE_ADMIN')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeProvider.isDarkMode ? Color(0xFF4A4A4A) : Color(0xFF8F7193),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      icon: const Icon(Icons.support_agent, color: Colors.white),
                      label: const Text(
                        'Support Chat',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      onPressed: _openSupportChat,
                    ),
                  ),
                
                if (!isEditing) ...[
                  FutureBuilder<Map<String, dynamic>>(
                    future: _doctorProfileDetails,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: themeProvider.isDarkMode ? Colors.white : Color(0xFF8F7193),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error loading profile',
                            style: TextStyle(
                              color: themeProvider.isDarkMode ? Colors.white : Color(0xFF8F7193),
                            ),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            'No data found',
                            style: TextStyle(
                              color: themeProvider.isDarkMode ? Colors.white : Color(0xFF8F7193),
                            ),
                          ),
                        );
                      } else {
                        final doctorProfile = snapshot.data!;
                        return Column(
                          children: [
                            Card(
                              color: themeProvider.isDarkMode ? Color(0xFF2D2D2D) : Color(0xFFDFCAE1),
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildProfileField("First Name", doctorProfile['fullName'] ?? ''),
                                    _buildProfileField("Last Name", doctorProfile['lastName'] ?? ''),
                                    _buildProfileField("Gender", doctorProfile['gender'] ?? ''),
                                    _buildProfileField("Phone Number", doctorProfile['phoneNumber'] ?? ''),
                                    _buildProfileField("Birthday", doctorProfile['birthday'] ?? ''),
                                    _buildProfileField("Professional ID Number", doctorProfile['professionalIdentificationNumber']?.toString() ?? ''),
                                    _buildProfileField("SubSpecialty", doctorProfile['subSpecialty'] ?? ''),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
                
                // Sección de chat de admin solo si es admin
                if (!_loadingRole && _role == 'ROLE_ADMIN') ...[
                  const SizedBox(height: 30),
                  Container(
                    height: 400,
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode ? Color(0xFF2D2D2D) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFF8F7193)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFF8F7193),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.admin_panel_settings, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Support Tickets',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: AdminGlobalChatSection(),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: themeProvider.isDarkMode ? Colors.white70 : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode ? Color(0xFF4A4A4A) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}