// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dio/dio.dart';

class ServerInfoModel {
  final int id;
  final String name;
  final String url;
  final String ip;
  final String username;
  final String country;
  final double loadCoef;

  ServerInfoModel(
      {required this.id,
      required this.name,
      required this.url,
      required this.ip,
      required this.username,
      required this.country,
      required this.loadCoef});

  factory ServerInfoModel.fromJson(Map<String, dynamic> json) {
    return ServerInfoModel(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      ip: json['ip'],
      username: json['username'],
      country: json['country'],
      loadCoef: json['load_coef'].toDouble(),
    );
  }
}

class ServerRepository {
  String baseAddress;
  String accessToken;
  ServerRepository({
    required this.baseAddress,
    required this.accessToken,
  });
  Future<ServerInfoModel> getServerInfo(String email) async {
    try {
      Response response = await Dio().get(
        '$baseAddress/api/user_info/',
        queryParameters: {'email': email},
      );

      if (response.statusCode == 200) {
        return ServerInfoModel.fromJson(response.data);
      } else {
        throw Exception('Ошибка получения данных');
      }
    } catch (e) {
      print(e);
      throw Exception('Ошибка сети');
    }
  }
}
