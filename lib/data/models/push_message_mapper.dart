import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:studio_chance/domain/entities/push_message.dart';

/// FCM `RemoteMessage`를 도메인 엔티티로 변환한다.
extension RemoteMessageMapper on RemoteMessage {
  PushMessage toEntity() {
    return PushMessage(
      type: data['type']?.toString() ?? '',
      title: notification?.title,
      body: notification?.body,
      data: _stringifyValues(data),
    );
  }
}

/// 로컬 알림 payload 등 `data` 맵만 남은 상황에서 엔티티를 복원한다.
PushMessage pushMessageFromData(Map<String, dynamic> data) {
  return PushMessage(
    type: data['type']?.toString() ?? '',
    data: _stringifyValues(data),
  );
}

Map<String, String> _stringifyValues(Map<String, dynamic> data) {
  return data.map((key, value) => MapEntry(key, value?.toString() ?? ''));
}
