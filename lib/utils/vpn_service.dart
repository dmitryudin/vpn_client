import 'package:flutter_vpn/flutter_vpn.dart';

class VpnService {
  static Future<void> connect() async {
    await FlutterVpn.connectIkev2EAP(
      server: 'vpnappsuper.ddns.net',
      username: 'vpn',
      password: '9174253',
    );
  }

  static Future<void> disconnect() async {
    await FlutterVpn.disconnect();
  }
}
