// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_code_verification_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InviteCodeVerificationController)
final inviteCodeVerificationControllerProvider =
    InviteCodeVerificationControllerProvider._();

final class InviteCodeVerificationControllerProvider
    extends
        $NotifierProvider<
          InviteCodeVerificationController,
          InviteCodeVerificationState
        > {
  InviteCodeVerificationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inviteCodeVerificationControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inviteCodeVerificationControllerHash();

  @$internal
  @override
  InviteCodeVerificationController create() =>
      InviteCodeVerificationController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InviteCodeVerificationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InviteCodeVerificationState>(value),
    );
  }
}

String _$inviteCodeVerificationControllerHash() =>
    r'dd3b322f18426c21cef34e56b54c86e7d068a30c';

abstract class _$InviteCodeVerificationController
    extends $Notifier<InviteCodeVerificationState> {
  InviteCodeVerificationState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<InviteCodeVerificationState, InviteCodeVerificationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                InviteCodeVerificationState,
                InviteCodeVerificationState
              >,
              InviteCodeVerificationState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
