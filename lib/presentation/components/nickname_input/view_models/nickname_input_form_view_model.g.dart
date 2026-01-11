// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nickname_input_form_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NicknameInputFormViewModel)
final nicknameInputFormViewModelProvider = NicknameInputFormViewModelFamily._();

final class NicknameInputFormViewModelProvider
    extends
        $NotifierProvider<NicknameInputFormViewModel, NicknameInputFormState> {
  NicknameInputFormViewModelProvider._({
    required NicknameInputFormViewModelFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'nicknameInputFormViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$nicknameInputFormViewModelHash();

  @override
  String toString() {
    return r'nicknameInputFormViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  NicknameInputFormViewModel create() => NicknameInputFormViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NicknameInputFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NicknameInputFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NicknameInputFormViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$nicknameInputFormViewModelHash() =>
    r'692aa046d189c571aa52b11abd694de8cb10eda8';

final class NicknameInputFormViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          NicknameInputFormViewModel,
          NicknameInputFormState,
          NicknameInputFormState,
          NicknameInputFormState,
          String?
        > {
  NicknameInputFormViewModelFamily._()
    : super(
        retry: null,
        name: r'nicknameInputFormViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  NicknameInputFormViewModelProvider call(String? initialValue) =>
      NicknameInputFormViewModelProvider._(argument: initialValue, from: this);

  @override
  String toString() => r'nicknameInputFormViewModelProvider';
}

abstract class _$NicknameInputFormViewModel
    extends $Notifier<NicknameInputFormState> {
  late final _$args = ref.$arg as String?;
  String? get initialValue => _$args;

  NicknameInputFormState build(String? initialValue);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<NicknameInputFormState, NicknameInputFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NicknameInputFormState, NicknameInputFormState>,
              NicknameInputFormState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
