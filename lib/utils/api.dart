import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:magicscreen/utils/config.dart' as config;

final defaultTimeout = Duration(seconds: 60);
final defaultHeaders = {'Content-Type': 'application/json'};

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}

class API {
  static Uri _url(String path) {
    return Uri.parse(config.apiBaseUrl + path);
  }

  static BaseResponse<T> _parseResponse<T>(http.Response response) {
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse['code'] != config.apiCodeSuccess) {
        throw ApiException(jsonResponse?.message ?? '接口请求失败');
      }

      return BaseResponse<T>()
        ..code = jsonResponse['code']
        ..message = jsonResponse['message'] ?? jsonResponse['msg']
        ..data = jsonResponse['data'];
    } else {
      throw ApiException('网络请求失败');
    }
  }

  static Future<BaseResponse<T>> get<T>(String url) async {
    final response = await http.get(_url(url)).timeout(defaultTimeout);
    return _parseResponse<T>(response);
  }

  static Future<BaseResponse<T>> post<T>(String url, dynamic body) async {
    try {
      final response = await http
          .post(_url(url), body: jsonEncode(body), headers: defaultHeaders)
          .timeout(defaultTimeout);
      return _parseResponse<T>(response);
    } on ApiException catch (e) {
      rethrow;
    } catch (e) {
      throw ApiException('网络请求错误 $e');
    }
  }
}

class BaseResponse<T> {
  late String code;
  late String message;
  late T? data;
}
