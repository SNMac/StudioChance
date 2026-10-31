import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/domain/use_cases/auth_use_case_provider.dart';

part 'account_deletion_controller.g.dart';

/// 계정 삭제를 UseCase에 위임한다. (CLAUDE.md "Presentation → Domain 접근 규칙")
///
/// 재인증 창과 Apple revoke는 `AuthUseCase.delete()` 안에서 한다 (ADR-0005).
/// 성공하면 인증 상태가 바뀌어 라우터가 로그인 화면으로 보낸다.
/// 마이페이지는 [findStoresBlockingDeletion]으로 막는 점포를 먼저 확인하고 계정 삭제 화면을 연다.
/// 그 사이 멤버가 늘었으면 [delete]가 `StoreAdminHandoverRequiredException`으로
/// 실패하며, 이때는 재인증 창이 뜨기 전에 막힌다.
@riverpod
class AccountDeletionController extends _$AccountDeletionController {
  final _logger = Logger();

  @override
  FutureOr<void> build() {}

  /// 계정 삭제를 막는 점포. 실패하면 상태를 오류로 두고 null을 돌려준다 (마이페이지가 알린다).
  ///
  /// 로딩 상태로 바꾸지 않는다. 화면을 열기 전 조회라 오버레이를 늦게 띄우는 판단은
  /// 부르는 쪽이 한다 (CLAUDE.md "화면 전환 전 데이터 로딩 패턴")
  Future<List<StoreRef>?> findStoresBlockingDeletion() async {
    final result = await ref
        .read(authUseCaseProvider)
        .findStoresBlockingDeletion();
    final stackTrace = StackTrace.current;

    return result.fold((e) {
      _logger.e('계정 삭제 전 점포 확인 실패', error: e);
      state = AsyncError(e, stackTrace);
      return null;
    }, (stores) => stores);
  }

  Future<void> delete() async {
    state = const AsyncLoading();

    final result = await ref.read(authUseCaseProvider).delete();
    final stackTrace = StackTrace.current;

    result.fold((e) {
      _logger.e('계정 삭제 실패', error: e);
      state = AsyncError(e, stackTrace);
    }, (_) => state = const AsyncData(null));
  }
}
