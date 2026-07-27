import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/domain/entities/user.dart';

import 'package:studio_chance/domain/use_cases/auth_use_case_provider.dart';
import 'package:studio_chance/presentation/providers/auth_provider.dart';

part 'app_auth_controller.g.dart';

/// 앱의 전체 상태 정의
/// - `unauthenticated`: 비로그인
/// - `onboarding`: 로그인) 신규 사용자 or 온보딩 미완수 사용자
/// - `authenticated`: 로그인) 기존 사용자
/// - `error`: 에러 발생
enum AppStatus { unauthenticated, onboarding, authenticated, error }

@Riverpod(keepAlive: true)
Future<User?> currentUser(Ref ref) async {
  final authInfo = await ref.watch(authStateChangesProvider.future);

  if (authInfo == null) return null;

  final authUseCase = ref.watch(authUseCaseProvider);
  final result = await authUseCase.fetchOrCreateUser(authInfo);

  return result.fold((error) => throw error, (user) => user);
}

@Riverpod(keepAlive: true)
class AppAuthController extends _$AppAuthController {
  final _logger = Logger();

  @override
  Future<AppStatus> build() async {
    try {
      final userState = await ref.watch(currentUserProvider.future);

      if (userState == null) {
        return AppStatus.unauthenticated;
      }

      if (userState.isNewUser) {
        return AppStatus.onboarding;
      }

      return AppStatus.authenticated;
    } catch (e) {
      _logger.e('앱 인증 상태 확인 실패 — AppStatus.error로 진입', error: e);
      return AppStatus.error;
    }
  }
}
