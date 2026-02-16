// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_code_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InviteCodeFormController)
final inviteCodeFormControllerProvider = InviteCodeFormControllerProvider._();

final class InviteCodeFormControllerProvider
    extends $NotifierProvider<InviteCodeFormController, InviteCodeFormState> {
  InviteCodeFormControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inviteCodeFormControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inviteCodeFormControllerHash();

  @$internal
  @override
  InviteCodeFormController create() => InviteCodeFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InviteCodeFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InviteCodeFormState>(value),
    );
  }
}

String _$inviteCodeFormControllerHash() =>
    r'eb388c23a82c2bed4d658de885947f8dc5d17592';

abstract class _$InviteCodeFormController
    extends $Notifier<InviteCodeFormState> {
  InviteCodeFormState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<InviteCodeFormState, InviteCodeFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<InviteCodeFormState, InviteCodeFormState>,
              InviteCodeFormState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
