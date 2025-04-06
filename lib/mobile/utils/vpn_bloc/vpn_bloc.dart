import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vpn/flutter_vpn.dart';
import 'package:flutter_vpn/state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn/mobile/utils/vpn_bloc/vpn_state.dart';
import 'package:vpn/mobile/utils/vpn_service.dart';
import 'package:vpn_info/vpn_info.dart';

import 'vpn_event.dart';

class VpnChecker {
  static const platform = MethodChannel('com.example/vpn');
  Future<bool> isVPNConnected() async {
    try {
      final bool result = await platform.invokeMethod('isVPNConnected');
      print('platform result = $result');
      return result;
    } on PlatformException catch (e) {
      print("Failed to get VPN status: '${e.message}'.");
      return false;
    }
  }
}

class VpnBloc extends Bloc<VpnEvent, VpnState> {
  CurrentServer? currentServer;
  Future<void> checkConnectState() async {
    if (Platform.isIOS) {
      await FlutterVpn.prepare();

      bool vpnConnected = await VpnChecker().isVPNConnected();
      if (vpnConnected) {
        emit(VpnState(
            connectionState: FlutterVpnState.connected, status: 'Подключено'));
      } else {
        emit(VpnState(
            connectionState: FlutterVpnState.disconnected,
            status: 'Отключено'));
      }
    }

    if (Platform.isAndroid) {
      await FlutterVpn.prepare();
      bool vpnConnected = await VpnInfo.isVpnConnected();
      if (vpnConnected) {
        emit(VpnState(
            connectionState: FlutterVpnState.connected, status: 'Подключено'));
      } else {
        emit(VpnState(
            connectionState: FlutterVpnState.disconnected,
            status: 'Отключено'));
      }
    }
  }

  VpnBloc()
      : super(VpnState(
            connectionState: FlutterVpnState.disconnected,
            status: 'Отключено')) {
    checkConnectState();

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
      emit(VpnState(
          connectionState: FlutterVpnState.disconnected, status: 'Отключено'));
      await VpnService.connect(username: '', server: '', password: '');
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

      emit(VpnState(connectionState: event.state, status: status));
    });

    on<ChangeServerEvent>((event, emit) {
      currentServer = CurrentServer(
          host: event.host, userName: event.userName, password: event.password);
    });
  }
}
