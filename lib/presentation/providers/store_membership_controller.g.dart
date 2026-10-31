// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_membership_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 점포 멤버 구성을 바꾸는 액션(역할 변경·추방·관리자 위임·점포 나가기·신청 취소·
/// 점포 삭제·점포 복구·영구 삭제)을 UseCase에 위임한다. (CLAUDE.md "Presentation → Domain 접근 규칙")
///
/// 각 액션은 성공하면 true를 돌려준다. 화면은 이 값으로 다음 이동을 정하고,
/// 실패는 [state]의 [AsyncError]를 듣고 알린다.

@ProviderFor(StoreMembershipController)
final storeMembershipControllerProvider = StoreMembershipControllerProvider._();

/// 점포 멤버 구성을 바꾸는 액션(역할 변경·추방·관리자 위임·점포 나가기·신청 취소·
/// 점포 삭제·점포 복구·영구 삭제)을 UseCase에 위임한다. (CLAUDE.md "Presentation → Domain 접근 규칙")
///
/// 각 액션은 성공하면 true를 돌려준다. 화면은 이 값으로 다음 이동을 정하고,
/// 실패는 [state]의 [AsyncError]를 듣고 알린다.
final class StoreMembershipControllerProvider
    extends $AsyncNotifierProvider<StoreMembershipController, void> {
  /// 점포 멤버 구성을 바꾸는 액션(역할 변경·추방·관리자 위임·점포 나가기·신청 취소·
  /// 점포 삭제·점포 복구·영구 삭제)을 UseCase에 위임한다. (CLAUDE.md "Presentation → Domain 접근 규칙")
  ///
  /// 각 액션은 성공하면 true를 돌려준다. 화면은 이 값으로 다음 이동을 정하고,
  /// 실패는 [state]의 [AsyncError]를 듣고 알린다.
  StoreMembershipControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storeMembershipControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storeMembershipControllerHash();

  @$internal
  @override
  StoreMembershipController create() => StoreMembershipController();
}

String _$storeMembershipControllerHash() =>
    r'eb2e4ea29b4605297b54a5409cab075946fed022';

/// 점포 멤버 구성을 바꾸는 액션(역할 변경·추방·관리자 위임·점포 나가기·신청 취소·
/// 점포 삭제·점포 복구·영구 삭제)을 UseCase에 위임한다. (CLAUDE.md "Presentation → Domain 접근 규칙")
///
/// 각 액션은 성공하면 true를 돌려준다. 화면은 이 값으로 다음 이동을 정하고,
/// 실패는 [state]의 [AsyncError]를 듣고 알린다.

abstract class _$StoreMembershipController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
