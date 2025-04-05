import 'package:auth_feature/interfaces/auth_api_service_interface.dart';
import 'package:auth_feature/interfaces/storage_interface.dart';
import 'package:auth_feature/interfaces/user_data_interface.dart';

enum AuthRepositoryLoginStatus {
  success,
  invalod_username,
  invalid_password,
  invalid_service
}

enum AuthRepositoryRegisterStatus { success, user_exist, invalid_service }

abstract interface class AuthRepository {
  abstract AuthApiService authApiService;
  abstract StorageUserDataProvider storageUserDataProvider;
  Future<AuthRepositoryLoginStatus> login(
      {required String login, required String password});
  Future<AuthRepositoryRegisterStatus> register(
      {required UserDataForRegister userInformation});
  Future<UserData> getUserData();
}
