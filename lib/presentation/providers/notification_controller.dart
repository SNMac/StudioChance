import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/constants/notification_constants.dart';
import 'package:studio_chance/data/models/push_message_mapper.dart';
import 'package:studio_chance/domain/entities/push_message.dart';
import 'package:studio_chance/domain/use_cases/notification_use_case_provider.dart';
import 'package:studio_chance/presentation/my_page/widgets/pending_member_modal.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/router/app_router.dart';
import 'package:studio_chance/router/router_path.dart';

part 'notification_controller.g.dart';

/// 푸시 메시지가 "가입 신청"이면 이동 대상 점포 ID를, 아니면 null을 반환한다.
String? joinRequestStoreIdOf(PushMessage message) {
  if (message.type != joinRequestNotificationType) return null;

  final storeId = message.data['storeId'];
  if (storeId == null || storeId.isEmpty) return null;

  return storeId;
}

/// 알림 권한 요청, FCM 토큰 등록, 수신 메시지 표시·딥링크를 담당한다.
///
/// `MyApp`에서 watch하여 앱 생명주기 동안 살아 있게 한다.
@Riverpod(keepAlive: true)
class NotificationController extends _$NotificationController {
  final _logger = Logger();

  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<PushMessage>? _foregroundSubscription;
  StreamSubscription<PushMessage>? _openedAppSubscription;

  /// 인증이 끝나기 전에 도착한 메시지 (종료 상태에서 알림 탭한 경우)
  PushMessage? _pendingMessage;

  /// build() 세대 번호.
  ///
  /// riverpod 3.1.0은 build()가 새 호출로 대체돼도 이전 build()의 Future 본문을
  /// 강제 중단하지 않고 끝까지 실행한다 (버려지는 것은 반환값뿐). currentUserProvider가
  /// 짧은 간격으로 두 번 emit되거나(로그아웃 직후 재로그인 등) requestPermission()이
  /// OS 권한 다이얼로그에서 수 초간 블로킹되는 사이 두 build()가 겹치면, 뒤처진(오래된)
  /// build()가 stale한 user로 구독을 덮어쓰거나 FCM 토큰을 다른 계정에 등록할 수 있다.
  /// → 매 await 직후 세대 번호를 비교해 뒤처진 build()는 즉시 포기한다.
  /// (지워도 컴파일·평상시 테스트는 통과하므로 불필요해 보일 수 있으나 삭제 금지)
  int _buildGeneration = 0;

  @override
  Future<void> build() async {
    final generation = ++_buildGeneration;

    await _cancelSubscriptions();
    ref.onDispose(_cancelSubscriptions);

    final user = await ref.watch(currentUserProvider.future);
    if (generation != _buildGeneration || user == null) return;

    final useCase = ref.read(notificationUseCaseProvider);

    // 인증이 늦게 끝나는 경우를 대비해 보류된 메시지를 소비한다.
    ref.listen(appAuthControllerProvider, (_, next) {
      if (next.value != AppStatus.authenticated) return;

      final pending = _pendingMessage;
      if (pending == null) return;
      _pendingMessage = null;
      _handleMessage(pending);
    });

    await useCase.initLocalNotifications(onTap: _handlePayload);
    if (generation != _buildGeneration) return;

    final permissionResult = await useCase.requestPermission();
    if (generation != _buildGeneration) return;
    permissionResult.fold(
      (error) => _logger.w('알림 권한 요청 실패 (무시)', error: error),
      (granted) => _logger.i('알림 권한 허용 여부: $granted'),
    );

    final registerResult = await useCase.registerFcmToken(uid: user.id);
    if (generation != _buildGeneration) return;
    registerResult.fold(
      (error) => _logger.w('FCM 토큰 등록 실패 (무시)', error: error),
      (_) {},
    );

    if (generation != _buildGeneration) return;
    _tokenSubscription = useCase.onTokenRefresh.listen((token) {
      useCase.registerFcmToken(uid: user.id, token: token);
    });

    if (generation != _buildGeneration) return;
    _foregroundSubscription = useCase.foregroundMessages.listen((message) {
      useCase.showLocalNotification(message);
    });

    if (generation != _buildGeneration) return;
    _openedAppSubscription = useCase.openedAppMessages.listen(_handleMessage);

    final initialMessage = await useCase.getInitialMessage();
    if (generation != _buildGeneration) return;
    if (initialMessage != null) _handleMessage(initialMessage);
  }

  /// 로컬 알림 payload(JSON 문자열)를 메시지로 되돌려 처리한다.
  ///
  /// `showLocalNotification`이 저장한 payload는 `PushMessage.data`를
  /// `jsonEncode`한 것이므로, 복원도 동일한 변환기(`pushMessageFromData`)를
  /// 사용해 중복 구현을 피한다.
  void _handlePayload(String? payload) {
    if (payload == null || payload.isEmpty) return;

    try {
      final decoded = jsonDecode(payload) as Map<String, dynamic>;
      _handleMessage(pushMessageFromData(decoded));
    } catch (e) {
      _logger.w('알림 payload 파싱 실패', error: e);
    }
  }

  void _handleMessage(PushMessage message) {
    final storeId = joinRequestStoreIdOf(message);
    if (storeId == null) return;

    final status = ref.read(appAuthControllerProvider).value;
    if (status != AppStatus.authenticated) {
      // 스플래시·온보딩 중이면 이동할 수 없으므로 보류한다.
      _pendingMessage = message;
      return;
    }

    final router = ref.read(goRouterProvider);
    router.go(SCRoute.myPage.path);

    // go()는 선언적 이동이라 GoRouter가 다음 프레임에 Navigator의 페이지 목록을
    // 실제로 갱신한다. 프레임 1회면 충분하다 — navigatorKey.currentContext는
    // 루트 Navigator의 context로 앱 시작 후 계속 mount 상태이며(경로 전환과
    // 무관하게 유지됨), addPostFrameCallback은 go() 호출로 예약된 바로 그 프레임의
    // 빌드·레이아웃·페인트가 끝난 뒤 실행되므로 그 시점엔 마이페이지 라우트가
    // Navigator에 반영돼 있다. 모달은 Navigator 위 Overlay로 열리므로 마이페이지가
    // 전환 애니메이션 중이어도 문제없다. 그 이상 프레임을 기다릴 필요는 없다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = router.routerDelegate.navigatorKey.currentContext;
      if (context == null || !context.mounted) return;
      showPendingMemberModal(context, storeId);
    });
  }

  Future<void> _cancelSubscriptions() async {
    await _tokenSubscription?.cancel();
    await _foregroundSubscription?.cancel();
    await _openedAppSubscription?.cancel();
    _tokenSubscription = null;
    _foregroundSubscription = null;
    _openedAppSubscription = null;
  }
}
