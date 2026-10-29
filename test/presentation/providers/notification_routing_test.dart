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

  group('membershipChangeStoreIdOf', () {
    for (final type in [
      'adminDelegated',
      'memberLeft',
      'memberRemoved',
      'joinApproved',
      'joinRejected',
      'storeDeleted',
    ]) {
      test('$type 메시지면 storeId를 반환한다', () {
        final message = PushMessage(type: type, data: {'storeId': 'store1'});

        expect(membershipChangeStoreIdOf(message), 'store1');
      });
    }

    test('가입 신청 메시지는 멤버 구성 변화가 아니다', () {
      const message = PushMessage(
        type: 'joinRequest',
        data: {'storeId': 'store1'},
      );

      expect(membershipChangeStoreIdOf(message), isNull);
    });

    test('storeId가 없으면 null을 반환한다', () {
      const message = PushMessage(type: 'memberRemoved', data: {});

      expect(membershipChangeStoreIdOf(message), isNull);
    });
  });

  group('membershipChangeLocationOf', () {
    for (final type in ['adminDelegated', 'memberLeft', 'joinApproved']) {
      test('$type 알림은 그 점포 상세를 연다 — 점포를 계속 볼 수 있다', () {
        final message = PushMessage(type: type, data: {'storeId': 'store1'});

        expect(membershipChangeLocationOf(message), '/my-page/store/store1');
      });
    }

    for (final type in ['memberRemoved', 'joinRejected', 'storeDeleted']) {
      test('$type 알림은 마이페이지를 연다 — 점포를 더는 볼 수 없다', () {
        final message = PushMessage(type: type, data: {'storeId': 'store1'});

        expect(membershipChangeLocationOf(message), '/my-page');
      });
    }

    test('멤버 구성 변화가 아니면 null을 반환한다', () {
      const message = PushMessage(
        type: 'joinRequest',
        data: {'storeId': 'store1'},
      );

      expect(membershipChangeLocationOf(message), isNull);
    });
  });
}
