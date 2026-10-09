import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/domain/entities/price_setting.dart';
import 'package:studio_chance/domain/entities/reservation.dart';

import '../../helpers/fake_entities.dart';

void main() {
  group('keepsPriceSettingFor', () {
    const snapshot = PriceSetting(dayGroups: []);
    final saved = fakeReservation.copyWith(
      spaceOptionId: 'space-a',
      priceSetting: snapshot,
    );

    test('점포·공간이 같으면 저장된 요금표를 유지한다', () {
      final edited = saved.copyWith(
        headCount: 3,
        startTime: DateTime(2026, 5, 1, 9),
        memo: '메모 변경',
      );

      expect(saved.keepsPriceSettingFor(edited), isTrue);
    });

    test('점포 표시 정보(이름·색상)만 다르면 같은 점포로 본다', () {
      final edited = saved.copyWith(
        storeSummary: fakeStoreSummary.copyWith(
          name: '다른 이름',
          color: StoreColor.red,
        ),
      );

      expect(saved.keepsPriceSettingFor(edited), isTrue);
    });

    test('공간이 바뀌면 유지하지 않는다', () {
      final edited = saved.copyWith(spaceOptionId: 'space-b');

      expect(saved.keepsPriceSettingFor(edited), isFalse);
    });

    test('점포가 바뀌면 유지하지 않는다', () {
      final edited = saved.copyWith(
        storeSummary: fakeStoreSummary.copyWith(id: 'store-other'),
      );

      expect(saved.keepsPriceSettingFor(edited), isFalse);
    });

    test('저장된 요금표가 없으면 유지하지 않는다', () {
      final noSnapshot = saved.copyWith(priceSetting: null);

      expect(noSnapshot.keepsPriceSettingFor(noSnapshot), isFalse);
    });
  });
}
