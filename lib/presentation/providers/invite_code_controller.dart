import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/domain/use_cases/store_use_case_provider.dart';
import 'package:studio_chance/presentation/providers/store_detail_provider.dart';

part 'invite_code_controller.g.dart';

/// 관리자의 초대 코드 발급 액션을 UseCase에 위임한다.
///
/// 위젯이 `*_use_case_provider.dart`를 직접 읽지 않도록 하기 위한 계층이다.
/// (CLAUDE.md "Presentation → Domain 접근 규칙")
///
/// 발급된 코드 자체는 여기에 담지 않는다. 발급에 성공하면 점포 문서의
/// `inviteInfo`가 갱신되므로 `storeDetailProvider`가 유일한 출처가 된다.
/// 코드를 여기에도 들고 있으면 점포별로 분리되지 않은 두 번째 출처가 생겨,
/// 다른 점포 모달에 직전 점포의 코드가 새는 경로가 만들어진다.
@riverpod
class InviteCodeController extends _$InviteCodeController {
  final _logger = Logger();

  @override
  FutureOr<void> build() {}

  /// 초대 코드를 발급한다.
  ///
  /// 기본값([forceRegenerate]가 false)에서는 유효 기간이 남은 코드가 있으면
  /// Repository가 같은 코드를 되돌려주므로(`store_repository_impl.dart`의
  /// `createInviteCode`) 재사용/재발급 분기를 UI가 판단하지 않는다.
  ///
  /// [forceRegenerate]가 true면 유효 기간이 남아 있어도 새 코드를 만들어
  /// 덮어쓴다. 별도의 코드 폐기 경로가 없으므로, 유출된 코드를 즉시 막는
  /// 수단이기도 하다 — 덮어쓰는 순간 옛 코드로는 점포가 조회되지 않는다.
  ///
  /// 처리 중 [state]를 [AsyncLoading]으로 두어, 모달이 `isLoading`을 보고
  /// 버튼을 비활성화해 연타로 인한 중복 발급을 막을 수 있게 한다.
  Future<void> issue(String storeId, {bool forceRegenerate = false}) async {
    state = const AsyncLoading();

    final result = await ref
        .read(storeUseCaseProvider)
        .createInviteCode(storeId, forceRegenerate: forceRegenerate);
    final stackTrace = StackTrace.current;

    result.fold(
      (e) {
        _logger.e('초대 코드 발급 실패', error: e);
        state = AsyncError(e, stackTrace);
      },
      (_) {
        state = const AsyncData(null);
        // 새 코드는 이 무효화를 통해 화면에 도달한다.
        ref.invalidate(storeDetailProvider(storeId));
      },
    );
  }
}
