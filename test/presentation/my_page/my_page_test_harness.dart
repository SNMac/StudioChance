import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/use_cases/auth_use_case_provider.dart';
import 'package:studio_chance/domain/use_cases/store_use_case_provider.dart';
import 'package:studio_chance/domain/use_cases/user_use_case_provider.dart';
import 'package:studio_chance/presentation/commons/store_input/screens/store_form_screen.dart';
import 'package:studio_chance/presentation/commons/widgets/app_toast.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/presentation/providers/server_clock_offset_provider.dart';
import 'package:studio_chance/router/app_router.dart';
import 'package:studio_chance/router/router_path.dart';

import '../../helpers/mocks.dart';

/// 마이페이지 위젯 테스트 하네스 — 실제 마이페이지 라우트([myPageRoute])로 화면을 이동한다.
///
/// HomeTabBar가 GoRouterState를 읽고 다이얼로그 확인 버튼이 context.pop()을 쓰므로
/// GoRouter가 필요하다. 점포 수정 화면은 무거워서 넘겨받은 점포만 보여주는 화면으로 바꾼다.
class MyPageHarness {
  MyPageHarness({required this._user, this._initialLocation = '/my-page'});

  final storeUseCase = MockStoreUseCase();
  final userUseCase = MockUserUseCase();
  final authUseCase = MockAuthUseCase();

  User _user;
  final String _initialLocation;

  /// 다음에 currentUserProvider를 다시 읽을 때 돌려줄 사용자 (위임·나가기 뒤 상태)
  set user(User user) => _user = user;

  Widget build() {
    final router = GoRouter(
      initialLocation: _initialLocation,
      routes: [
        myPageRoute(),
        GoRoute(
          path: SCRoute.storeEdit.path,
          builder: (_, state) => Scaffold(
            body: Text(
              '수정 화면: ${(state.extra! as StoreEditArgs).store.address}',
            ),
          ),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        currentUserProvider.overrideWith((ref) async => _user),
        storeUseCaseProvider.overrideWith((ref) => storeUseCase),
        userUseCaseProvider.overrideWith((ref) => userUseCase),
        authUseCaseProvider.overrideWith((ref) => authUseCase),
        // 삭제 예정 점포의 남은 기간 표시가 서버 시각을 구한다 (기기 시계와 같다고 둔다)
        serverClockOffsetProvider.overrideWith((ref) async => Duration.zero),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        builder: (context, child) => ToastHost(child: child!),
      ),
    );
  }
}
