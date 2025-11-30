import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:demeterapp/app/core/providers/auth_provider.dart';

part 'register_view_model.g.dart';

enum RegisterStatus { initial, loading, success, error }

enum PasswordStrength { weak, medium, strong }

class RegisterState {
  final RegisterStatus status;
  final String? errorMessage;
  final PasswordStrength? passwordStrength;

  RegisterState({
    required this.status,
    this.errorMessage,
    this.passwordStrength,
  });

  RegisterState.initial()
    : status = RegisterStatus.initial,
      errorMessage = null,
      passwordStrength = null;

  RegisterState.loading()
    : status = RegisterStatus.loading,
      errorMessage = null,
      passwordStrength = null;

  RegisterState.success()
    : status = RegisterStatus.success,
      errorMessage = null,
      passwordStrength = null;

  RegisterState.error(String message)
    : status = RegisterStatus.error,
      errorMessage = message,
      passwordStrength = null;

  RegisterState copyWith({
    RegisterStatus? status,
    String? errorMessage,
    PasswordStrength? passwordStrength,
  }) {
    return RegisterState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      passwordStrength: passwordStrength ?? this.passwordStrength,
    );
  }
}

@riverpod
class RegisterViewModel extends _$RegisterViewModel {
  @override
  RegisterState build() {
    return RegisterState.initial();
  }

  String _sanitizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = RegisterState.loading();

    try {
      final authNotifier = ref.read(authProvider.notifier);

      final sanitizedPhone = _sanitizePhone(phone);

      if (sanitizedPhone.length != 11) {
        state = RegisterState.error('Telefone inválido');
        return;
      }

      final success = await authNotifier.register(
        name: name,
        email: email,
        phone: sanitizedPhone,
        password: password,
      );

      // ✅ PROTEÇÃO: Verificar se provider ainda está montado após await
      if (!ref.mounted) return;

      if (success) {
        state = RegisterState.success();
      } else {
        final authState = ref.read(authProvider);
        state = RegisterState.error(
          authState.errorMessage ?? 'Erro ao registrar',
        );
      }
    } catch (e) {
      // ✅ PROTEÇÃO: Verificar se provider ainda está montado
      if (!ref.mounted) return;

      state = RegisterState.error('Erro ao registrar. Tente novamente.');
    }
  }

  PasswordStrength validatePasswordStrength(String password) {
    if (password.isEmpty) {
      return PasswordStrength.weak;
    }

    int strength = 0;

    if (password.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;

    if (strength <= 2) {
      return PasswordStrength.weak;
    } else if (strength <= 4) {
      return PasswordStrength.medium;
    } else {
      return PasswordStrength.strong;
    }
  }

  void updatePasswordStrength(String password) {
    final strength = validatePasswordStrength(password);
    state = state.copyWith(passwordStrength: strength);
  }

  void resetState() {
    state = RegisterState.initial();
  }
}
