import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/domain/entities/user.dart';

import 'package:studio_chance/domain/use_cases/auth_use_case_provider.dart';
import 'package:studio_chance/presentation/providers/auth_provider.dart';
import 'package:studio_chance/presentation/providers/server_clock_offset_provider.dart';

part 'app_auth_controller.g.dart';

/// 사용자 정보 로딩이 서버 시각을 기다리는 최대 시간 ([currentUser])
const _serverClockTimeout = Duration(seconds: 3);

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
  final user = result.fold((error) => throw error, (user) => user);

  // 기한이 지난 삭제 예정 점포는 서버 시각으로 판정해 뺀다 (ADR-0007). 서버 시각은
  // 삭제 예정 점포가 있을 때만 구해 평소의 사용자 정보 로딩에 Functions 호출을 더하지 않는다.
  // 받지 못하거나 늦으면 기기 시계로 판정한다 — Functions cold start가 앱 시작을 붙잡지 않게 한다
  if (!user.storeInfos.any((info) => info.isScheduledForDeletion)) return user;
  final offset = await ref
      .watch(serverClockOffsetProvider.future)
      .timeout(_serverClockTimeout, onTimeout: () => Duration.zero);
  return user.withoutExpiredStores(DateTime.now().add(offset));
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
