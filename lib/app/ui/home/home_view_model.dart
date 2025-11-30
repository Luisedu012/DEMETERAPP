import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:demeterapp/app/core/providers/core_providers.dart';
import 'package:demeterapp/app/core/providers/auth_provider.dart';
import 'package:demeterapp/app/core/exceptions/api_exception.dart';

part 'home_view_model.g.dart';

enum HomeStatus { initial, loading, loaded, empty, error }

class ClassificationItem {
  final int id;
  final String grainType;
  final double confidence;
  final String? thumbnailUrl;

  ClassificationItem({
    required this.id,
    required this.grainType,
    required this.confidence,
    this.thumbnailUrl,
  });
}

class HomeState {
  final HomeStatus status;
  final String userName;
  final List<ClassificationItem> classifications;
  final String? errorMessage;

  HomeState({
    required this.status,
    required this.userName,
    required this.classifications,
    this.errorMessage,
  });

  HomeState.initial()
      : status = HomeStatus.initial,
        userName = '',
        classifications = [],
        errorMessage = null;

  HomeState.loading()
      : status = HomeStatus.loading,
        userName = '',
        classifications = [],
        errorMessage = null;

  HomeState copyWith({
    HomeStatus? status,
    String? userName,
    List<ClassificationItem>? classifications,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      userName: userName ?? this.userName,
      classifications: classifications ?? this.classifications,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class HomeViewModel extends _$HomeViewModel {
  @override
  HomeState build() {
    loadData();
    return HomeState.initial();
  }

  Future<void> loadData() async {
    state = HomeState.loading();

    try {
      // Buscar dados do usuário
      final authState = ref.read(authProvider);
      final userName = authState.user?.name ?? 'Usuário';

      // Buscar classificações recentes
      final repository = ref.read(classificationRepositoryProvider);
      final classifications = await repository.getRecentClassifications(limit: 5);

      final items = classifications
          .map((c) => ClassificationItem(
                id: c.id,
                grainType: c.grainType,
                confidence: c.confidenceScore ?? 0.0,
              ))
          .toList();

      if (items.isEmpty) {
        state = HomeState(
          status: HomeStatus.empty,
          userName: userName,
          classifications: [],
        );
      } else {
        state = HomeState(
          status: HomeStatus.loaded,
          userName: userName,
          classifications: items,
        );
      }
    } on ApiException catch (e) {
      final authState = ref.read(authProvider);
      state = HomeState(
        status: HomeStatus.error,
        userName: authState.user?.name ?? '',
        classifications: [],
        errorMessage: e.userFriendlyMessage,
      );
    } catch (e) {
      final authState = ref.read(authProvider);
      state = HomeState(
        status: HomeStatus.error,
        userName: authState.user?.name ?? '',
        classifications: [],
        errorMessage: 'Erro ao carregar dados',
      );
    }
  }

  Future<void> refresh() async {
    await loadData();
  }
}
