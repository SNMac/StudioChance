import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/common/exceptions/user_exceptions.dart';

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
    final session = ref.read(onboardingSessionProvider);

    if (!session.canSubmit) {
      state = AsyncValue.error(
        Exception('필수 정보가 누락되었습니다.'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();

    try {
      final userUseCase = ref.read(userUseCaseProvider);
      final storeUseCase = ref.read(storeUseCaseProvider);

      final userResult = await userUseCase.getCurrentUser();
      if (userResult.isLeft()) throw userResult.getLeft().toNullable()!;

      final currentUser = userResult.getRight().toNullable();
      if (currentUser == null) {
        throw UserNotFoundException(message: '로그인 정보를 찾을 수 없습니다.');
      }

      final updateResult = await userUseCase.updateUser(
        uid: currentUser.id,
        nickname: session.nickname,
      );
      if (updateResult.isLeft()) throw updateResult.getLeft().toNullable()!;

      if (session.isCreatingStore) {
        // 점포 생성 - 관리자가 직접 생성하는 경우
        if (session.storeToMake == null) {
          throw StoreNotFoundException(message: "점포 정보가 누락되었습니다.");
        }

        final createResult = await storeUseCase.createStore(
          store: session.storeToMake!,
          color: session.selectedStoreColor!,
        );
        if (createResult.isLeft()) throw createResult.getLeft().toNullable()!;
      } else {
        // 점포 참가 - 스태프/뷰어 혹은 관리자가 기존 점포에 참가하는 경우
        if (session.invitedStoreId == null) {
          throw StoreNotFoundException(message: "초대된 점포 ID가 없습니다.");
        }

        final joinResult = await storeUseCase.joinStore(
          storeId: session.invitedStoreId!,
          role: session.selectedRole,
        );
        if (joinResult.isLeft()) throw joinResult.getLeft().toNullable()!;
      }

      state = const AsyncValue.data(null);
      ref.invalidate(appAuthControllerProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
