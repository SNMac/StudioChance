import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/domain/use_cases/store_use_case_provider.dart';
import 'package:studio_chance/presentation/providers/store_detail_provider.dart';

part 'pending_member_controller.g.dart';

/// 승인 대기 멤버의 승인·거절 액션을 UseCase에 위임한다.
///
/// 위젯이 `*_use_case_provider.dart`를 직접 읽지 않도록 하기 위한 계층이다.
/// (CLAUDE.md "Presentation → Domain 접근 규칙")
@riverpod
class PendingMemberController extends _$PendingMemberController {
  final _logger = Logger();

  @override
  FutureOr<void> build() {}

  /// 신청자를 승인한다. 역할은 신청 시 선택한 값을 그대로 사용한다.
  Future<void> approve({
    required String storeId,
    required String uid,
    required UserRole role,
  }) async {
    final result = await ref
        .read(storeUseCaseProvider)
        .approveMember(storeId: storeId, targetUid: uid, role: role);
    final stackTrace = StackTrace.current;

    result.fold((e) {
      _logger.e('멤버 승인 실패', error: e);
      state = AsyncError(e, stackTrace);
    }, (_) => ref.invalidate(storeDetailProvider(storeId)));
  }

  /// 신청을 거절한다 (대기 명단 및 대상 사용자의 점포 정보에서 제거).
  Future<void> reject({required String storeId, required String uid}) async {
    final result = await ref
        .read(storeUseCaseProvider)
        .removeMember(storeId: storeId, targetUid: uid);
    final stackTrace = StackTrace.current;

    result.fold((e) {
      _logger.e('가입 신청 거절 실패', error: e);
      state = AsyncError(e, stackTrace);
    }, (_) => ref.invalidate(storeDetailProvider(storeId)));
  }
}
