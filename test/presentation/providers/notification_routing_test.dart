import 'package:flutter_test/flutter_test.dart';

import 'package:studio_chance/domain/entities/push_message.dart';
import 'package:studio_chance/presentation/providers/notification_controller.dart';

void main() {
  group('joinRequestStoreIdOf', () {
    test('가입 신청 메시지면 storeId를 반환한다', () {
      const message = PushMessage(
        type: 'joinRequest',
        data: {'type': 'joinRequest', 'storeId': 'store1'},
      );

      expect(joinRequestStoreIdOf(message), 'store1');
    });

    test('다른 종류의 메시지는 null을 반환한다', () {
      const message = PushMessage(
        type: 'reservationCreated',
        data: {'storeId': 'store1'},
      );

      expect(joinRequestStoreIdOf(message), isNull);
    });

    test('storeId가 없으면 null을 반환한다', () {
      const message = PushMessage(type: 'joinRequest', data: {});

      expect(joinRequestStoreIdOf(message), isNull);
    });

    test('storeId가 빈 문자열이면 null을 반환한다', () {
      const message = PushMessage(type: 'joinRequest', data: {'storeId': ''});

      expect(joinRequestStoreIdOf(message), isNull);
    });
  });
}
