// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_vpn/state.dart';

import 'package:vpn/mobile/utils/vpn_bloc/vpn_state.dart';

class CurrentServer {
  String host;
  String userName;
  String password;
  CurrentServer({
    required this.host,
    required this.userName,
    required this.password,
  });
}

abstract class VpnEvent {}

class ConnectVpn extends VpnEvent {}

class DisconnectVpn extends VpnEvent {}

class UpdateVpnState extends VpnEvent {
  final FlutterVpnState state;
  UpdateVpnState(this.state);
}

class ChangeServerEvent extends VpnEvent {
  String host;
  String userName;
  String password;
  ChangeServerEvent({
    required this.host,
    required this.userName,
    required this.password,
  });
}
