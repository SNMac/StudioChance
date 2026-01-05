// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authUseCase)
final authUseCaseProvider = AuthUseCaseProvider._();

final class AuthUseCaseProvider
    extends $FunctionalProvider<AuthUseCase, AuthUseCase, AuthUseCase>
    with $Provider<AuthUseCase> {
  AuthUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authUseCaseHash();

  @$internal
  @override
  $ProviderElement<AuthUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthUseCase create(Ref ref) {
    return authUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthUseCase>(value),
    );
  }
}

String _$authUseCaseHash() => r'9b9f1c76259cd0374b1472a1b0d1bd559357c76f';
