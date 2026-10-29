import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/domain/use_cases/auth_use_case_provider.dart';

part 'account_deletion_controller.g.dart';

/// 계정 삭제를 UseCase에 위임한다. (CLAUDE.md "Presentation → Domain 접근 규칙")
///
/// 재인증 창과 Apple revoke는 `AuthUseCase.delete()` 안에서 한다 (ADR-0005).
/// 성공하면 인증 상태가 바뀌어 라우터가 로그인 화면으로 보낸다.
/// 다른 멤버가 있는 관리자 점포가 남아 있으면 `StoreAdminHandoverRequiredException`으로
/// 실패하며, 이때는 재인증 창이 뜨기 전에 막힌다.
@riverpod
class AccountDeletionController extends _$AccountDeletionController {
  final _logger = Logger();

  @override
  FutureOr<void> build() {}

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
