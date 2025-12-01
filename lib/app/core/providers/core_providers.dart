import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:demeterapp/app/core/config/env.dart';
import 'package:demeterapp/app/core/rest_client/api_client.dart';
import 'package:demeterapp/app/data/services/token_storage_service.dart';
import 'package:demeterapp/app/data/repositories/auth_repository.dart';
import 'package:demeterapp/app/data/repositories/classification_repository.dart';
import 'package:demeterapp/app/data/repositories/user_repository.dart';

final tokenStorageServiceProvider = Provider<TokenStorageService>((ref) {
  return TokenStorageService();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageServiceProvider);

  return ApiClient(
    baseUrl: Env.apiBaseUrl,
    tokenStorage: tokenStorage,
    connectTimeout: Env.apiTimeout,
    receiveTimeout: Env.apiTimeout,
    sendTimeout: Env.apiTimeout,
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final tokenStorage = ref.watch(tokenStorageServiceProvider);

  return AuthRepository(apiClient: apiClient, tokenStorage: tokenStorage);
});

final classificationRepositoryProvider = Provider<ClassificationRepository>((
  ref,
) {
  final apiClient = ref.watch(apiClientProvider);

  return ClassificationRepository(apiClient: apiClient);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  return UserRepository(apiClient: apiClient);
});
