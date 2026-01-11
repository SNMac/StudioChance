import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/domain/use_cases/auth_use_case.dart';
import 'package:studio_chance/domain/use_cases/user_use_case.dart';

part 'app_auth_controller.g.dart';

// 앱의 전체 상태 정의
enum AppStatus {
  unauthenticated, // 비로그인
  authenticating, // 인증은 됐는데 DB 조회 중 (로딩)
  onboarding, // DB는 있는데 닉네임 없음 (신규)
  authenticated, // 모든 정보 완벽함 (홈으로)
  error, // 에러 발생
}

@Riverpod(keepAlive: true)
class AppAuthController extends _$AppAuthController {
  final Logger _logger = Logger();

  @override
  Stream<AppStatus> build() async* {
    final authUseCase = ref.watch(authUseCaseProvider);
    final userUseCase = ref.watch(userUseCaseProvider);

    await for (final authInfo in authUseCase.authStateChanges()) {
      if (authInfo == null) {
        yield AppStatus.unauthenticated;
        continue;
      }

      yield AppStatus.authenticating;

      final result = await userUseCase.fetchOrCreateUser(authInfo);

      yield result.fold(
        (error) {
          _logger.e('앱 초기화 실패', error: error);
          return AppStatus.error;
        },
        (user) {
          if (user.nickname == null) {
            return AppStatus.onboarding;
          }
          return AppStatus.authenticated;
        },
      );
    }
  }
}
