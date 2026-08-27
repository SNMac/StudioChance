import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:studio_chance/data/models/push_message_mapper.dart';

void main() {
  group('RemoteMessageMapper', () {
    test('notification과 data를 엔티티로 옮긴다', () {
      const remoteMessage = RemoteMessage(
        notification: RemoteNotification(title: '가입 신청', body: '홍길동님이 신청했습니다.'),
        data: {'type': 'joinRequest', 'storeId': 'store1'},
      );

      final entity = remoteMessage.toEntity();

      expect(entity.type, 'joinRequest');
      expect(entity.title, '가입 신청');
      expect(entity.body, '홍길동님이 신청했습니다.');
      expect(entity.data['storeId'], 'store1');
    });

    test('type이 없으면 빈 문자열로 처리한다', () {
      const remoteMessage = RemoteMessage(data: {'storeId': 'store1'});

      expect(remoteMessage.toEntity().type, '');
    });

    test('notification이 없어도 변환된다', () {
      const remoteMessage = RemoteMessage(data: {'type': 'joinRequest'});

      final entity = remoteMessage.toEntity();

      expect(entity.title, isNull);
      expect(entity.body, isNull);
      expect(entity.type, 'joinRequest');
    });

    test('data가 비어 있어도 안전하다', () {
      const remoteMessage = RemoteMessage();

      final entity = remoteMessage.toEntity();

      expect(entity.type, '');
      expect(entity.data, isEmpty);
    });
  });

  group('pushMessageFromData', () {
    test('data 맵만으로 엔티티를 만든다', () {
      final entity = pushMessageFromData({
        'type': 'joinRequest',
        'storeId': 'store1',
      });

      expect(entity.type, 'joinRequest');
      expect(entity.data['storeId'], 'store1');
      expect(entity.title, isNull);
    });
  });
}
