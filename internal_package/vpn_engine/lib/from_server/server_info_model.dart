// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vpn_engine/from_server/api_server/models/free_server_model.dart';
import 'package:vpn_engine/from_server/api_server/models/root_model.dart';
import 'package:vpn_engine/from_server/api_server/models/server_http_model.dart';
import 'package:vpn_engine/from_server/api_server/models/user_http_model.dart';

class ServerRepository {
  String baseAddress;
  String accessToken;
  ServerRepository({
    required this.baseAddress,
    required this.accessToken,
  }) {}
  Future<RootHttpModel> getServerInfo(String email) async {
    try {
      print('Token $accessToken');
      Response response = await Dio().get('$baseAddress/api/user_info/',
          queryParameters: {'email': email},
          options: Options(
            headers: <String, String>{'authorization': 'Token $accessToken'},
          ));

      if (response.statusCode == 200) {
        await Hive.initFlutter();
        var box = await Hive.openBox('cache');
        RootHttpModel rootHttpModel = RootHttpModel.fromJson(response.data);
        print('roothttpModel ${rootHttpModel.toJson()}');
        await box.put('servers_cache', json.encode(rootHttpModel.toJson()));
        return rootHttpModel;
      } else {
        throw Exception('Ошибка получения данных');
      }
    } catch (e) {
      print(e);
      throw Exception('Ошибка сети');
    }
  }

  Future<RootHttpModel> getServerInfoCached() async {
    try {
      await Hive.initFlutter();
      var box = await Hive.openBox('cache');
      print(box.get('servers_cache'));
      var data = json.decode(box.get('servers_cache'));
      RootHttpModel rootHttpModel = RootHttpModel.fromJson(data);
      print('parsed root http model = ${rootHttpModel.toJson()}');
      return rootHttpModel;
    } catch (e) {
      print('exception in cache ${e}');
      return RootHttpModel(
          tariffs: [],
          servers: [],
          user_info: UserHttpModel(
              balance: 0.0, is_blocked: false, current_tarif_id: 1));
    }
  }

  Future<FreeServerHttpModel> getFreeServersInfo(String email) async {
    try {
      Response response = await Dio().get('$baseAddress/api/free-servers/');

      if (response.statusCode == 200) {
        await Hive.initFlutter();
        var box = await Hive.openBox('cache');
        FreeServerHttpModel freeServerHttpModel =
            FreeServerHttpModel.fromJson(response.data);
        await box.put(
            'free_servers_cache', json.encode(freeServerHttpModel.toJson()));
        return freeServerHttpModel;
      } else {
        throw Exception('Ошибка получения данных');
      }
    } catch (e) {
      print(e);
      throw Exception('Ошибка сети');
    }
  }

  Future<FreeServerHttpModel> getFreeServersInfoCached() async {
    try {
      await Hive.initFlutter();
      var box = await Hive.openBox('cache');
      print(box.get('free_servers_cache'));

      var data = json.decode(box.get('free_servers_cache'));
      FreeServerHttpModel freeServerHttpModel =
          FreeServerHttpModel.fromJson(data);
      return freeServerHttpModel;
    } catch (e) {
      print('exception in cache $e');
      return FreeServerHttpModel(tariffs: [], servers: []);
    }
  }

  Future<void> logout(String deviceId, String email) async {
    Response response = await Dio().post('$baseAddress/api/logout/',
        data: {'device_id': deviceId, 'email': email},
        options: Options(
          headers: <String, String>{'authorization': 'Token $accessToken'},
        ));
  }
}
