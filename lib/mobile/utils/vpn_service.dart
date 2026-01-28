import 'package:flutter_vpn/flutter_vpn.dart';
import 'package:flutter/services.dart';

class VpnService {
  static const MethodChannel _platform = MethodChannel('com.example/vpn');

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

  /// iOS only: enables NEVPNManager On-Demand rules by DNS domain match.
  /// Important: iOS requires the VPN profile to be created first (connect once).
  static Future<bool> enableOnDemandByDomains(List<String> domains) async {
    try {
      final result = await _platform.invokeMethod<bool>(
        'configureOnDemandDomains',
        {
          'domains': domains,
          'enabled': true,
        },
      );
      print('enableOnDemandByDomains result: $result');
      return result ?? false;
    } on PlatformException catch (e) {
      print('enableOnDemandByDomains error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// iOS only: disables On-Demand and clears rules.
  static Future<bool> disableOnDemand() async {
    final result = await _platform.invokeMethod<bool>('disableOnDemand');
    return result ?? false;
  }
}
