import 'package:auth_feature/interfaces/user_data_interface.dart';

abstract interface class StorageUserDataProvider {
  Future<UserData> load();
  Future<void> save({required UserData user});
  Future<void> delete();
}
