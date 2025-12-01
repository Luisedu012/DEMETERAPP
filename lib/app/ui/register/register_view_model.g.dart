// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RegisterViewModel)
const registerViewModelProvider = RegisterViewModelProvider._();

final class RegisterViewModelProvider
    extends $NotifierProvider<RegisterViewModel, RegisterState> {
  const RegisterViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'registerViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$registerViewModelHash();

  @$internal
  @override
  RegisterViewModel create() => RegisterViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RegisterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RegisterState>(value),
    );
  }
}

String _$registerViewModelHash() => r'3fd4e6e31ec8489331ca50e3bffa1b864a83ad5f';

abstract class _$RegisterViewModel extends $Notifier<RegisterState> {
  RegisterState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<RegisterState, RegisterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RegisterState, RegisterState>,
              RegisterState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
