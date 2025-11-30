import 'dart:io';
import 'package:dio/dio.dart';
import 'package:demeterapp/app/core/rest_client/api_client.dart';
import 'package:demeterapp/app/core/exceptions/api_exception.dart';
import 'package:demeterapp/app/data/models/classification/classification_model.dart';

class ClassificationRepository {
  final ApiClient _apiClient;

  ClassificationRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  /// Cria uma nova classificação com upload de imagem
  Future<ClassificationModel> createClassification({
    required File image,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        ),
      });

      final response = await _apiClient.post(
        '/api/v1/classifications',
        data: formData,
      );

      return ClassificationModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Lista todas as classificações do usuário
  Future<List<ClassificationModel>> getClassifications({
    int? skip,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (skip != null) queryParams['skip'] = skip;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiClient.get(
        '/api/v1/classifications',
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['items'] ?? response.data;
      return data.map((json) => ClassificationModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Busca uma classificação específica por ID
  Future<ClassificationModel> getClassificationById(int id) async {
    try {
      final response = await _apiClient.get('/api/v1/classifications/$id');
      return ClassificationModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Deleta uma classificação (soft delete)
  Future<void> deleteClassification(int id) async {
    try {
      await _apiClient.delete('/api/v1/classifications/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Busca classificações recentes (para home)
  Future<List<ClassificationModel>> getRecentClassifications({
    int limit = 5,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/classifications',
        queryParameters: {'limit': limit},
      );

      final List<dynamic> data = response.data['items'] ?? response.data;
      return data.map((json) => ClassificationModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
