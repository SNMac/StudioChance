import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/exceptions/user_exceptions.dart';
import 'package:studio_chance/domain/enums/user_role.dart';
import 'package:studio_chance/domain/use_cases/auth_use_case.dart';
import 'package:studio_chance/domain/use_cases/user_use_case.dart';
import 'package:studio_chance/presentation/onboarding/controllers/states/onboarding_session_state.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';

part 'onboarding_session_controller.g.dart';

@riverpod
class OnboardingSessionController extends _$OnboardingSessionController {
  @override
  OnboardingSessionState build() {
    return const OnboardingSessionState();
  }

  void setNickname(String nickname) {
    state = state.copyWith(nickname: nickname);
  }

  void setRole(UserRole role) {
    state = state.copyWith(selectedRole: role);
  }

  Future<void> cancelOnboarding() async {
    final authUseCase = ref.read(authUseCaseProvider);
    await authUseCase.signOut();
  }

  /// 닉네임을 원격 DB에 저장만 수행 (리다이렉트 X)
  /// - '다음' 버튼을 눌렀을 때 사용
  Future<void> saveNicknameToRemote() async {
    state = state.copyWith(status: const AsyncLoading());

    try {
      if (!state.isNicknameExists) {
        throw UserValidationException(message: '닉네임이 입력되지 않았습니다.');
      }

      final userUseCase = ref.read(userUseCaseProvider);
      final userResult = await userUseCase.getCurrentUser();

      if (userResult.isLeft()) throw userResult.getLeft().toNullable()!;

      final currentUser = userResult.getRight().toNullable();
      if (currentUser == null) {
        throw UserNotFoundException(message: '로그인 정보를 찾을 수 없습니다.');
      }

      final updateResult = await userUseCase.updateUser(
        uid: currentUser.id,
        nickname: state.nickname,
      );

      if (updateResult.isLeft()) throw updateResult.getLeft().toNullable()!;

      state = state.copyWith(status: const AsyncData(null));
    } catch (e, st) {
      state = state.copyWith(status: AsyncError(e, st));
    }
  }

  /// 닉네임 저장 후 온보딩 종료 (리다이렉트 O)
  /// - '나중에 설정' 버튼을 눌렀을 때 사용
  Future<void> submitNicknameOnly() async {
    await saveNicknameToRemote();

    if (state.status.hasError) return;

    try {
      ref.invalidate(appAuthControllerProvider);
      state = state.copyWith(status: const AsyncData(null));
    } catch (e, st) {
      state = state.copyWith(status: AsyncError(e, st));
    }
  }
}
