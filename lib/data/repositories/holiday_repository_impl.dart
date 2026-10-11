import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/utils/exception_utils.dart';
import 'package:studio_chance/data/data_sources/holiday_data_source.dart';
import 'package:studio_chance/domain/entities/holiday_calendar.dart';
import 'package:studio_chance/domain/repository_interfaces/holiday_repository.dart';

part 'holiday_repository_impl.g.dart';

class HolidayRepositoryImpl implements HolidayRepository {
  final HolidayDataSource _holidayDataSource;

  HolidayRepositoryImpl({required HolidayDataSource holidayDataSource})
    : _holidayDataSource = holidayDataSource;

  @override
  Future<Either<Exception, HolidayCalendar>> getHolidayCalendar({
    required Set<int> years,
  }) async {
    try {
      final models = await _holidayDataSource.getHolidayYears(years);
      return right(
        HolidayCalendar(
          daysByYear: {
            for (final MapEntry(key: year, value: model) in models.entries)
              year: model.days,
          },
        ),
      );
    } catch (e) {
      return left(toException(e));
    }
  }
}

@Riverpod(keepAlive: true)
HolidayRepository holidayRepository(Ref ref) {
  return HolidayRepositoryImpl(
    holidayDataSource: ref.watch(holidayDataSourceProvider),
  );
}
