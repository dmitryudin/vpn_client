// import 'package:auth_feature/data/auth_data.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:auth_feature/auth_feature.dart';

// void main() {
//   test('register test', () async {
//     UserData user = UserData();

//     user.email = 'aqhy@ml.ru';
//     user.password = '12345678';

//     AuthStatus status = await AuthService().register(
//         userData: user,
//         registerUrl: 'http://109.196.101.63:8000/api/register/');
//     print(status);
//   });

//   test('login test', () async {
//     UserData user = UserData();
//     user.email = 'example@mail.ru';
//     user.password = '11111111';

//     user = await AuthService().loginOnline(
//         username: user.email,
//         password: user.password,
//         deviceType: '',
//         message_service_token: '',
//         authUrl: 'http://109.196.101.63:8000/api/login/',
//         deviceId: '');
//     print(user.authStatus);
//     print(user.accessToken);
//   });
// }
