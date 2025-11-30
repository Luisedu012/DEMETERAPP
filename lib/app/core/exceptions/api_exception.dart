import 'package:dio/dio.dart';
import 'package:demeterapp/app/data/models/common/api_error.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final ApiError? apiError;
  final dynamic originalError;

  ApiException({
    required this.message,
    this.statusCode,
    this.apiError,
    this.originalError,
  });

  factory ApiException.fromDioException(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      String message;

      try {
        if (data is Map<String, dynamic>) {
          // Tentar campo 'detail' primeiro (padrão FastAPI)
          if (data.containsKey('detail')) {
            message = data['detail'] is String
                ? data['detail']
                : data['detail']?['message'] ?? 'Erro desconhecido';
          }
          // Fallback: tentar campo 'message'
          else if (data.containsKey('message')) {
            message = data['message'];
          }
          // Fallback: tentar parsear como ApiError
          else {
            final apiError = ApiError.fromJson(data);
            message = apiError.message;
          }
        } else {
          message = data?.toString() ?? 'Erro desconhecido';
        }
      } catch (e) {
        message = 'Erro ao processar resposta do servidor';
      }

      return ApiException(
        message: message,
        statusCode: statusCode,
        originalError: error,
      );
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return ApiException(
        message: 'Tempo de conexão esgotado. Verifique sua internet.',
        statusCode: null,
        originalError: error,
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      return ApiException(
        message: 'Erro de conexão. Verifique sua internet.',
        statusCode: null,
        originalError: error,
      );
    }

    return ApiException(
      message: error.message ?? 'Erro desconhecido',
      statusCode: null,
      originalError: error,
    );
  }

  String get userFriendlyMessage {
    switch (statusCode) {
      case 400:
      case 422:
        return message;
      case 401:
        return 'Sessão expirada. Faça login novamente.';
      case 403:
        return 'Você não tem permissão para esta ação.';
      case 404:
        return 'Recurso não encontrado.';
      case 409:
        return message;
      case 500:
      case 502:
      case 503:
        return 'Erro no servidor. Tente novamente mais tarde.';
      default:
        if (statusCode == null) {
          return message;
        }
        return message;
    }
  }

  bool get isNetworkError => statusCode == null;

  bool get isUnauthorized => statusCode == 401;

  bool get isForbidden => statusCode == 403;

  bool get isNotFound => statusCode == 404;

  bool get isValidationError => statusCode == 400 || statusCode == 422;

  bool get isServerError =>
      statusCode != null && statusCode! >= 500 && statusCode! < 600;

  @override
  String toString() {
    return 'ApiException(message: $message, statusCode: $statusCode, apiError: $apiError)';
  }
}
