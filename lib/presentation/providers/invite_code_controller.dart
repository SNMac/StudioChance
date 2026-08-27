import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/domain/entities/invite_info.dart';
import 'package:studio_chance/domain/use_cases/store_use_case_provider.dart';
import 'package:studio_chance/presentation/providers/store_detail_provider.dart';

part 'invite_code_controller.g.dart';

/// 관리자의 초대 코드 발급 액션을 UseCase에 위임한다.
///
/// 위젯이 `*_use_case_provider.dart`를 직접 읽지 않도록 하기 위한 계층이다.
/// (CLAUDE.md "Presentation → Domain 접근 규칙")
@riverpod
class InviteCodeController extends _$InviteCodeController {
  final _logger = Logger();

  /// 이번 세션에서 방금 발급한 코드. 발급 전에는 null이다.
  ///
  /// 이미 저장돼 있는 코드는 `storeDetailProvider`의 `Store.inviteInfo`가 들고
  /// 있으므로 여기서 다시 조회하지 않는다 — 모달은 두 곳을 합쳐서 보여준다.
  @override
  FutureOr<InviteInfo?> build() => null;

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

    // 응답을 기다리는 동안 모달이 닫히고 다른 점포 모달이 열렸다면, 그쪽
    // didChangeDependencies가 이 컨트롤러를 invalidate해 state를 AsyncData(null)로
    // 되돌린다. 그런데 invalidate는 Notifier 인스턴스를 재사용하므로 이 메서드는
    // 그대로 살아남아, 막지 않으면 A점포의 코드를 B점포 모달에 써 넣는다
    // (관리자가 엉뚱한 점포 코드를 복사·공유하게 된다).
    if (!state.isLoading) {
      _logger.w('버려진 초대 코드 발급 결과 — 요청 중 상태가 리셋됐다\nstoreId: $storeId');
      return;
    }

    result.fold(
      (e) {
        _logger.e('초대 코드 발급 실패', error: e);
        state = AsyncError(e, stackTrace);
      },
      (info) {
        state = AsyncData(info);
        // 점포 문서의 inviteInfo가 바뀌었다. 무효화하지 않으면 모달을 다시 열 때
        // 캐시에 남은 옛 코드를 보여준다 (마이페이지가 이 provider를 계속
        // 구독하고 있어 autoDispose되지 않는다).
        ref.invalidate(storeDetailProvider(storeId));
      },
    );
  }
}
