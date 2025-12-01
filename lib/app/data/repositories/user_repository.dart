import 'package:dio/dio.dart';
import 'package:demeterapp/app/core/rest_client/api_client.dart';
import 'package:demeterapp/app/core/exceptions/api_exception.dart';
import 'package:demeterapp/app/data/models/auth/user_model.dart';

class UserRepository {
  final ApiClient _apiClient;

  UserRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Atualiza nome e telefone do usuário
  Future<UserModel> updateProfile({
    String? name,
    String? phone,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;

      final response = await _apiClient.patch(
        '/api/v1/users/me',
        data: data,
      );

      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Altera a senha do usuário
  Future<void> changePassword({
    required String newPassword,
  }) async {
    try {
      await _apiClient.patch(
        '/api/v1/users/me',
        data: {
          'password': newPassword,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
