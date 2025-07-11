import 'package:experimentos_hormonal_care_mobile_frontend/scr/core/utils/usecases/jwt_storage.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/profile/data/data_sources/remote/profile_service.dart';

class GreetingService {
  static final ProfileService _profileService = ProfileService();
  
  static Future<String> getUserName() async {
    try {
      // ✅ NUEVO: Verificar si es admin primero
      final role = await JwtStorage.getRole();
      if (role == 'ROLE_ADMIN' || role == 'ADMIN') {
        return 'Admin';
      }
      
      // Para usuarios normales (doctores y pacientes)
      final userId = await JwtStorage.getUserId();
      
      if (userId != null) {
        print('Getting profile details for userId: $userId');
        final profileDetails = await _profileService.fetchProfileDetails(userId);
        print('Profile details: $profileDetails');
        
        // ✅ MEJOR: Usar fullName si existe, o combinar firstName y lastName
        final fullName = profileDetails['fullName'];
        if (fullName != null && fullName.isNotEmpty) {
          return fullName;
        }
        
        final firstName = profileDetails['firstName'] ?? '';
        final lastName = profileDetails['lastName'] ?? '';
        
        if (firstName.isNotEmpty && lastName.isNotEmpty) {
          return '$firstName $lastName';
        } else if (firstName.isNotEmpty) {
          return firstName;
        }
      }
      
      return 'User';
    } catch (e) {
      print('Error getting user name: $e');
      
      // ✅ NUEVO: Fallback para admin si hay error
      final role = await JwtStorage.getRole();
      if (role == 'ROLE_ADMIN' || role == 'ADMIN') {
        return 'Admin';
      }
      
      return 'User';
    }
  }
  
  static String getGreetingMessage(String userName) {
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      return 'Good morning, $userName!';
    } else if (hour < 18) {
      return 'Good afternoon, $userName!';
    } else {
      return 'Good evening, $userName!';
    }
  }
}