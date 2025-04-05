import 'package:auth_feature/interfaces/user_data_interface.dart';

abstract interface class AuthApiService {
  Future<UserData> register({required UserData user});

  Future<UserData> login(UserData user);

  Future<String> refreshToken({required String refreshToken});
}
