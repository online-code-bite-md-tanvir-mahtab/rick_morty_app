import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(baseUrl: "https://rickandmortyapi.com/api/"),
  );

  Future<Response> getCharacters(int page) async {
    return await _dio.get("character", queryParameters: {"page": page});
  }
}
