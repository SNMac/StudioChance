// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'holiday_use_case_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(holidayUseCase)
final holidayUseCaseProvider = HolidayUseCaseProvider._();

final class HolidayUseCaseProvider
    extends $FunctionalProvider<HolidayUseCase, HolidayUseCase, HolidayUseCase>
    with $Provider<HolidayUseCase> {
  HolidayUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'holidayUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$holidayUseCaseHash();

  @$internal
  @override
  $ProviderElement<HolidayUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HolidayUseCase create(Ref ref) {
    return holidayUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HolidayUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HolidayUseCase>(value),
    );
  }
}

String _$holidayUseCaseHash() => r'c95a7adfe1691205ad61bb0053421a4342e8e225';
