// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userUseCase)
final userUseCaseProvider = UserUseCaseProvider._();

final class UserUseCaseProvider
    extends $FunctionalProvider<UserUseCase, UserUseCase, UserUseCase>
    with $Provider<UserUseCase> {
  UserUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userUseCaseHash();

  @$internal
  @override
  $ProviderElement<UserUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserUseCase create(Ref ref) {
    return userUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserUseCase>(value),
    );
  }
}

String _$userUseCaseHash() => r'6a03516f4fdb896a4492752bedc0d22877524e2f';
