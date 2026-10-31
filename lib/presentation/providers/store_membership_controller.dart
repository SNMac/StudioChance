import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/domain/use_cases/store_use_case_provider.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/presentation/providers/store_detail_provider.dart';

part 'store_membership_controller.g.dart';

/// 점포 멤버 구성을 바꾸는 액션(역할 변경·추방·관리자 위임·점포 나가기·신청 취소·
/// 점포 삭제·점포 복구·영구 삭제)을 UseCase에 위임한다. (CLAUDE.md "Presentation → Domain 접근 규칙")
///
/// 각 액션은 성공하면 true를 돌려준다. 화면은 이 값으로 다음 이동을 정하고,
/// 실패는 [state]의 [AsyncError]를 듣고 알린다.
@riverpod
class StoreMembershipController extends _$StoreMembershipController {
  final _logger = Logger();

  @override
  FutureOr<void> build() {}

  /// 스태프 ↔ 뷰어 역할 변경 (관리자용)
  Future<bool> changeRole({
    required String storeId,
    required String uid,
    required UserRole newRole,
  }) {
    return _run(
      '역할 변경',
      storeId,
      () => ref
          .read(storeUseCaseProvider)
          .updateMemberRole(storeId: storeId, targetUid: uid, newRole: newRole),
    );
  }

  /// 추방 (관리자용)
  Future<bool> removeMember({required String storeId, required String uid}) {
    return _run(
      '추방',
      storeId,
      () => ref
          .read(storeUseCaseProvider)
          .removeMember(storeId: storeId, targetUid: uid),
    );
  }

  /// 관리자 위임 — 내 역할이 바뀌므로 내 점포 목록도 다시 읽는다
  Future<bool> delegateAdmin({
    required String storeId,
    required String uid,
    required UserRole previousAdminRole,
  }) {
    return _run(
      '관리자 위임',
      storeId,
      () => ref
          .read(storeUseCaseProvider)
          .delegateAdmin(
            storeId: storeId,
            targetUid: uid,
            previousAdminRole: previousAdminRole,
          ),
      refreshCurrentUser: true,
    );
  }

  Future<bool> leaveStore(String storeId) {
    return _run(
      '점포 나가기',
      storeId,
      () => ref.read(storeUseCaseProvider).leaveStore(storeId),
      refreshCurrentUser: true,
    );
  }

  Future<bool> cancelJoinRequest(String storeId) {
    return _run(
      '신청 취소',
      storeId,
      () => ref.read(storeUseCaseProvider).cancelJoinRequest(storeId),
      refreshCurrentUser: true,
    );
  }

  /// 점포 삭제 — 삭제 예정 점포가 되어 7일 안에 복구할 수 있다 (CONTEXT.md "점포 삭제")
  Future<bool> deleteStore(String storeId) {
    return _run(
      '점포 삭제',
      storeId,
      () => ref.read(storeUseCaseProvider).softDeleteStore(storeId),
      refreshCurrentUser: true,
    );
  }

  Future<bool> restoreStore(String storeId) {
    return _run(
      '점포 복구',
      storeId,
      () => ref.read(storeUseCaseProvider).restoreStore(storeId),
      refreshCurrentUser: true,
    );
  }

  /// 영구 삭제 — 되돌릴 수 없다 (CONTEXT.md "영구 삭제")
  Future<bool> permanentlyDeleteStore(String storeId) {
    return _run(
      '영구 삭제',
      storeId,
      () => ref.read(storeUseCaseProvider).permanentlyDeleteStore(storeId),
      refreshCurrentUser: true,
    );
  }

  /// 처리 중에는 [state]를 [AsyncLoading]으로 두어 화면이 같은 액션의 연타를 막게 한다.
  ///
  /// [refreshCurrentUser]: 내 점포 목록·역할이 바뀌는 액션. 사용자 정보는 한 번만
  /// 읽어 두므로(currentUserProvider) 스스로 갱신되지 않는다
  Future<bool> _run(
    String label,
    String storeId,
    Future<Either<Exception, void>> Function() action, {
    bool refreshCurrentUser = false,
  }) async {
    state = const AsyncLoading();

    final result = await action();
    final stackTrace = StackTrace.current;

    return result.fold(
      (e) {
        _logger.e('$label 실패', error: e);
        state = AsyncError(e, stackTrace);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        ref.invalidate(storeDetailProvider(storeId));
        if (refreshCurrentUser) ref.invalidate(currentUserProvider);
        return true;
      },
    );
  }
}
