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

      print('🔍 DIAGNÓSTICO - Resposta do Backend (createClassification):');
      print('📦 response.data completo: ${response.data}');
      print('📝 grain_type recebido: ${response.data['grain_type']}');
      print('📊 confidence_score recebido: ${response.data['confidence_score']}');
      print('📂 extra_data recebido: ${response.data['extra_data']}');

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

      print('🔍 DIAGNÓSTICO - Resposta do Backend (getClassifications):');
      final List<dynamic> data = response.data['items'] ?? response.data;
      print('📊 Total de itens recebidos: ${data.length}');
      if (data.isNotEmpty) {
        print('📝 Primeiro item grain_type: ${data[0]['grain_type']}');
        print('📦 Primeiro item completo: ${data[0]}');
      }

      return data.map((json) => ClassificationModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Busca uma classificação específica por ID
  Future<ClassificationModel> getClassificationById(int id) async {
    try {
      final response = await _apiClient.get('/api/v1/classifications/$id');

      print('🔍 DIAGNÓSTICO - Resposta do Backend (getClassificationById $id):');
      print('📦 response.data completo: ${response.data}');
      print('📝 grain_type recebido: ${response.data['grain_type']}');
      print('📊 confidence_score recebido: ${response.data['confidence_score']}');
      print('📂 extra_data recebido: ${response.data['extra_data']}');

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
