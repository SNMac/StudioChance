import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/exceptions/user_exceptions.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/enums/store_color.dart';
import 'package:studio_chance/domain/use_cases/store_use_case.dart';
import 'package:studio_chance/domain/use_cases/user_use_case.dart';
import 'package:studio_chance/presentation/onboarding/sessions/onboarding_session.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';

part 'store_creation_controller.g.dart';

@riverpod
class StoreCreationController extends _$StoreCreationController {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  /// 점포 생성 제출
  /// [formData] : StoreInputFormViewModel에서 getFormData()로 만든 결과값
  Future<void> submit(({Store store, StoreColor color}) formData) async {
    state = const AsyncValue.loading();

    try {
      final userUseCase = ref.read(userUseCaseProvider);
      final storeUseCase = ref.read(storeUseCaseProvider);

      // 1. OnboardingSession에서 닉네임/역할 정보 가져오기
      // (이 시점까지 아직 서버에 닉네임이 저장되지 않았을 수 있으므로 확실하게 처리)
      final session = ref.read(onboardingSessionProvider);

      if (!session.isNicknameValid || !session.isRoleSelected) {
        throw UserValidationException(message: '사용자 프로필 정보가 부족합니다.');
      }

      // 2. 사용자 프로필(닉네임/역할) 우선 업데이트
      final userResult = await userUseCase.getCurrentUser();
      if (userResult.isLeft()) throw userResult.getLeft().toNullable()!;

      final currentUser = userResult.getRight().toNullable();
      if (currentUser == null) {
        throw UserNotFoundException(message: '로그인 정보가 없습니다.');
      }

      final updateResult = await userUseCase.updateUser(
        uid: currentUser.id,
        nickname: session.nickname,
      );
      if (updateResult.isLeft()) throw updateResult.getLeft().toNullable()!;

      final finalStore = formData.store;

      // 4. 점포 생성 요청
      final createResult = await storeUseCase.createStore(
        store: finalStore,
        color: formData.color,
      );

      if (createResult.isLeft()) throw createResult.getLeft().toNullable()!;

      // 5. 성공 처리 (인증 상태 갱신 -> 홈으로 이동됨)
      state = const AsyncValue.data(null);

      // AuthController를 갱신하여 GoRouter가 redirect를 수행하도록 함
      ref.invalidate(appAuthControllerProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
