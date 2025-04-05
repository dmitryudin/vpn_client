import 'dart:convert';
import 'dart:io';
import 'package:auth_feature/data/auth_data.dart';
import 'package:auth_feature/data/device_info.dart';
import 'package:dio/dio.dart';

Future<UserData> registerInServer(UserData user, String registerUrl) async {
  try {
    if (user.email.isEmpty || user.password.isEmpty) {
      user.authStatus = AuthStatus.error_of_validation;
      return user;
    }
    final deviceInfo = await getDeviceInfo();
    user.deviceType = deviceInfo['deviceType'] ?? '';
    user.deviceId = deviceInfo['deviceId'] ?? '';

    print(user.toJson());
    Response response = await Dio().post(registerUrl, data: user.toJson());
    user.accessToken = response.data['access_token'].toString();
    print(response.data['access_token']);
    print(user.email);
    print(user.accessToken);

    user.authStatus = AuthStatus.authorized;

    return user;
  } on DioError catch (_, e) {
    print('exception on register server $_');
    if (_.runtimeType == SocketException) {
      user.authStatus = AuthStatus.network_failure;
      return user;
    }
    if (_.response == null) {
      user.authStatus = AuthStatus.network_failure;
      return user;
    }
    if (_.response!.statusCode == 409) {
      user.authStatus = AuthStatus.user_exist;
      return user;
    }
  }
  return user;
}

Future<UserData> loginInServer(
    {required String message_service_token,
    required String deviceType,
    required String deviceId,
    required String username,
    required String password,
    required String authUrl}) async {
  String basicAuth =
      'Basic ' + base64Encode(utf8.encode('${username}:${password}'));
  print(basicAuth);

  try {
    Response response = await Dio().post(authUrl,
        data: {
          'device_id': deviceId ?? '',
          'device_type': deviceType ?? '',
        },
        options: Options(
            //receiveDataWhenStatusError: true,
            headers: <String, String>{
              'Authorization': basicAuth,
              'User-Agent': 'PostmanRuntime/7.36.3',
              'Accept': '*/*',
              'Cache-Control': 'no-cache',
              'Postman-Token': '30bb6a90-1f78-43a4-999f-b1dd6152e315',
              'Host': '91.222.236.176:8880',
              'Accept-Encoding': 'gzip, deflate, br',
              'Connection': 'keep-alive',
              'Content-Length': '0'
            }));
    Map jsonString = response.data;

    UserData user = UserData()
      ..password = password
      ..email = jsonString['user']['email'] ?? ''
      ..deviceType = deviceType
      ..deviceId = deviceId
      ..accessToken = jsonString['access_token'] ?? '';

    // RSAPublicKey.fromPEM(jsonString['server_rsa_public_key']);
    user.authStatus = AuthStatus.authorized;
    print(response.data['access_token']);
    print(user.email);
    print(user.accessToken);

    user.authStatus = AuthStatus.authorized;
    return user;
  } on DioError catch (_, e) {
    if (_.response == null)
      return UserData()..authStatus = AuthStatus.network_failure;
    if (_.response!.statusCode == 404) {
      return UserData()..authStatus = AuthStatus.user_not_found;
    }
    if (_.response!.statusCode == 401) {
      return UserData()..authStatus = AuthStatus.unauthorized;
    }
    if (_.response!.statusCode == 403) {
      return UserData()..authStatus = AuthStatus.device_lomit_over;
    }
    return UserData()..authStatus = AuthStatus.unauthorized;
  }
}
