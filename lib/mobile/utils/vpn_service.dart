import 'package:flutter_vpn/flutter_vpn.dart';

class VpnService {
  static Future<void> connect(
      {required String server,
      required String username,
      required String password}) async {
    await FlutterVpn.connectIkev2EAP(
      server: server,
      username: username,
      password: password,
    );
  }

  static Future<void> disconnect() async {
    await FlutterVpn.disconnect();
  }
}
