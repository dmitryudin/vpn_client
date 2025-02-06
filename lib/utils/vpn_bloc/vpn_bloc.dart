import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vpn/flutter_vpn.dart';
import 'package:flutter_vpn/state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn/utils/vpn_bloc/vpn_state.dart';
import 'package:vpn/utils/vpn_service.dart';

import 'vpn_event.dart';

class VpnBloc extends Bloc<VpnEvent, VpnState> {
  Future<void> _saveConnectionState(FlutterVpnState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vpn_state', state.toString());
    if (currentServer != null) {
      await prefs.setString('server_host', currentServer!.host);
      await prefs.setString('server_username', currentServer!.userName);
      await prefs.setString('server_password', currentServer!.password);
    }
  }

  Future<void> _restoreConnectionState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedState = prefs.getString('vpn_state');
    final host = prefs.getString('server_host');
    final username = prefs.getString('server_username');
    final password = prefs.getString('server_password');

    if (savedState == FlutterVpnState.connected.toString() &&
        host != null &&
        username != null &&
        password != null) {
      currentServer =
          CurrentServer(host: host, userName: username, password: password);
      add(ConnectVpn());
    }
  }

  CurrentServer? currentServer;

  VpnBloc()
      : super(VpnState(
            connectionState: FlutterVpnState.disconnected,
            status: 'Отключено')) {
    _restoreConnectionState();

    FlutterVpn.prepare();

    FlutterVpn.onStateChanged.listen((state) {
      add(UpdateVpnState(state as FlutterVpnState));
    });

    on<ConnectVpn>((event, emit) async {
      if (currentServer == null) {
        emit(VpnState(
            connectionState: FlutterVpnState.disconnected,
            status: 'Выберите сервер'));
      } else {
        emit(VpnState(
            connectionState: FlutterVpnState.connecting,
            status: 'Подключение'));
        print('host ${currentServer!.userName}');
        print('host ${currentServer!.host}');
        print('host ${currentServer!.password}');
        await VpnService.connect(
            username: currentServer!.userName,
            server: currentServer!.host,
            password: currentServer!.password);
      }
    });

    on<DisconnectVpn>((event, emit) async {
      emit(VpnState(
          connectionState: FlutterVpnState.disconnecting,
          status: 'Отключение'));
      await VpnService.disconnect();
    });

    on<UpdateVpnState>((event, emit) async {
      String status = '';
      switch (event.state) {
        case FlutterVpnState.connected:
          status = 'Подключено';
          break;
        case FlutterVpnState.disconnected:
          status = 'Отключено';
          break;
        case FlutterVpnState.connecting:
          status = 'Подключение';
          break;
        case FlutterVpnState.disconnecting:
          status = 'Отключение';
          break;
        default:
          status = 'Неизвестно';
      }
      await _saveConnectionState(event.state);
      emit(VpnState(connectionState: event.state, status: status));
    });

    on<ChangeServerEvent>((event, emit) {
      currentServer = CurrentServer(
          host: event.host, userName: event.userName, password: event.password);
    });
  }
}
