// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_code_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 관리자의 초대 코드 발급 액션을 UseCase에 위임한다.
///
/// 위젯이 `*_use_case_provider.dart`를 직접 읽지 않도록 하기 위한 계층이다.
/// (CLAUDE.md "Presentation → Domain 접근 규칙")

@ProviderFor(InviteCodeController)
final inviteCodeControllerProvider = InviteCodeControllerProvider._();

/// 관리자의 초대 코드 발급 액션을 UseCase에 위임한다.
///
/// 위젯이 `*_use_case_provider.dart`를 직접 읽지 않도록 하기 위한 계층이다.
/// (CLAUDE.md "Presentation → Domain 접근 규칙")
final class InviteCodeControllerProvider
    extends $AsyncNotifierProvider<InviteCodeController, InviteInfo?> {
  /// 관리자의 초대 코드 발급 액션을 UseCase에 위임한다.
  ///
  /// 위젯이 `*_use_case_provider.dart`를 직접 읽지 않도록 하기 위한 계층이다.
  /// (CLAUDE.md "Presentation → Domain 접근 규칙")
  InviteCodeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inviteCodeControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inviteCodeControllerHash();

  @$internal
  @override
  InviteCodeController create() => InviteCodeController();
}

String _$inviteCodeControllerHash() =>
    r'df85ff07fcbd503bad777f22c5ef7bbf1d135fff';

/// 관리자의 초대 코드 발급 액션을 UseCase에 위임한다.
///
/// 위젯이 `*_use_case_provider.dart`를 직접 읽지 않도록 하기 위한 계층이다.
/// (CLAUDE.md "Presentation → Domain 접근 규칙")

abstract class _$InviteCodeController extends $AsyncNotifier<InviteInfo?> {
  FutureOr<InviteInfo?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<InviteInfo?>, InviteInfo?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<InviteInfo?>, InviteInfo?>,
              AsyncValue<InviteInfo?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
