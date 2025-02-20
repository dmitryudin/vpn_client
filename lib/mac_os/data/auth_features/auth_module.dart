import 'package:auth_feature/auth_feature.dart';
import 'package:auth_feature/data/auth_data.dart';

class AuthModule {
  static final AuthModule _instance = AuthModule._internal();
  late final AuthService _authService;

  factory AuthModule() {
    return _instance;
  }

  AuthModule._internal() {
    _authService = AuthService();
  }

  AuthService get authService => _authService;
}
