import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class CustomLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('╔════════════════════════════════════════════════════════════════');
      print('║ 🚀 REQUEST');
      print('║ Method: ${options.method}');
      print('║ URL: ${options.uri}');
      print('║ Headers: ${options.headers}');
      if (options.data != null) {
        print('║ Body: ${options.data}');
      }
      if (options.queryParameters.isNotEmpty) {
        print('║ Query: ${options.queryParameters}');
      }
      print('╚════════════════════════════════════════════════════════════════');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('╔════════════════════════════════════════════════════════════════');
      print('║ ✅ RESPONSE');
      print('║ Status Code: ${response.statusCode}');
      print('║ URL: ${response.requestOptions.uri}');
      print('║ Data: ${response.data}');
      print('╚════════════════════════════════════════════════════════════════');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('╔════════════════════════════════════════════════════════════════');
      print('║ ❌ ERROR');
      print('║ Type: ${err.type}');
      print('║ URL: ${err.requestOptions.uri}');
      print('║ Status Code: ${err.response?.statusCode}');
      print('║ Message: ${err.message}');
      if (err.response?.data != null) {
        print('║ Response: ${err.response?.data}');
      }
      print('╚════════════════════════════════════════════════════════════════');
    }
    super.onError(err, handler);
  }
}
