import 'package:flutter_vpn/state.dart';

enum VpnConnectionState { disconnected, connecting, connected, error }

class VpnState {
  final FlutterVpnState connectionState;
  final String status;

  VpnState({
    required this.connectionState,
    required this.status,
  });
}
