// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_calendar_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 오늘 버튼 클릭 시 3일 캘린더 스크롤 트리거 (값이 바뀔 때마다 스크롤 실행)

@ProviderFor(ScrollToCurrentTimeTrigger)
final scrollToCurrentTimeTriggerProvider =
    ScrollToCurrentTimeTriggerProvider._();

/// 오늘 버튼 클릭 시 3일 캘린더 스크롤 트리거 (값이 바뀔 때마다 스크롤 실행)
final class ScrollToCurrentTimeTriggerProvider
    extends $NotifierProvider<ScrollToCurrentTimeTrigger, int> {
  /// 오늘 버튼 클릭 시 3일 캘린더 스크롤 트리거 (값이 바뀔 때마다 스크롤 실행)
  ScrollToCurrentTimeTriggerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scrollToCurrentTimeTriggerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scrollToCurrentTimeTriggerHash();

  @$internal
  @override
  ScrollToCurrentTimeTrigger create() => ScrollToCurrentTimeTrigger();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$scrollToCurrentTimeTriggerHash() =>
    r'b1b698e7c100f9f4792ef8814a08dcb8c9df289c';

/// 오늘 버튼 클릭 시 3일 캘린더 스크롤 트리거 (값이 바뀔 때마다 스크롤 실행)

abstract class _$ScrollToCurrentTimeTrigger extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

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
    r'3cdddb7d83249b447cd4afddd4ad1d634814e32b';

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
