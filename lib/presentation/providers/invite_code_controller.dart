import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/domain/entities/invite_info.dart';
import 'package:studio_chance/domain/use_cases/store_use_case_provider.dart';

part 'invite_code_controller.g.dart';

/// 관리자의 초대 코드 발급 액션을 UseCase에 위임한다.
///
/// 위젯이 `*_use_case_provider.dart`를 직접 읽지 않도록 하기 위한 계층이다.
/// (CLAUDE.md "Presentation → Domain 접근 규칙")
@riverpod
class InviteCodeController extends _$InviteCodeController {
  final _logger = Logger();

  /// 발급 전에는 null이며, 모달을 열 때마다 항상 발급 버튼부터 시작한다.
  /// [InviteInfo]에 `createdAt`이 없어 이미 발급된 코드의 만료 여부를
  /// 클라이언트가 판단할 수 없기 때문이다 (만료된 코드를 보여줄 위험).
  @override
  FutureOr<InviteInfo?> build() => null;

  /// 초대 코드를 발급한다.
  ///
  /// 유효 기간이 남은 코드가 있으면 Repository가 같은 코드를 되돌려주므로
  /// (`store_repository_impl.dart`의 `createInviteCode`) 재사용/재발급 분기를
  /// UI가 판단하지 않는다. 같은 이유로 `forceRegenerate`도 넘기지 않는다.
  ///
  /// 처리 중 [state]를 [AsyncLoading]으로 두어, 모달이 `isLoading`을 보고
  /// 버튼을 비활성화해 연타로 인한 중복 발급을 막을 수 있게 한다.
  Future<void> issue(String storeId) async {
    state = const AsyncLoading();

    final result = await ref
        .read(storeUseCaseProvider)
        .createInviteCode(storeId);
    final stackTrace = StackTrace.current;

    result.fold((e) {
      _logger.e('초대 코드 발급 실패', error: e);
      state = AsyncError(e, stackTrace);
    }, (info) => state = AsyncData(info));
  }
}
