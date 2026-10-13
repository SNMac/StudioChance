import 'package:freezed_annotation/freezed_annotation.dart';

part 'holiday_year_model.freezed.dart';
part 'holiday_year_model.g.dart';

/// `holidays/{year}` 문서. Cloud Functions(`functions/src/holidays/`)만 쓴다.
///
/// 서버가 함께 쓰는 `source`(공식/예측)와 `syncedAt`은 앱이 쓰지 않으므로 읽지 않는다 (ADR-0002).
@freezed
abstract class HolidayYearModel with _$HolidayYearModel {
  const factory HolidayYearModel({
    /// 날짜 키(`yyyy-MM-dd`) → 그날의 공휴일 이름들 (같은 날 공휴일이 겹칠 수 있다)
    required Map<String, List<String>> days,
  }) = _HolidayYearModel;

  factory HolidayYearModel.fromJson(Map<String, dynamic> json) =>
      _$HolidayYearModelFromJson(json);
}
