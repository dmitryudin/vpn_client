// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dio/dio.dart';

class ApiService {
  String accessToken;
  String baseAddress;
  ApiService({
    required this.accessToken,
    required this.baseAddress,
  });

  final Dio _dio = Dio();

  Future<Response> makeAuthenticatedRequest(
    String endpoint, {
    dynamic data,
    String method = 'GET',
  }) async {
    try {
      final options = Options(
        headers: <String, String>{'authorization': 'Token $accessToken'},
        method: method,
      );

      final response = await _dio.request(
        '$baseAddress$endpoint',
        data: data,
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        throw Exception('Ошибка запроса: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка при выполнении запроса: $e');
      throw Exception('Ошибка сети');
    }
  }
}
