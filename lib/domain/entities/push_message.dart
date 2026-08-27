import 'package:freezed_annotation/freezed_annotation.dart';

part 'push_message.freezed.dart';

/// 수신한 푸시 알림의 도메인 표현
///
/// firebase_messaging의 `RemoteMessage`가 Domain·Presentation 계층으로
/// 새지 않도록 Data 계층 경계에서 이 엔티티로 변환한다.
@freezed
abstract class PushMessage with _$PushMessage {
  const PushMessage._();

  const factory PushMessage({
    /// 푸시 종류. `joinRequestNotificationType` 등과 비교한다.
    required String type,
    String? title,
    String? body,
    @Default({}) Map<String, String> data,
  }) = _PushMessage;
}
