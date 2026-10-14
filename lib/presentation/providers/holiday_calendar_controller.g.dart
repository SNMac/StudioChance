// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'holiday_calendar_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 예약 모달이 가격을 동기로 계산할 수 있도록 공휴일 달력을 연도별로 들고 있는 컨트롤러.
///
/// 홈 진입 시 올해·내년분을 미리 불러오고, 모달에서 다른 연도를 고르면 그 연도를
/// [ensureYears]로 불러온다. Firestore 오프라인 캐시가 있어 대부분 바로 응답한다.

@ProviderFor(HolidayCalendarController)
final holidayCalendarControllerProvider = HolidayCalendarControllerProvider._();

/// 예약 모달이 가격을 동기로 계산할 수 있도록 공휴일 달력을 연도별로 들고 있는 컨트롤러.
///
/// 홈 진입 시 올해·내년분을 미리 불러오고, 모달에서 다른 연도를 고르면 그 연도를
/// [ensureYears]로 불러온다. Firestore 오프라인 캐시가 있어 대부분 바로 응답한다.
final class HolidayCalendarControllerProvider
    extends $NotifierProvider<HolidayCalendarController, HolidayCalendarState> {
  /// 예약 모달이 가격을 동기로 계산할 수 있도록 공휴일 달력을 연도별로 들고 있는 컨트롤러.
  ///
  /// 홈 진입 시 올해·내년분을 미리 불러오고, 모달에서 다른 연도를 고르면 그 연도를
  /// [ensureYears]로 불러온다. Firestore 오프라인 캐시가 있어 대부분 바로 응답한다.
  HolidayCalendarControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'holidayCalendarControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$holidayCalendarControllerHash();

  @$internal
  @override
  HolidayCalendarController create() => HolidayCalendarController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HolidayCalendarState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HolidayCalendarState>(value),
    );
  }
}

String _$holidayCalendarControllerHash() =>
    r'4805766931e2325c3662c48ca42bd175a1199b99';

/// 예약 모달이 가격을 동기로 계산할 수 있도록 공휴일 달력을 연도별로 들고 있는 컨트롤러.
///
/// 홈 진입 시 올해·내년분을 미리 불러오고, 모달에서 다른 연도를 고르면 그 연도를
/// [ensureYears]로 불러온다. Firestore 오프라인 캐시가 있어 대부분 바로 응답한다.

abstract class _$HolidayCalendarController
    extends $Notifier<HolidayCalendarState> {
  HolidayCalendarState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<HolidayCalendarState, HolidayCalendarState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HolidayCalendarState, HolidayCalendarState>,
              HolidayCalendarState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
