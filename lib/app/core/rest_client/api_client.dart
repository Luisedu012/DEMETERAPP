import 'package:dio/dio.dart';
import 'package:demeterapp/app/core/rest_client/interceptors/auth_interceptor.dart';
import 'package:demeterapp/app/core/rest_client/interceptors/error_interceptor.dart';
import 'package:demeterapp/app/core/rest_client/interceptors/log_interceptor.dart'
    as custom;
import 'package:demeterapp/app/data/services/token_storage_service.dart';

class ApiClient {
  late final Dio _dio;
  final TokenStorageService _tokenStorage;

  ApiClient({
    required String baseUrl,
    required TokenStorageService tokenStorage,
    int connectTimeout = 60000,
    int receiveTimeout = 60000,
    int sendTimeout = 60000,
  }) : _tokenStorage = tokenStorage {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(milliseconds: connectTimeout),
        receiveTimeout: Duration(milliseconds: receiveTimeout),
        sendTimeout: Duration(milliseconds: sendTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      custom.CustomLogInterceptor(),
      AuthInterceptor(_tokenStorage),
      ErrorInterceptor(),
    ]);
  }

  Dio get dio => _dio;

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}
