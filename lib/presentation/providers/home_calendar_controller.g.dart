// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_calendar_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 홈 캘린더 상태 관리 컨트롤러

@ProviderFor(HomeCalendarController)
final homeCalendarControllerProvider = HomeCalendarControllerProvider._();

/// 홈 캘린더 상태 관리 컨트롤러
final class HomeCalendarControllerProvider
    extends $NotifierProvider<HomeCalendarController, HomeCalendarState> {
  /// 홈 캘린더 상태 관리 컨트롤러
  HomeCalendarControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeCalendarControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeCalendarControllerHash();

  @$internal
  @override
  HomeCalendarController create() => HomeCalendarController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeCalendarState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeCalendarState>(value),
    );
  }
}

String _$homeCalendarControllerHash() =>
    r'4b90b6440dd0ed2d4de83de4822cf684c844e0be';

/// 홈 캘린더 상태 관리 컨트롤러

abstract class _$HomeCalendarController extends $Notifier<HomeCalendarState> {
  HomeCalendarState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<HomeCalendarState, HomeCalendarState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HomeCalendarState, HomeCalendarState>,
              HomeCalendarState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
