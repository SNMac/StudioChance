import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/domain/use_cases/store_use_case_provider.dart';
import 'package:studio_chance/presentation/commons/invite_code/controllers/states/invite_code_verification_state.dart';
import 'package:studio_chance/presentation/commons/role_selection/controllers/role_selection_controller.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';

part 'invite_code_verification_controller.g.dart';

@riverpod
class InviteCodeVerificationController
    extends _$InviteCodeVerificationController {
  @override
  InviteCodeVerificationState build() {
    return const InviteCodeVerificationState();
  }

  void onCodeChanged(String value) {
    state = state.copyWith(inviteCode: value.toUpperCase());
  }

  void setStoreAlias(String value) => state = state.copyWith(storeAlias: value);

  void setColor(StoreColor color) => state = state.copyWith(color: color);

  void setMemo(String value) => state = state.copyWith(memo: value);

  Future<void> verifyInviteCode() async {
    state = state.copyWith(status: const AsyncLoading());

    final storeUseCase = ref.read(storeUseCaseProvider);
    final result = await storeUseCase.getStoreByInviteCode(state.inviteCode);

    result.fold(
      (exception) => state = state.copyWith(
        status: AsyncError(exception, StackTrace.current),
      ),
      // 점포 별명 기본값은 점포명
      (preview) => state = state.copyWith(
        status: AsyncData(preview),
        storeAlias: preview?.storeName ?? '',
      ),
    );
  }

  /// 가입 신청 제출 (대기열 등록)
  Future<void> submitJoinRequest() async {
    if (!state.canSubmit) return;

    final preview = state.status.value!;
    // 역할은 초대 코드 단계 진입 전 역할 선택 화면에서 고른 값을 그대로 사용한다.
    final role = ref.read(roleSelectionControllerProvider);

    state = state.copyWith(submitStatus: const AsyncLoading());

    final storeUseCase = ref.read(storeUseCaseProvider);
    final result = await storeUseCase.joinStore(
      storeId: preview.storeId,
      storeAlias: state.storeAlias.trim(),
      role: role,
      color: state.color,
      memo: state.memo,
    );
    final stackTrace = StackTrace.current;

    result.fold(
      (exception) => state = state.copyWith(
        submitStatus: AsyncError(exception, stackTrace),
      ),
      (_) => state = state.copyWith(submitStatus: const AsyncData(null)),
    );
  }

  /// 신청 완료 안내를 사용자가 확인한 뒤 호출한다.
  /// currentUser를 무효화하면 온보딩 중이던 사용자는 라우터 redirect로 홈에 진입하므로,
  /// 안내 다이얼로그가 뜨자마자 화면이 바뀌지 않도록 제출 성공 시점과 분리한다.
  void completeJoin() => ref.invalidate(currentUserProvider);
}
