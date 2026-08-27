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
///
/// 발급된 코드 자체는 여기에 담지 않는다. 발급에 성공하면 점포 문서의
/// `inviteInfo`가 갱신되므로 `storeDetailProvider`가 유일한 출처가 된다.
/// 코드를 여기에도 들고 있으면 점포별로 분리되지 않은 두 번째 출처가 생겨,
/// 다른 점포 모달에 직전 점포의 코드가 새는 경로가 만들어진다.

@ProviderFor(InviteCodeController)
final inviteCodeControllerProvider = InviteCodeControllerProvider._();

/// 관리자의 초대 코드 발급 액션을 UseCase에 위임한다.
///
/// 위젯이 `*_use_case_provider.dart`를 직접 읽지 않도록 하기 위한 계층이다.
/// (CLAUDE.md "Presentation → Domain 접근 규칙")
///
/// 발급된 코드 자체는 여기에 담지 않는다. 발급에 성공하면 점포 문서의
/// `inviteInfo`가 갱신되므로 `storeDetailProvider`가 유일한 출처가 된다.
/// 코드를 여기에도 들고 있으면 점포별로 분리되지 않은 두 번째 출처가 생겨,
/// 다른 점포 모달에 직전 점포의 코드가 새는 경로가 만들어진다.
final class InviteCodeControllerProvider
    extends $AsyncNotifierProvider<InviteCodeController, void> {
  /// 관리자의 초대 코드 발급 액션을 UseCase에 위임한다.
  ///
  /// 위젯이 `*_use_case_provider.dart`를 직접 읽지 않도록 하기 위한 계층이다.
  /// (CLAUDE.md "Presentation → Domain 접근 규칙")
  ///
  /// 발급된 코드 자체는 여기에 담지 않는다. 발급에 성공하면 점포 문서의
  /// `inviteInfo`가 갱신되므로 `storeDetailProvider`가 유일한 출처가 된다.
  /// 코드를 여기에도 들고 있으면 점포별로 분리되지 않은 두 번째 출처가 생겨,
  /// 다른 점포 모달에 직전 점포의 코드가 새는 경로가 만들어진다.
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
    r'6949b9d104824e4b1305e682ca60bf5f0f6042f9';

/// 관리자의 초대 코드 발급 액션을 UseCase에 위임한다.
///
/// 위젯이 `*_use_case_provider.dart`를 직접 읽지 않도록 하기 위한 계층이다.
/// (CLAUDE.md "Presentation → Domain 접근 규칙")
///
/// 발급된 코드 자체는 여기에 담지 않는다. 발급에 성공하면 점포 문서의
/// `inviteInfo`가 갱신되므로 `storeDetailProvider`가 유일한 출처가 된다.
/// 코드를 여기에도 들고 있으면 점포별로 분리되지 않은 두 번째 출처가 생겨,
/// 다른 점포 모달에 직전 점포의 코드가 새는 경로가 만들어진다.

abstract class _$InviteCodeController extends $AsyncNotifier<void> {
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
