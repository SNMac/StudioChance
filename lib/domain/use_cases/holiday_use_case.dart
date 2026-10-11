import 'package:fpdart/fpdart.dart';
import 'package:studio_chance/domain/entities/holiday_calendar.dart';
import 'package:studio_chance/domain/repository_interfaces/holiday_repository.dart';

abstract interface class HolidayUseCase {
  /// [years]의 공휴일 달력 조회. 공휴일 달력이 없는 연도는 결과에서 빠진다.
  Future<Either<Exception, HolidayCalendar>> getHolidayCalendar({
    required Set<int> years,
  });
}

/// 화면이 Repository를 직접 부르지 않도록 하는 단순 위임 UseCase (D10).
class HolidayUseCaseImpl implements HolidayUseCase {
  final HolidayRepository _repository;

  HolidayUseCaseImpl(this._repository);

  @override
  Future<Either<Exception, HolidayCalendar>> getHolidayCalendar({
    required Set<int> years,
  }) => _repository.getHolidayCalendar(years: years);
}
