// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_member_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 승인 대기 멤버의 승인·거절 액션을 UseCase에 위임한다.
///
/// 위젯이 `*_use_case_provider.dart`를 직접 읽지 않도록 하기 위한 계층이다.
/// (CLAUDE.md "Presentation → Domain 접근 규칙")

@ProviderFor(PendingMemberController)
final pendingMemberControllerProvider = PendingMemberControllerProvider._();

/// 승인 대기 멤버의 승인·거절 액션을 UseCase에 위임한다.
///
/// 위젯이 `*_use_case_provider.dart`를 직접 읽지 않도록 하기 위한 계층이다.
/// (CLAUDE.md "Presentation → Domain 접근 규칙")
final class PendingMemberControllerProvider
    extends $AsyncNotifierProvider<PendingMemberController, void> {
  /// 승인 대기 멤버의 승인·거절 액션을 UseCase에 위임한다.
  ///
  /// 위젯이 `*_use_case_provider.dart`를 직접 읽지 않도록 하기 위한 계층이다.
  /// (CLAUDE.md "Presentation → Domain 접근 규칙")
  PendingMemberControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingMemberControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingMemberControllerHash();

  @$internal
  @override
  PendingMemberController create() => PendingMemberController();
}

String _$pendingMemberControllerHash() =>
    r'5e0492ddec57f218e672c815180d6392564181a8';

/// 승인 대기 멤버의 승인·거절 액션을 UseCase에 위임한다.
///
/// 위젯이 `*_use_case_provider.dart`를 직접 읽지 않도록 하기 위한 계층이다.
/// (CLAUDE.md "Presentation → Domain 접근 규칙")

abstract class _$PendingMemberController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
