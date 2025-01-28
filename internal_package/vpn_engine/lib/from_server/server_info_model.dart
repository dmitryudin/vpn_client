// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dio/dio.dart';
import 'package:vpn_engine/from_server/api_server/models/root_model.dart';

class ServerRepository {
  String baseAddress;
  String accessToken;
  ServerRepository({
    required this.baseAddress,
    required this.accessToken,
  });
  Future<RootHttpModel> getServerInfo(String email) async {
    try {
      print('Token $accessToken');
      Response response = await Dio().get('$baseAddress/api/user_info/',
          queryParameters: {'email': email},
          options: Options(
            headers: <String, String>{'authorization': 'Token $accessToken'},
          ));

      if (response.statusCode == 200) {
        return RootHttpModel.fromJson(response.data);
      } else {
        throw Exception('Ошибка получения данных');
      }
    } catch (e) {
      print(e);
      throw Exception('Ошибка сети');
    }
  }
}
