import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/domain/use_cases/user_use_case.dart';
import 'package:studio_chance/presentation/providers/auth_provider.dart';

part 'app_auth_controller.g.dart';

// 앱의 전체 상태 정의
enum AppStatus {
  unauthenticated, // 비로그인
  onboarding, // DB는 있는데 닉네임 없음 (신규)
  authenticated, // 모든 정보 완벽함 (홈으로)
  error, // 에러 발생
}

@Riverpod(keepAlive: true)
class AppAuthController extends _$AppAuthController {
  @override
  Future<AppStatus> build() async {
    final userUseCase = ref.watch(userUseCaseProvider);

    final authInfo = await ref.watch(authStateChangesProvider.future);

    if (authInfo == null) {
      return AppStatus.unauthenticated;
    }

    final result = await userUseCase.fetchOrCreateUser(authInfo);

    return result.fold((error) => AppStatus.error, (user) {
      if (user.nickname == null) return AppStatus.onboarding;
      return AppStatus.authenticated;
    });
  }
}
