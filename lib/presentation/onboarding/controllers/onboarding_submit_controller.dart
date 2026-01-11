import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/common/exceptions/user_exceptions.dart';

import 'package:studio_chance/domain/enums/user_role.dart';
import 'package:studio_chance/domain/use_cases/auth_use_case.dart';
import 'package:studio_chance/domain/use_cases/store_use_case.dart';
import 'package:studio_chance/domain/use_cases/user_use_case.dart';
import 'package:studio_chance/presentation/onboarding/sessions/onboarding_session.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';

part 'onboarding_submit_controller.g.dart';

@riverpod
class OnboardingSubmitController extends _$OnboardingSubmitController {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  /// 온보딩 취소
  Future<void> cancel() async {
    try {
      final authUseCase = ref.read(authUseCaseProvider);
      await authUseCase.signOut();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 최종 제출
  Future<void> submit() async {
    // 1. 세션 데이터 가져오기
    final session = ref.read(onboardingSessionProvider);

    // 2. 세션 유효성 검사
    if (!session.canSubmit) {
      state = AsyncValue.error(
        Exception('필수 정보가 누락되었습니다.'),
        StackTrace.current,
      );
      return;
    }

    // 3. 로딩 시작
    state = const AsyncValue.loading();

    try {
      final userUseCase = ref.read(userUseCaseProvider);
      final storeUseCase = ref.read(storeUseCaseProvider);

      // 4. [안전한 방법] 최신 유저 정보 조회
      final userResult = await userUseCase.getCurrentUser();
      if (userResult.isLeft()) throw userResult.getLeft().toNullable()!;

      final currentUser = userResult.getRight().toNullable();
      if (currentUser == null) throw UserNotFoundException(message: '로그인 정보를 찾을 수 없습니다.');

      // 5. [선행] 유저 프로필(닉네임, 역할) 업데이트
      // *주의: 프로필을 먼저 업데이트해야 점포 생성/참가 시 올바른 정보(이름 등)가 기록됨
      final updateResult = await userUseCase.updateUser(
        uid: currentUser.id,
        nickname: session.nickname,
        role: session.selectedRole,
      );
      if (updateResult.isLeft()) throw updateResult.getLeft().toNullable()!;

      // 6. 점포 처리 (생성 or 참가)
      // *참고: userUseCase.addStoreId는 제거됨 (StoreUseCase 내부에서 Batch 처리)
      if (session.selectedRole == UserRole.admin) {
        // [Admin] 가게 생성
        if (session.storeToMake == null) throw StoreNotFoundException(message: "가게 정보가 없습니다.");

        final createResult = await storeUseCase.createStore(
          session.storeToMake!,
        );
        if (createResult.isLeft()) throw createResult.getLeft().toNullable()!;
      } else {
        // [Staff/Viewer] 가게 참가 (초대 수락)
        if (session.invitedStoreId == null) throw StoreNotFoundException(message: "초대된 가게 ID가 없습니다.");

        final joinResult = await storeUseCase.joinStore(
          storeId: session.invitedStoreId!,
          role: session.selectedRole, // staff or viewer
        );
        if (joinResult.isLeft()) throw joinResult.getLeft().toNullable()!;
      }

      // 7. 성공 처리
      state = const AsyncValue.data(null);

      ref.invalidate(appAuthControllerProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
