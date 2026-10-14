import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/domain/entities/holiday_calendar.dart';
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

  group('holidayCheckerFor', () {
    // 2026-05-01(금) 10~12시 예약. 저장 당시 5/1을 공휴일로 계산했다
    final saved = fakeReservation.copyWith(
      spaceOptionId: 'space-a',
      priceSetting: const PriceSetting(dayGroups: []),
      holidayDates: ['2026-05-01'],
    );
    // 현재 공휴일 달력에서는 5/1이 공휴일이 아니고 5/8이 공휴일이다
    const current = HolidayCalendar(
      daysByYear: {
        2026: {
          '2026-05-08': ['임시공휴일'],
        },
      },
    );

    test('같은 날 안에서 시간만 바꾸면 저장된 공휴일 판정을 쓴다', () {
      final edited = saved.copyWith(
        startTime: DateTime(2026, 5, 1, 14),
        endTime: DateTime(2026, 5, 1, 16),
      );

      final isHoliday = saved.holidayCheckerFor(edited, current);

      expect(isHoliday(DateTime(2026, 5, 1)), isTrue);
    });

    test('저장된 예약 기간 밖으로 옮긴 날짜는 현재 공휴일 달력으로 판정한다', () {
      final edited = saved.copyWith(
        startTime: DateTime(2026, 5, 8, 10),
        endTime: DateTime(2026, 5, 8, 12),
      );

      final isHoliday = saved.holidayCheckerFor(edited, current);

      expect(isHoliday(DateTime(2026, 5, 8)), isTrue);
    });

    test('공간이 바뀌면 저장된 기간 안의 날짜도 현재 공휴일 달력으로 판정한다', () {
      final edited = saved.copyWith(spaceOptionId: 'space-b');

      final isHoliday = saved.holidayCheckerFor(edited, current);

      expect(isHoliday(DateTime(2026, 5, 1)), isFalse);
    });

    test('공휴일 스냅샷이 없으면 현재 공휴일 달력으로 판정한다', () {
      final noSnapshot = saved.copyWith(holidayDates: null);

      final isHoliday = noSnapshot.holidayCheckerFor(noSnapshot, current);

      expect(isHoliday(DateTime(2026, 5, 1)), isFalse);
    });

    test('현재 공휴일 달력에 없는 연도는 공휴일이 아닌 것으로 판정한다', () {
      final edited = saved.copyWith(
        startTime: DateTime(2052, 1, 1, 10),
        endTime: DateTime(2052, 1, 1, 12),
      );

      final isHoliday = saved.holidayCheckerFor(edited, current);

      expect(isHoliday(DateTime(2052, 1, 1)), isFalse);
    });
  });

  group('holidayDatesWith', () {
    test('하루종일 예약은 예약 기간 중 공휴일로 판정된 날짜만 담는다', () {
      final allDay = fakeReservation.copyWith(
        isAllDay: true,
        startTime: DateTime(2026, 5, 4),
        endTime: DateTime(2026, 5, 7), // 3일: 5/4, 5/5, 5/6
      );

      final dates = allDay.holidayDatesWith(
        (date) => date.day == 5 || date.day == 6,
      );

      expect(dates, ['2026-05-05', '2026-05-06']);
    });

    test('자정을 넘는 시간 지정 예약은 걸친 날짜를 모두 판정한다', () {
      // 밤샘 예약: 5/4 22시 ~ 5/5 02시. 5/5 새벽은 5/5의 요일 그룹으로 계산한다
      final overnight = fakeReservation.copyWith(
        startTime: DateTime(2026, 5, 4, 22),
        endTime: DateTime(2026, 5, 5, 2),
      );

      final dates = overnight.holidayDatesWith((date) => date.day == 5);

      expect(dates, ['2026-05-05']);
    });

    test('종료가 정확히 자정인 시간 지정 예약은 다음 날을 판정하지 않는다', () {
      final untilMidnight = fakeReservation.copyWith(
        startTime: DateTime(2026, 5, 4, 22),
        endTime: DateTime(2026, 5, 5),
      );

      final dates = untilMidnight.holidayDatesWith((date) => date.day == 5);

      expect(dates, isEmpty);
    });
  });

  group('holidaysDifferFromCurrent', () {
    final saved = fakeReservation.copyWith(
      spaceOptionId: 'space-a',
      priceSetting: const PriceSetting(dayGroups: []),
      holidayDates: [], // 5/1을 공휴일이 아닌 것으로 계산했다
    );

    test('저장된 판정과 현재 공휴일 달력이 다르면 true', () {
      const current = HolidayCalendar(
        daysByYear: {
          2026: {
            '2026-05-01': ['노동절'],
          },
        },
      );

      expect(saved.holidaysDifferFromCurrent(saved, current), isTrue);
    });

    test('저장된 판정과 현재 공휴일 달력이 같으면 false', () {
      const current = HolidayCalendar(daysByYear: {2026: {}});

      expect(saved.holidaysDifferFromCurrent(saved, current), isFalse);
    });

    test('현재 공휴일 달력이 모르는 연도는 다르다고 보지 않는다', () {
      final withHoliday = saved.copyWith(holidayDates: ['2026-05-01']);

      expect(
        withHoliday.holidaysDifferFromCurrent(
          withHoliday,
          const HolidayCalendar(),
        ),
        isFalse,
      );
    });

    test('요금표를 유지하지 않는 수정이면 false (어차피 현재 달력으로 계산한다)', () {
      const current = HolidayCalendar(
        daysByYear: {
          2026: {
            '2026-05-01': ['노동절'],
          },
        },
      );
      final edited = saved.copyWith(spaceOptionId: 'space-b');

      expect(saved.holidaysDifferFromCurrent(edited, current), isFalse);
    });
  });

  group('holidaySnapshotKeysFor', () {
    // 2026-05-04 ~ 05-06 하루종일 예약 (3일)
    final saved = fakeReservation.copyWith(
      spaceOptionId: 'space-a',
      priceSetting: const PriceSetting(dayGroups: []),
      holidayDates: ['2026-05-05'],
      isAllDay: true,
      startTime: DateTime(2026, 5, 4),
      endTime: DateTime(2026, 5, 7),
    );

    test('요금표를 유지하는 수정이면 저장된 예약 기간의 날짜들을 돌려준다', () {
      expect(saved.holidaySnapshotKeysFor(saved), {
        '2026-05-04',
        '2026-05-05',
        '2026-05-06',
      });
    });

    test('요금표를 유지하지 않는 수정이면 비어 있다', () {
      final edited = saved.copyWith(spaceOptionId: 'space-b');

      expect(saved.holidaySnapshotKeysFor(edited), isEmpty);
    });

    test('공휴일 스냅샷이 없으면 비어 있다', () {
      final noSnapshot = saved.copyWith(holidayDates: null);

      expect(noSnapshot.holidaySnapshotKeysFor(noSnapshot), isEmpty);
    });
  });

  test('pricedYears는 가격 계산에 쓰는 날짜들의 연도다 (연말을 넘는 하루종일 예약)', () {
    final yearEnd = fakeReservation.copyWith(
      isAllDay: true,
      startTime: DateTime(2026, 12, 31),
      endTime: DateTime(2027, 1, 2),
    );

    expect(yearEnd.pricedYears, {2026, 2027});
  });
}
