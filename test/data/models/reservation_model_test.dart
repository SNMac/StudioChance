import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_data.dart';

void main() {
  group('toUpdateJson', () {
    test('불변 필드(storeId, writerId, writerRole)를 포함하지 않는다', () {
      final json = fakeReservationModel.toUpdateJson();

      expect(json.containsKey('storeId'), false);
      expect(json.containsKey('writerId'), false);
      expect(json.containsKey('writerRole'), false);
    });

    test('수정 가능 필드는 모두 포함한다', () {
      final json = fakeReservationModel.toUpdateJson();

      const editableFields = {
        'status', 'customerName', 'headCount', 'customerPhone', 'memo',
        'isAllDay', 'startTime', 'endTime', 'platform', 'paymentMethod',
        'calculatedPrice', 'priceAdjustment', 'totalPrice', 'spaceOptionId',
      };
      for (final field in editableFields) {
        expect(json.containsKey(field), true, reason: '$field 누락');
      }
    });

    test('id는 포함하지 않는다', () {
      final json = fakeReservationModel.toUpdateJson();
      expect(json.containsKey('id'), false);
    });
  });
}
