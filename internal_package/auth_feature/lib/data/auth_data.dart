// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum AuthStatus {
  initial,
  authorized,
  unauthorized,
  error_of_password,
  user_not_found,
  network_failure,
  user_exist,
  unknown,
  error_of_validation,
}

class UserData {
  int id = -1;
  String password = '';
  String email = '';
  String deviceType = '';
  String accessToken = '';
  String deviceId = '';
  AuthStatus authStatus = AuthStatus.unauthorized;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'password': password,
      'email': email,
      'device_type': deviceType,
      'device_id': deviceId,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'UserData(id: $id, password: $password, email: $email, deviceType: $deviceType, deviceId: $deviceId, accessToken: $accessToken, authStatus: $authStatus)';
  }
}

Future<void> setUserData(UserData user) async {
  await Hive.initFlutter();
  Box box = await Hive.openBox('UserBox');
  box.put('id', user.id);
  box.put('email', user.email);
  box.put('password', user.password);
  box.put('deviceId', user.deviceId);
  box.put('deviceType', user.deviceType);
  box.put('accessToken', user.accessToken);
  box.put('auth_status', user.authStatus.toString());
}

Future<void> deleteUserData() async {
  await Hive.initFlutter();
  Box box = await Hive.openBox('UserBox');
  box.put('id', '');
  box.put('email', '');
  box.put('password', '');
  box.put('deviceId', '');
  box.put('deviceType', '');
  box.put('accessToken', '');
  box.put('auth_status', AuthStatus.unauthorized);
}

Future<UserData> getUserData() async {
  await Hive.initFlutter();
  UserData user = UserData();
  Box box = await Hive.openBox('UserBox');
  user.id = box.get('id');
  user.email = box.get('email');
  user.password = box.get('password');
  user.deviceId = box.get('deviceId');
  user.deviceType = box.get('deviceType');
  user.accessToken = box.get('accessToken');

  user.authStatus = AuthStatus.values
      .firstWhere((e) => e.toString() == box.get('auth_status'));
  return user;
}
