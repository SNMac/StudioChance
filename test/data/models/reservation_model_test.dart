import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/common/enums/weekday.dart';
import 'package:studio_chance/data/models/reservation_model.dart';
import 'package:studio_chance/domain/entities/day_group.dart';
import 'package:studio_chance/domain/entities/headcount_rule.dart';
import 'package:studio_chance/domain/entities/price_setting.dart';
import 'package:studio_chance/domain/entities/time_slot.dart';

import '../../helpers/fake_data.dart';

const _priceSetting = PriceSetting(
  dayGroups: [
    DayGroup(
      days: [Weekday.friday],
      headcountRule: HeadcountRule(
        headcountBase: 2,
        headcountExtraPrice: 1000,
        isHeadcountHourly: true,
        isHeadcountPerPerson: true,
      ),
      timeSlots: [
        TimeSlot(
          isAllDay: false,
          startTime: 0,
          endTime: 1440,
          price: 10000,
          isHourly: true,
          isPerPerson: false,
        ),
      ],
    ),
  ],
);

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

    test('요금표 스냅샷이 있으면 포함한다', () {
      final json = ReservationModel.fromEntity(
        fakeReservation.copyWith(priceSetting: _priceSetting),
      ).toUpdateJson();

      expect(json['priceSettings'], isA<Map<String, dynamic>>());
    });
  });

  group('요금표 스냅샷', () {
    test('엔티티 → JSON → 엔티티 왕복 후에도 유지된다', () {
      final json = ReservationModel.fromEntity(
        fakeReservation.copyWith(priceSetting: _priceSetting),
      ).toJson();

      final restored = ReservationModel.fromJson({
        ...json,
        'id': fakeReservation.id,
      }).toEntity(fakeReservation.storeSummary, fakeReservation.writer);

      expect(restored.priceSetting, _priceSetting);
    });

    test('스냅샷이 없는 문서는 null로 읽는다', () {
      final json = fakeReservationModel.toJson();

      final restored = ReservationModel.fromJson({
        ...json,
        'id': fakeReservationModel.id,
      }).toEntity(fakeReservation.storeSummary, fakeReservation.writer);

      expect(json.containsKey('priceSettings'), false);
      expect(restored.priceSetting, isNull);
    });
  });
}
