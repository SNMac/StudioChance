import 'package:fpdart/fpdart.dart';
import 'package:studio_chance/domain/entities/holiday_calendar.dart';

abstract interface class HolidayRepository {
  /// [years]의 공휴일 달력 조회.
  ///
  /// 공휴일 달력이 없는 연도(동기화 범위 밖)는 결과에서 빠진다 —
  /// [HolidayCalendar.isHoliday]가 그 연도에 null을 돌려준다.
  Future<Either<Exception, HolidayCalendar>> getHolidayCalendar({
    required Set<int> years,
  });
}
