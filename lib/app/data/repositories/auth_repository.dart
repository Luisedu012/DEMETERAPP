import 'package:dio/dio.dart';
import 'package:demeterapp/app/core/rest_client/api_client.dart';
import 'package:demeterapp/app/core/exceptions/api_exception.dart';
import 'package:demeterapp/app/data/services/token_storage_service.dart';
import 'package:demeterapp/app/data/models/auth/auth_response.dart';
import 'package:demeterapp/app/data/models/auth/login_request.dart';
import 'package:demeterapp/app/data/models/auth/register_request.dart';
import 'package:demeterapp/app/data/models/auth/user_model.dart';
import 'package:demeterapp/app/data/models/auth/tokens_model.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final TokenStorageService _tokenStorage;

  AuthRepository({
    required ApiClient apiClient,
    required TokenStorageService tokenStorage,
  }) : _apiClient = apiClient,
       _tokenStorage = tokenStorage;

  /// Registra um novo usuário
  Future<UserModel> register(RegisterRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/auth/register',
        data: request.toJson(),
      );

      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Realiza login do usuário
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/auth/login',
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data);

      await _tokenStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        tokenType: authResponse.tokenType,
      );

      return authResponse;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Atualiza o access token usando o refresh token
  Future<TokensModel> refreshToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        throw ApiException(
          message: 'Refresh token não encontrado',
          statusCode: 401,
        );
      }

      final response = await _apiClient.post(
        '/api/v1/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final tokens = TokensModel.fromJson(response.data);

      await _tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        tokenType: tokens.tokenType,
      );

      return tokens;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Realiza logout do usuário
  Future<void> logout() async {
    try {
      await _apiClient.post('/api/v1/auth/logout');
    } catch (e) {
    } finally {
      await _tokenStorage.clearTokens();
    }
  }

  /// Obtém os dados do usuário atual
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/api/v1/users/me');
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Verifica se o usuário está autenticado
  Future<bool> isAuthenticated() async {
    return await _tokenStorage.hasValidToken();
  }

  /// Obtém o token de acesso atual
  Future<String?> getAccessToken() async {
    return await _tokenStorage.getAccessToken();
  }
}
