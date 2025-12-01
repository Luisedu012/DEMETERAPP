import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:demeterapp/app/core/providers/core_providers.dart';
import 'package:demeterapp/app/data/repositories/auth_repository.dart';
import 'package:demeterapp/app/data/models/auth/user_model.dart';
import 'package:demeterapp/app/data/models/auth/login_request.dart';
import 'package:demeterapp/app/data/models/auth/register_request.dart';
import 'package:demeterapp/app/core/exceptions/api_exception.dart';

part 'auth_provider.g.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  AuthState.initial()
      : status = AuthStatus.initial,
        user = null,
        errorMessage = null;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error;
}

@riverpod
class Auth extends _$Auth {
  late AuthRepository _authRepository;

  @override
  AuthState build() {
    _authRepository = ref.read(authRepositoryProvider);
    _checkAuthentication();
    return AuthState.initial();
  }

  /// Verifica se o usuário está autenticado ao iniciar o app
  Future<void> _checkAuthentication() async {
    try {
      final isAuthenticated = await _authRepository.isAuthenticated();

      if (isAuthenticated) {
        // Buscar dados do usuário
        final user = await _authRepository.getCurrentUser();

        // ✅ PROTEÇÃO: Verificar se provider ainda está montado após await
        if (!ref.mounted) return;

        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
        // ✅ PROTEÇÃO: Verificar se provider ainda está montado
        if (!ref.mounted) return;

        state = state.copyWith(
          status: AuthStatus.unauthenticated,
        );
      }
    } catch (e) {
      // ✅ PROTEÇÃO: Verificar se provider ainda está montado
      if (!ref.mounted) return;

      state = state.copyWith(
        status: AuthStatus.unauthenticated,
      );
    }
  }

  /// Realiza login do usuário
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔵 LOGIN - Iniciando login para: $email');
      print('🔵 LOGIN - ref.mounted = ${ref.mounted}');

      state = state.copyWith(status: AuthStatus.loading);

      final request = LoginRequest(email: email, password: password);
      print('🔵 LOGIN - Chamando API...');
      final authResponse = await _authRepository.login(request);
      print('🔵 LOGIN - API retornou sucesso!');
      print('🔵 LOGIN - ref.mounted após await = ${ref.mounted}');

      if (!ref.mounted) {
        print('🟡 LOGIN - Provider foi disposed, mas login teve sucesso');
        return true; // ✅ Login teve sucesso, mesmo que provider tenha sido disposed
      }

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: authResponse.user,
        errorMessage: null,
      );
      print('🟢 LOGIN - Estado atualizado para authenticated');

      return true;
    } on ApiException catch (e) {
      print('🔴 LOGIN - ApiException: ${e.message}');
      if (ref.mounted) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: e.userFriendlyMessage,
        );
      }
      return false;
    } catch (e) {
      print('🔴 LOGIN - Exception: $e');
      if (ref.mounted) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Erro ao fazer login. Tente novamente.',
        );
      }
      return false;
    }
  }

  /// Registra um novo usuário e faz login automaticamente
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      if (!ref.mounted) return false;
      state = state.copyWith(status: AuthStatus.loading);

      final request = RegisterRequest(
        name: name,
        email: email,
        phone: phone,
        password: password,
        confirmPassword: password,
      );

      // Tenta registrar
      await _authRepository.register(request);

      // Registro OK! Agora tenta login automático
      if (!ref.mounted) return true; // Registro foi bem-sucedido
      final loginSuccess = await login(email: email, password: password);

      if (!loginSuccess) {
        // Registro deu certo, mas o login falhou
        if (!ref.mounted) return true;
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Conta criada com sucesso! Faça login para continuar.',
        );
        return true; // Registro foi bem-sucedido, mas login falhou
      }

      return true; // Registro e login bem-sucedidos
    } on ApiException catch (e) {
      // Erro no REGISTRO (não no login)
      if (!ref.mounted) return false;
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.userFriendlyMessage,
      );
      return false;
    } catch (e) {
      // Erro genérico no REGISTRO
      if (!ref.mounted) return false;
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Erro ao registrar. Tente novamente.',
      );
      return false;
    }
  }

  /// Realiza logout do usuário
  Future<void> logout() async {
    try {
      await _authRepository.logout();
    } catch (e) {
      // Continua logout mesmo com erro
    } finally {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        errorMessage: null,
      );
    }
  }

  /// Atualiza o token de acesso
  Future<void> refreshToken() async {
    try {
      await _authRepository.refreshToken();
    } catch (e) {
      // Se falhar, desloga o usuário
      await logout();
    }
  }

  /// Limpa o erro
  void clearError() {
    if (state.hasError) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: null,
      );
    }
  }

  /// Recarrega os dados do usuário da API
  Future<void> reloadUser() async {
    try {
      final user = await _authRepository.getCurrentUser();

      if (!ref.mounted) return;

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
    } catch (e) {
      // Mantém usuário atual em caso de erro
    }
  }
}
