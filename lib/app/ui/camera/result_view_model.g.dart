// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ResultViewModel)
const resultViewModelProvider = ResultViewModelProvider._();

final class ResultViewModelProvider
    extends $NotifierProvider<ResultViewModel, ResultState> {
  const ResultViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'resultViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$resultViewModelHash();

  @$internal
  @override
  ResultViewModel create() => ResultViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ResultState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ResultState>(value),
    );
  }
}

String _$resultViewModelHash() => r'dcbe9a1b2f9cc91d66a9276930cbb0d49def533e';

abstract class _$ResultViewModel extends $Notifier<ResultState> {
  ResultState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ResultState, ResultState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ResultState, ResultState>,
              ResultState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
