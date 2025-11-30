import 'package:demeterapp/app/core/providers/core_providers.dart';
import 'package:demeterapp/app/core/exceptions/api_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InfrastructureTest {
  static Future<void> testTokenStorage(WidgetRef ref) async {
    print('\n=== TESTE: TOKEN STORAGE ===');

    final tokenStorage = ref.read(tokenStorageServiceProvider);

    print('1. Salvando tokens...');
    await tokenStorage.saveTokens(
      accessToken: 'test_access_token_123',
      refreshToken: 'test_refresh_token_456',
    );
    print('✅ Tokens salvos');

    print('2. Recuperando access token...');
    final accessToken = await tokenStorage.getAccessToken();
    print('✅ Access Token: $accessToken');

    print('3. Verificando token válido...');
    final hasValidToken = await tokenStorage.hasValidToken();
    print('✅ Has Valid Token: $hasValidToken');

    print('4. Limpando tokens...');
    await tokenStorage.clearTokens();
    print('✅ Tokens limpos');

    print('5. Verificando após limpar...');
    final afterClear = await tokenStorage.hasValidToken();
    print('✅ After Clear: $afterClear');

    print('=== TESTE CONCLUÍDO ===\n');
  }

  static Future<void> testApiClientHealthCheck(WidgetRef ref) async {
    print('\n=== TESTE: API CLIENT - HEALTH CHECK ===');

    final apiClient = ref.read(apiClientProvider);

    try {
      print('1. Chamando GET /health...');
      final response = await apiClient.dio.get('http://localhost:8000/health');

      print('✅ Status: ${response.statusCode}');
      print('✅ Data: ${response.data}');
      print('=== TESTE CONCLUÍDO ===\n');
    } on DioException catch (e) {
      final apiException = e.error as ApiException;
      print('❌ Erro: ${apiException.userFriendlyMessage}');
      print('   Status Code: ${apiException.statusCode}');
      print('=== TESTE FALHOU ===\n');
    }
  }

  static Future<void> testApiClientRegister(WidgetRef ref) async {
    print('\n=== TESTE: API CLIENT - REGISTER ===');

    final apiClient = ref.read(apiClientProvider);

    try {
      print('1. Chamando POST /api/v1/auth/register...');
      final response = await apiClient.post(
        '/api/v1/auth/register',
        data: {
          'email':
              'test.user${DateTime.now().millisecondsSinceEpoch}@demeter.com',
          'name': 'Test User Infrastructure',
          'phone': '11987654321',
          'password': 'Test123!',
          'password_confirm': 'Test123!',
        },
      );

      print('✅ Status: ${response.statusCode}');
      print('✅ User criado: ${response.data}');
      print('=== TESTE CONCLUÍDO ===\n');
    } on DioException catch (e) {
      final apiException = e.error as ApiException;
      print('❌ Erro: ${apiException.userFriendlyMessage}');
      print('   Status Code: ${apiException.statusCode}');

      if (apiException.statusCode == 409) {
        print('   (Email já cadastrado - normal em testes repetidos)');
      }

      print('=== TESTE FALHOU ===\n');
    }
  }

  static Future<void> testApiClientLogin(WidgetRef ref) async {
    print('\n=== TESTE: API CLIENT - LOGIN ===');

    final apiClient = ref.read(apiClientProvider);
    final tokenStorage = ref.read(tokenStorageServiceProvider);

    try {
      print('1. Chamando POST /api/v1/auth/login...');
      final response = await apiClient.post(
        '/api/v1/auth/login',
        data: {'email': 'usuario.teste@gmail.com', 'password': 'Senha123!'},
      );

      print('✅ Status: ${response.statusCode}');
      print('✅ User: ${response.data['user']['name']}');
      print('✅ Email: ${response.data['user']['email']}');

      final accessToken = response.data['access_token'];
      final refreshToken = response.data['refresh_token'];

      print('2. Salvando tokens...');
      await tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      print('✅ Tokens salvos');

      print('3. Testando endpoint autenticado GET /api/v1/users/me...');
      final meResponse = await apiClient.get('/api/v1/users/me');
      print('✅ Dados do usuário: ${meResponse.data}');

      print('=== TESTE CONCLUÍDO ===\n');
    } on DioException catch (e) {
      final apiException = e.error as ApiException;
      print('❌ Erro: ${apiException.userFriendlyMessage}');
      print('   Status Code: ${apiException.statusCode}');
      print('=== TESTE FALHOU ===\n');
    }
  }

  static Future<void> runAllTests(WidgetRef ref) async {
    print('\n');
    print('╔════════════════════════════════════════════════════════════════');
    print('║   DEMETER - TESTE DE INFRAESTRUTURA (FASE 01)');
    print('╚════════════════════════════════════════════════════════════════');
    print('\n');

    await testTokenStorage(ref);
    await testApiClientHealthCheck(ref);
    await testApiClientRegister(ref);
    await testApiClientLogin(ref);

    print('╔════════════════════════════════════════════════════════════════');
    print('║   TODOS OS TESTES FINALIZADOS');
    print('╚════════════════════════════════════════════════════════════════');
    print('\n');
  }
}
