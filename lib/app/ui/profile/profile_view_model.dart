import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:demeterapp/app/core/providers/auth_provider.dart';

part 'profile_view_model.g.dart';

enum ProfileStatus {
  loading,
  loaded,
  loggingOut,
  error,
}

class UserProfile {
  final int id;
  final String name;
  final String phone;
  final String email;
  final bool isVerified;

  UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.isVerified,
  });
}

class ProfileState {
  final ProfileStatus status;
  final UserProfile? profile;
  final String? errorMessage;

  ProfileState({
    required this.status,
    this.profile,
    this.errorMessage,
  });

  ProfileState.initial()
      : status = ProfileStatus.loading,
        profile = null,
        errorMessage = null;

  ProfileState.loading()
      : status = ProfileStatus.loading,
        profile = null,
        errorMessage = null;

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
    );
  }
}

@riverpod
class ProfileViewModel extends _$ProfileViewModel {
  @override
  ProfileState build() {
    final authState = ref.watch(authProvider);

    if (authState.isLoading) {
      return ProfileState.loading();
    }

    if (authState.user != null) {
      final profile = UserProfile(
        id: authState.user!.id,
        name: authState.user!.name,
        phone: authState.user!.phone,
        email: authState.user!.email,
        isVerified: authState.user!.isVerified,
      );

      return ProfileState(
        status: ProfileStatus.loaded,
        profile: profile,
      );
    }

    return ProfileState(
      status: ProfileStatus.error,
      errorMessage: 'Usuário não autenticado',
    );
  }

  void refresh() {
    ref.invalidateSelf();
  }

  Future<void> logout() async {
    state = state.copyWith(status: ProfileStatus.loggingOut);

    try {
      await ref.read(authProvider.notifier).logout();
      // Navegação será tratada pela tela
    } catch (e) {
      state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'Erro ao fazer logout',
      );
    }
  }
}
