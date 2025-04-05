import 'package:auth_feature/interfaces/user_data_interface.dart';

enum LoginStatus {
  success,
  invalod_username,
  invalid_password,
  invalid_service
}

enum RegisterStatus { success, user_exist, invalid_service }

abstract interface class AuthService {
  abstract UserData user;

  Future<bool> checkAuthStatus();
  Future<String> refreshAccessToken();
  Future<LoginStatus> login({required String login, required String password});
  Future<RegisterStatus> register({required UserData user});
}
