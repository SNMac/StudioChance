import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/domain/entities/holiday_calendar.dart';
import 'package:studio_chance/domain/use_cases/holiday_use_case_provider.dart';

part 'holiday_calendar_controller.freezed.dart';
part 'holiday_calendar_controller.g.dart';

@freezed
abstract class HolidayCalendarState with _$HolidayCalendarState {
  const HolidayCalendarState._();

  const factory HolidayCalendarState({
    @Default(HolidayCalendar()) HolidayCalendar calendar,

    /// 조회를 마친 연도 (성공·실패·문서 없음 모두 포함). 불러오는 중인 연도는 없다.
    @Default({}) Set<int> settledYears,
  }) = _HolidayCalendarState;

  /// [date]의 공휴일 여부를 조회까지 했는데도 확인하지 못했는지 여부.
  ///
  /// 읽기 실패와 공휴일 달력이 없는 연도(동기화 범위 밖)가 해당한다. 불러오는 중이면
  /// 곧 확인되므로 false다. 화면은 이 값으로 "공휴일 여부를 확인하지 못했다"는 안내를 띄운다.
  bool isUnconfirmed(DateTime date) =>
      settledYears.contains(date.year) && calendar.isHoliday(date) == null;
}

/// 예약 모달이 가격을 동기로 계산할 수 있도록 공휴일 달력을 연도별로 들고 있는 컨트롤러.
///
/// 홈 진입 시 올해·내년분을 미리 불러오고, 모달에서 다른 연도를 고르면 그 연도를
/// [ensureYears]로 불러온다. Firestore 오프라인 캐시가 있어 대부분 바로 응답한다.
@Riverpod(keepAlive: true)
class HolidayCalendarController extends _$HolidayCalendarController {
  final Logger _logger = Logger();
  final Set<int> _loadingYears = {};
  final Set<int> _failedYears = {};

  @override
  HolidayCalendarState build() => const HolidayCalendarState();

  /// [years] 중 아직 조회하지 않았거나 읽기에 실패한 연도를 불러온다.
  ///
  /// 문서가 없던 연도(동기화 범위 밖)는 다시 조회하지 않는다 — 모달은 입력이 바뀔
  /// 때마다 호출하므로, 다시 조회하면 키 입력마다 네트워크 읽기가 일어난다.
  Future<void> ensureYears(Set<int> years) => _load(
    years
        .where(
          (year) =>
              !state.settledYears.contains(year) || _failedYears.contains(year),
        )
        .toSet(),
  );

  /// [years]를 이미 불러왔더라도 다시 조회한다.
  ///
  /// 앱을 켜둔 사이 서버 동기화로 공휴일 달력이 바뀌면(임시공휴일, 예측→공식 교체)
  /// 모달은 예전 달력으로, UseCase는 새 달력으로 계산해 화면 가격과 저장 가격이 어긋난다.
  /// 예약 모달을 열 때 호출해 공간 옵션을 새로 받는 것과 같은 수준으로 맞춘다.
  Future<void> refreshYears(Set<int> years) => _load(years);

  Future<void> _load(Set<int> years) async {
    final targets = years.where((y) => !_loadingYears.contains(y)).toSet();
    if (targets.isEmpty) return;

    _loadingYears.addAll(targets);
    final result = await ref
        .read(holidayUseCaseProvider)
        .getHolidayCalendar(years: targets);
    _loadingYears.removeAll(targets);
    if (!ref.mounted) return;

    final calendar = result.fold(
      (error) {
        _logger.w('공휴일 달력 조회 실패 — years: $targets', error: error);
        _failedYears.addAll(targets);
        return state.calendar;
      },
      (loaded) {
        _failedYears.removeAll(targets);
        // 다시 조회한 연도는 결과로 통째로 바꾼다 — 문서가 사라진 연도도 반영되도록
        final kept = {
          for (final MapEntry(key: year, value: days)
              in state.calendar.daysByYear.entries)
            if (!targets.contains(year)) year: days,
        };
        return state.calendar.copyWith(
          daysByYear: {...kept, ...loaded.daysByYear},
        );
      },
    );
    state = state.copyWith(
      calendar: calendar,
      settledYears: {...state.settledYears, ...targets},
    );
  }
}
