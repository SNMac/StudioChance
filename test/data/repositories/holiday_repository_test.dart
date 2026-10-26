import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/data/data_sources/holiday_data_source.dart';
import 'package:studio_chance/data/repositories/holiday_repository_impl.dart';
import 'package:studio_chance/domain/entities/holiday_calendar.dart';

import '../../helpers/either_expectations.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late HolidayRepositoryImpl repository;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    repository = HolidayRepositoryImpl(
      holidayDataSource: HolidayFirestoreDataSource(firestore),
    );
    // 서버(Functions)가 쓰는 문서 형태 그대로 시드한다
    await firestore.doc('holidays/2026').set({
      'days': {
        '2026-05-01': ['노동절'],
        '2026-05-05': ['어린이날'],
      },
      'source': 'official',
      'syncedAt': DateTime(2026, 10, 1),
    });
    await firestore.doc('holidays/2027').set({
      'days': {
        '2027-05-13': ['부처님오신날', '테스트 공휴일'],
      },
      'source': 'predicted',
      'syncedAt': DateTime(2026, 10, 1),
    });
  });

  test('요청한 연도의 공휴일 날짜와 이름을 읽는다', () async {
    final result = await repository.getHolidayCalendar(years: {2026, 2027});

    final calendar = expectRight(result);
    expect(
      calendar,
      const HolidayCalendar(
        daysByYear: {
          2026: {
            '2026-05-01': ['노동절'],
            '2026-05-05': ['어린이날'],
          },
          2027: {
            '2027-05-13': ['부처님오신날', '테스트 공휴일'],
          },
        },
      ),
    );
  });

  test('공휴일 달력이 없는 연도는 결과에서 빠져 알 수 없는 연도가 된다', () async {
    final result = await repository.getHolidayCalendar(years: {2026, 2099});

    final calendar = expectRight(result);
    expect(calendar.isHoliday(DateTime(2026, 5, 1)), isTrue);
    expect(calendar.isHoliday(DateTime(2099, 1, 1)), isNull);
  });
}
