import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/common/enums/reservation_status.dart';

void main() {
  group('ReservationStatus.jsonValue', () {
    test('pending은 PENDING을 반환한다', () {
      expect(ReservationStatus.pending.jsonValue, 'PENDING');
    });

    test('confirmed는 CONFIRMED를 반환한다', () {
      expect(ReservationStatus.confirmed.jsonValue, 'CONFIRMED');
    });

    test('canceled는 CANCELED를 반환한다', () {
      expect(ReservationStatus.canceled.jsonValue, 'CANCELED');
    });
  });
}
