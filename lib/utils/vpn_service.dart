import 'package:flutter_vpn/flutter_vpn.dart';

class VpnService {
  static Future<void> connect() async {
    await FlutterVpn.connectIkev2EAP(
      server: 'cryptonsrv1.ddns.net',
      username: 'vpn_server_1',
      password: 'kjfklsfjdfldfjs1829',
    );
  }

  static Future<void> disconnect() async {
    await FlutterVpn.disconnect();
  }
}
