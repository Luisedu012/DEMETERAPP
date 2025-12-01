import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:demeterapp/app/core/providers/core_providers.dart';
import 'package:demeterapp/app/core/providers/auth_provider.dart';
import 'package:demeterapp/app/data/repositories/user_repository.dart';
import 'package:demeterapp/app/core/exceptions/api_exception.dart';

part 'edit_profile_view_model.g.dart';

enum EditProfileStatus {
  initial,
  editing,
  saving,
  saved,
  error,
}

class EditProfileState {
  final EditProfileStatus status;
  final String name;
  final String email;
  final String phone;
  final String? errorMessage;

  EditProfileState({
    required this.status,
    required this.name,
    required this.email,
    required this.phone,
    this.errorMessage,
  });

  EditProfileState.initial()
      : status = EditProfileStatus.initial,
        name = '',
        email = '',
        phone = '',
        errorMessage = null;

  EditProfileState copyWith({
    EditProfileStatus? status,
    String? name,
    String? email,
    String? phone,
    String? errorMessage,
  }) {
    return EditProfileState(
      status: status ?? this.status,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      errorMessage: errorMessage,
    );
  }
}

@riverpod
class EditProfileViewModel extends _$EditProfileViewModel {
  late UserRepository _userRepository;

  @override
  EditProfileState build() {
    _userRepository = ref.read(userRepositoryProvider);

    final authState = ref.read(authProvider);

    if (authState.user != null) {
      return EditProfileState(
        status: EditProfileStatus.editing,
        name: authState.user!.name,
        email: authState.user!.email,
        phone: authState.user!.phone,
      );
    }

    return EditProfileState.initial();
  }

  Future<void> updateProfile(String name, String phone) async {
    state = state.copyWith(status: EditProfileStatus.saving);

    try {
      await _userRepository.updateProfile(
        name: name,
        phone: phone,
      );

      await ref.read(authProvider.notifier).reloadUser();

      state = state.copyWith(
        status: EditProfileStatus.saved,
        name: name,
        phone: phone,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        status: EditProfileStatus.error,
        errorMessage: e.userFriendlyMessage,
      );
    } catch (e) {
      state = state.copyWith(
        status: EditProfileStatus.error,
        errorMessage: 'Erro ao atualizar perfil',
      );
    }
  }

  Future<void> changePassword(String newPassword) async {
    state = state.copyWith(status: EditProfileStatus.saving);

    try {
      await _userRepository.changePassword(newPassword: newPassword);

      state = state.copyWith(status: EditProfileStatus.saved);
    } on ApiException catch (e) {
      state = state.copyWith(
        status: EditProfileStatus.error,
        errorMessage: e.userFriendlyMessage,
      );
    } catch (e) {
      state = state.copyWith(
        status: EditProfileStatus.error,
        errorMessage: 'Erro ao alterar senha',
      );
    }
  }
}
