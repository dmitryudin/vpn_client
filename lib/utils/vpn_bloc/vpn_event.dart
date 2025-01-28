import 'package:flutter_vpn/state.dart';
import 'package:vpn/utils/vpn_bloc/vpn_state.dart';

abstract class VpnEvent {}

class ConnectVpn extends VpnEvent {}

class DisconnectVpn extends VpnEvent {}

class UpdateVpnState extends VpnEvent {
  final FlutterVpnState state;
  UpdateVpnState(this.state);
}
