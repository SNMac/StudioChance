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

/// isContinuation 셀 탭 시 지정 시간으로 수직 스크롤하는 트리거

@ProviderFor(ScrollToTimeTrigger)
final scrollToTimeTriggerProvider = ScrollToTimeTriggerProvider._();

/// isContinuation 셀 탭 시 지정 시간으로 수직 스크롤하는 트리거
final class ScrollToTimeTriggerProvider
    extends $NotifierProvider<ScrollToTimeTrigger, DateTime?> {
  /// isContinuation 셀 탭 시 지정 시간으로 수직 스크롤하는 트리거
  ScrollToTimeTriggerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scrollToTimeTriggerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scrollToTimeTriggerHash();

  @$internal
  @override
  ScrollToTimeTrigger create() => ScrollToTimeTrigger();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime?>(value),
    );
  }
}

String _$scrollToTimeTriggerHash() =>
    r'4875e47942cabb804947c115ecb9f74e36e359f3';

/// isContinuation 셀 탭 시 지정 시간으로 수직 스크롤하는 트리거

abstract class _$ScrollToTimeTrigger extends $Notifier<DateTime?> {
  DateTime? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DateTime?, DateTime?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime?, DateTime?>,
              DateTime?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// isContinuation 탭 시 원본 날짜 TimeGrid에 하이라이트를 전달하기 위한 Provider

@ProviderFor(PendingHighlightId)
final pendingHighlightIdProvider = PendingHighlightIdProvider._();

/// isContinuation 탭 시 원본 날짜 TimeGrid에 하이라이트를 전달하기 위한 Provider
final class PendingHighlightIdProvider
    extends $NotifierProvider<PendingHighlightId, String?> {
  /// isContinuation 탭 시 원본 날짜 TimeGrid에 하이라이트를 전달하기 위한 Provider
  PendingHighlightIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingHighlightIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingHighlightIdHash();

  @$internal
  @override
  PendingHighlightId create() => PendingHighlightId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$pendingHighlightIdHash() =>
    r'1aa0cbcc30e46c3ab4cba30ead9e173056b19396';

/// isContinuation 탭 시 원본 날짜 TimeGrid에 하이라이트를 전달하기 위한 Provider

abstract class _$PendingHighlightId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
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
    r'273e19954cffa6c2cb46fdf82d783fa7af6e37fe';

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
