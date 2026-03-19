// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nickname_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NicknameFormController)
final nicknameFormControllerProvider = NicknameFormControllerFamily._();

final class NicknameFormControllerProvider
    extends $NotifierProvider<NicknameFormController, NicknameFormState> {
  NicknameFormControllerProvider._({
    required NicknameFormControllerFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'nicknameFormControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$nicknameFormControllerHash();

  @override
  String toString() {
    return r'nicknameFormControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  NicknameFormController create() => NicknameFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NicknameFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NicknameFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NicknameFormControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$nicknameFormControllerHash() =>
    r'4e0caf7588faf4fec74be37654267caaf8c634e7';

final class NicknameFormControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          NicknameFormController,
          NicknameFormState,
          NicknameFormState,
          NicknameFormState,
          String?
        > {
  NicknameFormControllerFamily._()
    : super(
        retry: null,
        name: r'nicknameFormControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  NicknameFormControllerProvider call(String? initialValue) =>
      NicknameFormControllerProvider._(argument: initialValue, from: this);

  @override
  String toString() => r'nicknameFormControllerProvider';
}

abstract class _$NicknameFormController extends $Notifier<NicknameFormState> {
  late final _$args = ref.$arg as String?;
  String? get initialValue => _$args;

  NicknameFormState build(String? initialValue);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<NicknameFormState, NicknameFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NicknameFormState, NicknameFormState>,
              NicknameFormState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
