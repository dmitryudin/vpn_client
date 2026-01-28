import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vpn/flutter_vpn.dart';
import 'package:flutter_vpn/state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn/mobile/utils/vpn_bloc/vpn_state.dart';
import 'package:vpn/mobile/utils/vpn_service.dart';
import 'package:vpn/mobile/utils/vpn_statistics_service.dart';
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
  static const platform = MethodChannel('com.example/vpn');

  Future<void> checkConnectState() async {
    if (Platform.isIOS) {
      await FlutterVpn.prepare();

      bool vpnConnected = await VpnChecker().isVPNConnected();
      if (vpnConnected) {
        add(UpdateVpnState(FlutterVpnState.connected));
      } else {
        add(UpdateVpnState(FlutterVpnState.disconnected));
      }
    }

    if (Platform.isAndroid) {
      await FlutterVpn.prepare();
      bool vpnConnected = await VpnInfo.isVpnConnected();
      if (vpnConnected) {
        add(UpdateVpnState(FlutterVpnState.connected));
      } else {
        add(UpdateVpnState(FlutterVpnState.disconnected));
      }
    }
  }

  VpnBloc()
      : super(VpnState(
            connectionState: FlutterVpnState.disconnected,
            status: 'Отключено')) {
    _loadSavedServer();
    checkConnectState();

    // Настройка обработчика URL schemes для автоматизации
    // Этот обработчик получает вызовы autoConnect/autoDisconnect из AppDelegate
    platform.setMethodCallHandler((call) async {
      if (call.method == 'autoConnect') {
        // Загружаем сохраненный сервер перед подключением
        await _loadSavedServer();
        add(ConnectVpn());
      } else if (call.method == 'autoDisconnect') {
        add(DisconnectVpn());
      }
    });

    FlutterVpn.onStateChanged.listen((state) {
      add(UpdateVpnState(state));
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

        // Сохраняем данные сервера в UserDefaults для нативного кода
        await _saveServerToUserDefaults(currentServer!.host,
            currentServer!.userName, currentServer!.password);

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
          // Сохраняем время начала сессии и увеличиваем счетчик подключений
          await VpnStatisticsService.saveSessionStart();
          await VpnStatisticsService.incrementConnectionsCount();
          await VpnStatisticsService.updateDailyStats(connectionsCount: null);
          break;
        case FlutterVpnState.disconnected:
          status = 'Отключено';
          // Сохраняем статистику сессии при отключении
          final sessionDuration = await VpnStatisticsService.getSessionDuration();
          if (sessionDuration.inSeconds > 0) {
            // Симулируем передачу данных на основе времени подключения
            final estimatedData = VpnStatisticsService.estimateDataTransferred(sessionDuration);
            await VpnStatisticsService.updateDailyStats(
              durationSeconds: sessionDuration.inSeconds,
              dataBytes: estimatedData,
            );
            await VpnStatisticsService.saveTotalStats(
              durationSeconds: sessionDuration.inSeconds,
              dataBytes: estimatedData,
            );
            await VpnStatisticsService.clearSessionStart();
          }
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
      // Сохраняем сервер для автоматического подключения
      _saveServer(event.host, event.userName, event.password);
    });
  }

  // Сохранение сервера в SharedPreferences
  Future<void> _saveServer(
      String host, String userName, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('vpn_server_host', host);
      await prefs.setString('vpn_server_username', userName);
      await prefs.setString('vpn_server_password', password);

      // Также сохраняем в UserDefaults для нативного кода
      await _saveServerToUserDefaults(host, userName, password);
    } catch (e) {
      print('Ошибка сохранения сервера: $e');
    }
  }

  // Сохранение сервера в UserDefaults (iOS) для нативного кода
  Future<void> _saveServerToUserDefaults(
      String host, String userName, String password) async {
    try {
      await platform.invokeMethod('saveServerCredentials', {
        'host': host,
        'username': userName,
        'password': password,
      });
    } catch (e) {
      print('Ошибка сохранения сервера в UserDefaults: $e');
    }
  }

  // Загрузка сохраненного сервера из SharedPreferences
  Future<void> _loadSavedServer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final host = prefs.getString('vpn_server_host');
      final userName = prefs.getString('vpn_server_username');
      final password = prefs.getString('vpn_server_password');

      if (host != null && userName != null && password != null) {
        currentServer = CurrentServer(
          host: host,
          userName: userName,
          password: password,
        );
      }
    } catch (e) {
      print('Ошибка загрузки сервера: $e');
    }
  }
}
