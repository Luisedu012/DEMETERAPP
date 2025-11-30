import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:demeterapp/app/core/providers/auth_provider.dart';

part 'login_view_model.g.dart';

enum LoginStatus { initial, loading, success, error }

class LoginState {
  final LoginStatus status;
  final String? errorMessage;

  LoginState({
    required this.status,
    this.errorMessage,
  });

  LoginState.initial()
      : status = LoginStatus.initial,
        errorMessage = null;

  LoginState.loading()
      : status = LoginStatus.loading,
        errorMessage = null;

  LoginState.success()
      : status = LoginStatus.success,
        errorMessage = null;

  LoginState.error(String message)
      : status = LoginStatus.error,
        errorMessage = message;
}

@riverpod
class LoginViewModel extends _$LoginViewModel {
  @override
  LoginState build() {
    return LoginState.initial();
  }

  Future<void> login(String email, String password) async {
    state = LoginState.loading();

    try {
      final authNotifier = ref.read(authProvider.notifier);
      final success = await authNotifier.login(
        email: email,
        password: password,
      );

      // ✅ PROTEÇÃO: Verificar se provider ainda está montado após await
      if (!ref.mounted) return;

      if (success) {
        state = LoginState.success();
      } else {
        final authState = ref.read(authProvider);
        state = LoginState.error(
          authState.errorMessage ?? 'Erro ao fazer login',
        );
      }
    } catch (e) {
      // ✅ PROTEÇÃO: Verificar se provider ainda está montado
      if (!ref.mounted) return;

      state = LoginState.error('Erro ao fazer login. Tente novamente.');
    }
  }

  void resetState() {
    state = LoginState.initial();
  }
}
