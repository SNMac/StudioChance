import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/exceptions/user_exceptions.dart';
import 'package:studio_chance/domain/use_cases/auth_use_case_provider.dart';
import 'package:studio_chance/domain/use_cases/user_use_case_provider.dart';

part 'onboarding_nickname_controller.g.dart';

@riverpod
class OnboardingNicknameController extends _$OnboardingNicknameController {
  @override
  FutureOr<void> build() {}

  Future<void> cancelOnboarding() async {
    final authUseCase = ref.read(authUseCaseProvider);
    await authUseCase.signOut();
  }

  /// 닉네임을 원격 DB에 저장
  Future<void> saveNicknameToRemote(String nickname) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      if (nickname.trim().isEmpty) {
        throw UserValidationException(message: '닉네임이 입력되지 않았습니다.');
      }

      final userUseCase = ref.read(userUseCaseProvider);
      final userResult = await userUseCase.getCurrentUser();

      final currentUser = userResult.fold(
        (error) => throw error,
        (user) => user,
      );

      if (currentUser == null) {
        throw UserNotFoundException(message: '로그인 정보를 찾을 수 없습니다.');
      }

      final updateResult = await userUseCase.updateUser(
        uid: currentUser.id,
        nickname: nickname,
      );

      updateResult.fold(
        (error) => throw error,
        (_) {},
      );
    });
  }
}
