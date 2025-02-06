import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vpn/flutter_vpn.dart';
import 'package:flutter_vpn/state.dart';
import 'package:vpn/utils/vpn_bloc/vpn_state.dart';
import 'package:vpn/utils/vpn_service.dart';
import 'package:vpn_info/vpn_info.dart';

import 'vpn_event.dart';

class VpnBloc extends Bloc<VpnEvent, VpnState> {
  Future<void> checkConnectState() async {
    bool vpnConnected = await VpnInfo.isVpnConnected();
    if (vpnConnected) {
      emit(VpnState(
          connectionState: FlutterVpnState.connected, status: 'Подключено'));
    } else {
      emit(VpnState(
          connectionState: FlutterVpnState.disconnected, status: 'Отключено'));
    }
  }

  VpnBloc()
      : super(VpnState(
            connectionState: FlutterVpnState.disconnected,
            status: 'Отключено')) {
    FlutterVpn.prepare();
    checkConnectState();

    FlutterVpn.onStateChanged.listen((state) {
      add(UpdateVpnState(state as FlutterVpnState));
    });

    on<ConnectVpn>((event, emit) async {
      emit(VpnState(
          connectionState: FlutterVpnState.connecting, status: 'Подключение'));

      await VpnService.connect();
    });

    on<DisconnectVpn>((event, emit) async {
      await VpnService.disconnect();
      emit(VpnState(
          connectionState: FlutterVpnState.disconnected, status: 'Отключено'));
    });

    on<UpdateVpnState>((event, emit) {
      String status = 'Отключено';
      print(event.state);
      switch (event.state) {
        case FlutterVpnState.disconnected:
          status = 'Отключено';
          break;
        case FlutterVpnState.connecting:
          status = 'Подключение';
          break;
        case FlutterVpnState.connected:
          status = 'Подключено';
          break;
        case FlutterVpnState.disconnecting:
          status = 'Отключение';
          break;
        case FlutterVpnState.error:
          status = 'Ошибка';
          break;
      }

      emit(VpnState(connectionState: event.state, status: status));
    });
  }
}
