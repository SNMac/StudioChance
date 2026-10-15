import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:studio_chance/domain/entities/holiday_calendar.dart';
import 'package:studio_chance/domain/use_cases/holiday_use_case_provider.dart';
import 'package:studio_chance/presentation/providers/holiday_calendar_controller.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockHolidayUseCase useCase;

  setUpAll(() => registerFallbackValue(<int>{}));

  setUp(() {
    useCase = MockHolidayUseCase();
    // 기본값: 요청한 연도마다 공휴일이 하나도 없는 달력
    when(
      () => useCase.getHolidayCalendar(years: any(named: 'years')),
    ).thenAnswer((invocation) async {
      final years = invocation.namedArguments[#years] as Set<int>;
      return right(HolidayCalendar(daysByYear: {for (final y in years) y: {}}));
    });
  });

  ProviderContainer buildContainer() {
    final container = ProviderContainer(
      overrides: [holidayUseCaseProvider.overrideWithValue(useCase)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('불러온 연도의 공휴일을 동기로 조회한다', () async {
    when(() => useCase.getHolidayCalendar(years: {2030})).thenAnswer(
      (_) async => right(
        const HolidayCalendar(
          daysByYear: {
            2030: {
              '2030-01-01': ['신정'],
            },
          },
        ),
      ),
    );
    final container = buildContainer();

    await container
        .read(holidayCalendarControllerProvider.notifier)
        .ensureYears({2030});

    final state = container.read(holidayCalendarControllerProvider);
    expect(state.calendar.isHoliday(DateTime(2030, 1, 1)), isTrue);
    expect(state.isUnconfirmed(DateTime(2030, 1, 1)), isFalse);
  });

  test('불러오는 중인 연도는 알 수 없지만 확인 실패로 보지 않는다', () async {
    final pending = Completer<Either<Exception, HolidayCalendar>>();
    when(
      () => useCase.getHolidayCalendar(years: {2030}),
    ).thenAnswer((_) => pending.future);
    final container = buildContainer();

    unawaited(
      container.read(holidayCalendarControllerProvider.notifier).ensureYears({
        2030,
      }),
    );

    final state = container.read(holidayCalendarControllerProvider);
    expect(state.calendar.isHoliday(DateTime(2030, 1, 1)), isNull);
    expect(state.isUnconfirmed(DateTime(2030, 1, 1)), isFalse);
    pending.complete(right(const HolidayCalendar(daysByYear: {2030: {}})));
  });

  test('읽지 못한 연도는 확인 실패로 본다', () async {
    when(
      () => useCase.getHolidayCalendar(years: {2030}),
    ).thenAnswer((_) async => left(Exception('네트워크 오류')));
    final container = buildContainer();

    await container
        .read(holidayCalendarControllerProvider.notifier)
        .ensureYears({2030});

    final state = container.read(holidayCalendarControllerProvider);
    expect(state.isUnconfirmed(DateTime(2030, 1, 1)), isTrue);
  });

  test('공휴일 달력이 없는 연도(동기화 범위 밖)도 확인 실패로 본다', () async {
    when(
      () => useCase.getHolidayCalendar(years: {2099}),
    ).thenAnswer((_) async => right(const HolidayCalendar()));
    final container = buildContainer();

    await container
        .read(holidayCalendarControllerProvider.notifier)
        .ensureYears({2099});

    final state = container.read(holidayCalendarControllerProvider);
    expect(state.isUnconfirmed(DateTime(2099, 1, 1)), isTrue);
  });

  test('이미 불러온 연도는 다시 조회하지 않는다', () async {
    final container = buildContainer();
    final notifier = container.read(holidayCalendarControllerProvider.notifier);

    await notifier.ensureYears({2030});
    await notifier.ensureYears({2030, 2031});

    verify(() => useCase.getHolidayCalendar(years: {2030})).called(1);
    verify(() => useCase.getHolidayCalendar(years: {2031})).called(1);
  });

  test('refreshYears는 이미 불러온 연도도 다시 조회해 바뀐 공휴일 달력을 반영한다', () async {
    // 앱 실행 중에 서버 동기화로 임시공휴일이 추가된 상황
    var calls = 0;
    when(() => useCase.getHolidayCalendar(years: {2030})).thenAnswer((_) async {
      calls++;
      return right(
        HolidayCalendar(
          daysByYear: {
            2030: calls == 1
                ? {}
                : {
                    '2030-05-07': ['임시공휴일'],
                  },
          },
        ),
      );
    });
    final container = buildContainer();
    final notifier = container.read(holidayCalendarControllerProvider.notifier);

    await notifier.ensureYears({2030});
    await notifier.refreshYears({2030});

    final state = container.read(holidayCalendarControllerProvider);
    expect(state.calendar.isHoliday(DateTime(2030, 5, 7)), isTrue);
  });
}
