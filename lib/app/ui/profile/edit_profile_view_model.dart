import 'package:riverpod_annotation/riverpod_annotation.dart';

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
  @override
  EditProfileState build() {
    loadProfile();
    return EditProfileState.initial();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(status: EditProfileStatus.initial);

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      state = state.copyWith(
        status: EditProfileStatus.editing,
        name: 'Luis Eduardo Rodrigues',
        email: 'exemplo@gmail.com',
        phone: '+24500000000',
      );
    } catch (e) {
      state = state.copyWith(
        status: EditProfileStatus.error,
        errorMessage: 'Erro ao carregar perfil',
      );
    }
  }

  Future<void> updateProfile(String name, String phone) async {
    state = state.copyWith(status: EditProfileStatus.saving);

    try {
      await Future.delayed(const Duration(milliseconds: 1000));

      state = state.copyWith(
        status: EditProfileStatus.saved,
        name: name,
        phone: phone,
      );
    } catch (e) {
      state = state.copyWith(
        status: EditProfileStatus.error,
        errorMessage: 'Erro ao atualizar perfil',
      );
    }
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    state = state.copyWith(status: EditProfileStatus.saving);

    try {
      await Future.delayed(const Duration(milliseconds: 1000));

      state = state.copyWith(status: EditProfileStatus.saved);
    } catch (e) {
      state = state.copyWith(
        status: EditProfileStatus.error,
        errorMessage: 'Erro ao alterar senha',
      );
    }
  }
}
