import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/all_day_row.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/current_time_indicator.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_cell.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/time_grid.dart';
import 'package:studio_chance/presentation/providers/home_calendar_controller.dart';

/// 3일 캘린더 최상위 위젯
/// - 좌측 고정 시간 열 (시간 레이블 + 현재 시간 캡슐)
/// - 우측 PageView (viewportFraction: 1/3, 1페이지=1일, 3일 동시 표시)
/// - 수직 스크롤: 페이지별 ScrollController + 중앙 offset 동기화
class ThreeDayCalendar extends ConsumerStatefulWidget {
  const ThreeDayCalendar({super.key});

  @override
  ConsumerState<ThreeDayCalendar> createState() => _ThreeDayCalendarState();
}

class _ThreeDayCalendarState extends ConsumerState<ThreeDayCalendar> {
  // 캘린더 지원 범위의 시작일 (2001.01.01 ~ 2100.12.31)
  static final _referenceDate = DateTime(2001, 1, 1);

  // ── 목업 이벤트 데이터 ────────────────────────────────────────────────────
  // TODO: Riverpod provider에서 실제 예약 데이터 수신으로 교체 예정.
  static final _mockEvents = _buildMockEvents();

  static List<ReservationDisplayData> _buildMockEvents() {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final tomorrow = today.add(const Duration(days: 1));
    final dayAfter = today.add(const Duration(days: 2));

    return [
      // ── 오늘: 단독 1개 + 4개 겹침(오버플로우) ──────────────────────────────

      // 종일 — 단독
      ReservationDisplayData(
        reserverName: '유훈자', headcount: 2,
        phoneNumber: '010-3109-6381',
        status: ReservationStatus.confirmed,
        colorTheme: ReservationCellColorTheme.green,
        isAllDay: true,
        date: today,
      ),

      // 07:00~08:30 — 단독 1개 (정상 셀 검증)
      ReservationDisplayData(
        reserverName: '유훈자', headcount: 2,
        phoneNumber: '010-3109-6381',
        status: ReservationStatus.confirmed,
        colorTheme: ReservationCellColorTheme.green,
        isAllDay: false,
        startTime: today.add(const Duration(hours: 7)),
        endTime: today.add(const Duration(hours: 8, minutes: 30)),
      ),

      // 10:00~XX — 4개 동시 겹침 → 오버플로우 셀 (N=4, ~26.5px < 31px)
      ReservationDisplayData(
        reserverName: '박지원', headcount: 1,
        phoneNumber: '010-1111-2222',
        status: ReservationStatus.confirmed,
        colorTheme: ReservationCellColorTheme.red,
        isAllDay: false,
        startTime: today.add(const Duration(hours: 10)),
        endTime: today.add(const Duration(hours: 11)),
      ),
      ReservationDisplayData(
        reserverName: '최수아', headcount: 2,
        phoneNumber: '010-3333-4444',
        status: ReservationStatus.confirmed,
        colorTheme: ReservationCellColorTheme.blue,
        isAllDay: false,
        startTime: today.add(const Duration(hours: 10)),
        endTime: today.add(const Duration(hours: 12)),
      ),
      ReservationDisplayData(
        reserverName: '김민준', headcount: 4,
        phoneNumber: '010-5555-1234',
        status: ReservationStatus.cancelled,
        colorTheme: ReservationCellColorTheme.green,
        isAllDay: false,
        startTime: today.add(const Duration(hours: 10)),
        endTime: today.add(const Duration(hours: 13)),
      ),
      ReservationDisplayData(
        reserverName: '이서준', headcount: 3,
        phoneNumber: '010-7777-9999',
        status: ReservationStatus.pendingPayment,
        colorTheme: ReservationCellColorTheme.yellow,
        isAllDay: false,
        startTime: today.add(const Duration(hours: 10)),
        endTime: today.add(const Duration(hours: 14)),
      ),

      // 16:00~17:00 — 단독 1개 (오버플로우 이후 정상 셀 검증)
      ReservationDisplayData(
        reserverName: '정하은', headcount: 1,
        phoneNumber: '010-8888-4444',
        status: ReservationStatus.cancelled,
        colorTheme: ReservationCellColorTheme.purple,
        isAllDay: false,
        startTime: today.add(const Duration(hours: 16)),
        endTime: today.add(const Duration(hours: 17)),
      ),

      // ── 내일 ─────────────────────────────────────────────────────────────────

      // 09:00 — N=2, delta=0 (동시 시작) → cellWidth stagger (~53px, 이름 3자)
      ReservationDisplayData(
        reserverName: '나현우', headcount: 2,
        phoneNumber: '010-2222-1111',
        status: ReservationStatus.confirmed,
        colorTheme: ReservationCellColorTheme.orange,
        isAllDay: false,
        startTime: tomorrow.add(const Duration(hours: 9)),
        endTime: tomorrow.add(const Duration(hours: 11)),
      ),
      ReservationDisplayData(
        reserverName: '임지수', headcount: 5,
        phoneNumber: '010-4444-3333',
        status: ReservationStatus.pendingPayment,
        colorTheme: ReservationCellColorTheme.indigo,
        isAllDay: false,
        startTime: tomorrow.add(const Duration(hours: 9)),
        endTime: tomorrow.add(const Duration(hours: 13)),
      ),

      // 13:00 — N=3, delta=0 → cellWidth stagger (~35px, 이름 1~2자)
      ReservationDisplayData(
        reserverName: '강민서', headcount: 3,
        phoneNumber: '010-6666-5555',
        status: ReservationStatus.confirmed,
        colorTheme: ReservationCellColorTheme.green,
        isAllDay: false,
        startTime: tomorrow.add(const Duration(hours: 13)),
        endTime: tomorrow.add(const Duration(hours: 15)),
      ),
      ReservationDisplayData(
        reserverName: '오세진', headcount: 2,
        phoneNumber: '010-8888-7777',
        status: ReservationStatus.pendingPayment,
        colorTheme: ReservationCellColorTheme.yellow,
        isAllDay: false,
        startTime: tomorrow.add(const Duration(hours: 13)),
        endTime: tomorrow.add(const Duration(hours: 16)),
      ),
      ReservationDisplayData(
        reserverName: '윤채원', headcount: 1,
        phoneNumber: '010-0000-9999',
        status: ReservationStatus.cancelled,
        colorTheme: ReservationCellColorTheme.purple,
        isAllDay: false,
        startTime: tomorrow.add(const Duration(hours: 13)),
        endTime: tomorrow.add(const Duration(hours: 17)),
      ),

      // 17:00 — N=2, delta=20분 (≤30분) → cellWidth stagger (이름 3자 표시)
      // 비겹침 구간 20분×hourHeight가 좁으므로 반절 방식으로 이름 보장
      ReservationDisplayData(
        reserverName: '한소희', headcount: 2,
        phoneNumber: '010-1357-2468',
        status: ReservationStatus.confirmed,
        colorTheme: ReservationCellColorTheme.red,
        isAllDay: false,
        startTime: tomorrow.add(const Duration(hours: 17)),
        endTime: tomorrow.add(const Duration(hours: 19, minutes: 30)),
      ),
      ReservationDisplayData(
        reserverName: '도경수', headcount: 3,
        phoneNumber: '010-2468-1357',
        status: ReservationStatus.pendingPayment,
        colorTheme: ReservationCellColorTheme.blue,
        isAllDay: false,
        startTime: tomorrow.add(const Duration(hours: 17, minutes: 20)),
        endTime: tomorrow.add(const Duration(hours: 19)),
      ),

      // 20:30 — N=2, delta=30분 (경계값, ≤30분) → cellWidth stagger
      ReservationDisplayData(
        reserverName: '박보검', headcount: 4,
        phoneNumber: '010-9999-1111',
        status: ReservationStatus.confirmed,
        colorTheme: ReservationCellColorTheme.orange,
        isAllDay: false,
        startTime: tomorrow.add(const Duration(hours: 20, minutes: 30)),
        endTime: tomorrow.add(const Duration(hours: 23)),
      ),
      ReservationDisplayData(
        reserverName: '김태리', headcount: 1,
        phoneNumber: '010-1111-9999',
        status: ReservationStatus.cancelled,
        colorTheme: ReservationCellColorTheme.indigo,
        isAllDay: false,
        startTime: tomorrow.add(const Duration(hours: 21)),
        endTime: tomorrow.add(const Duration(hours: 22, minutes: 30)),
      ),

      // ── 모레: 단독 셀들 ──────────────────────────────────────────────────────

      // 종일 — 단독
      ReservationDisplayData(
        reserverName: '최수아', headcount: 5,
        phoneNumber: '010-2222-3333',
        status: ReservationStatus.pendingPayment,
        colorTheme: ReservationCellColorTheme.orange,
        isAllDay: true,
        date: dayAfter,
      ),

      // 10:00~12:00 — 단독 1개
      ReservationDisplayData(
        reserverName: '한지민', headcount: 3,
        phoneNumber: '010-1234-5678',
        status: ReservationStatus.confirmed,
        colorTheme: ReservationCellColorTheme.indigo,
        isAllDay: false,
        startTime: dayAfter.add(const Duration(hours: 10)),
        endTime: dayAfter.add(const Duration(hours: 12)),
      ),

      // 15:00~16:00 — 단독 1개 (최소 높이 셀 검증)
      ReservationDisplayData(
        reserverName: '서동현', headcount: 1,
        phoneNumber: '010-9876-5432',
        status: ReservationStatus.confirmed,
        colorTheme: ReservationCellColorTheme.blue,
        isAllDay: false,
        startTime: dayAfter.add(const Duration(hours: 15)),
        endTime: dayAfter.add(const Duration(hours: 16)),
      ),

      // 17:00~19:00 — 단독 1개
      ReservationDisplayData(
        reserverName: '권나연', headcount: 4,
        phoneNumber: '010-5678-1234',
        status: ReservationStatus.cancelled,
        colorTheme: ReservationCellColorTheme.red,
        isAllDay: false,
        startTime: dayAfter.add(const Duration(hours: 17)),
        endTime: dayAfter.add(const Duration(hours: 19)),
      ),

      // ── 모레: N=2, delta=60분 (>30분) → 4px gap stagger (8px 고정) ──────────
      // 20:00~24:00 (4시간) + 21:00~23:00 (2시간, 내부에 포함됨)
      // delta=60분 > 30분 → 8px 고정 stagger (foreground strip+gap만 노출)
      ReservationDisplayData(
        reserverName: '송민호', headcount: 6,
        phoneNumber: '010-1111-3333',
        status: ReservationStatus.confirmed,
        colorTheme: ReservationCellColorTheme.orange,
        isAllDay: false,
        startTime: dayAfter.add(const Duration(hours: 20)),
        endTime: dayAfter.add(const Duration(hours: 24)),
      ),
      ReservationDisplayData(
        reserverName: '백지현', headcount: 2,
        phoneNumber: '010-2222-4444',
        status: ReservationStatus.pendingPayment,
        colorTheme: ReservationCellColorTheme.blue,
        isAllDay: false,
        startTime: dayAfter.add(const Duration(hours: 21)),
        endTime: dayAfter.add(const Duration(hours: 23)),
      ),
    ];
  }

  /// 특정 날짜의 이벤트 목록 반환
  static List<ReservationDisplayData> _eventsForDate(
      DateTime date, {required bool allDay}) {
    return _mockEvents.where((e) {
      if (e.isAllDay != allDay) return false;
      if (allDay) {
        final d = e.date!;
        return d.year == date.year && d.month == date.month && d.day == date.day;
      }
      final s = e.startTime!;
      return s.year == date.year && s.month == date.month && s.day == date.day;
    }).toList();
  }

  // 기준일(2001.01.01) 기준 오늘의 페이지 인덱스
  static final _initialPage = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  ).difference(_referenceDate).inDays;

  late final PageController _pageController;
  late final ScrollController _timeColumnScrollController;

  /// 현재 수직 스크롤 오프셋 (모든 날짜 열과 시간 열이 공유)
  double _currentVerticalOffset = 0.0;

  /// 재진입 방지 플래그 (_syncAllScrollControllers 무한 루프 방지)
  bool _isSyncing = false;

  /// animateToPage 진행 중 플래그
  /// onPageChanged가 중간 페이지마다 selectDateFromSwipe를 호출하는 것을 방지
  bool _isPageAnimating = false;

  /// animateToPage 중에 scrollToCurrentTime 요청이 들어온 경우 완료 후 실행
  bool _scrollToCurrentTimePending = false;

  /// 페이지 인덱스 → ScrollController 맵 (수직 스크롤 동기화)
  final Map<int, ScrollController> _dayScrollControllers = {};

  /// 핀치 줌 시작 시점의 hourHeight 기준값
  double _baseHourHeight = defaultHourHeight;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _initialPage,
      viewportFraction: 1 / 3,
    );
    _timeColumnScrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentTime());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timeColumnScrollController.dispose();
    for (final ctrl in _dayScrollControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  /// 페이지별 ScrollController 반환 (없으면 생성 또는 재생성, 리스너 자동 등록)
  ///
  /// 핵심 문제: ScrollController.initialScrollOffset은 final이라 최초 생성 시점에 고정됨.
  /// Flutter는 컨트롤러가 새 ScrollPosition에 재연결(re-attach)될 때마다 이 값을 사용함.
  ///
  /// 버그 경로:
  ///   1. 페이지가 cache extent 밖으로 나가면 위젯 unmount → hasClients = false
  ///   2. 이 사이 _currentVerticalOffset이 변경됨
  ///   3. 페이지 재진입 → itemBuilder 호출 → putIfAbsent가 기존 ctrl 반환
  ///   4. 재연결 시 stale initialScrollOffset으로 position 초기화 → notifyListeners
  ///   5. isInitialized = true 상태이므로 listener가 stale offset을 _currentVerticalOffset에 씀
  ///   6. 전체 열이 잘못된 위치로 snap됨
  ///
  /// 해결: hasClients = false인 기존 컨트롤러를 감지 → dispose 후 현재 offset으로 재생성
  ScrollController _controllerForPage(int page) {
    // 페이지가 unmount되었다가 remount될 때: 기존 컨트롤러의 initialScrollOffset이 stale함
    // → dispose하고 현재 _currentVerticalOffset으로 재생성
    final existing = _dayScrollControllers[page];
    if (existing != null && !existing.hasClients) {
      existing.dispose();
      _dayScrollControllers.remove(page);
    }

    return _dayScrollControllers.putIfAbsent(page, () {
      final ctrl = ScrollController(
        initialScrollOffset: _currentVerticalOffset,
      );
      // isInitialized = false 동안 listener 무시 → 초기 attach 시 발생하는
      // notifyListeners가 _currentVerticalOffset을 덮어쓰는 것 방지.
      // scheduleInit()에서 hasClients 확인 + offset 교정 완료 후 isInitialized = true.
      var isInitialized = false;
      ctrl.addListener(() {
        if (_isSyncing || !ctrl.hasClients) return;
        if (!isInitialized) return;
        final offset = ctrl.offset;
        if (ctrl.position.hasContentDimensions) {
          final maxExtent = ctrl.position.maxScrollExtent;
          if (offset < 0 || offset > maxExtent) {
            // bouncing 중: correctPixels로 다른 컨트롤러에 overscroll 전파
            // jumpTo()는 범위 밖 값을 거부하므로 correctPixels 사용
            _syncAllScrollControllersBouncing(offset, except: ctrl);
            return; // _currentVerticalOffset은 정상 범위 값만 추적
          }
        }
        if (offset == _currentVerticalOffset) return;
        _currentVerticalOffset = offset;
        _syncAllScrollControllers(offset, except: ctrl);
      });

      // hasClients = true 확인 후 offset 교정 → isInitialized = true
      // hasClients = false이면 다음 프레임에서 재시도 (evict 시 containsValue로 자동 중단)
      void scheduleInit() {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !_dayScrollControllers.containsValue(ctrl)) return;
          if (!ctrl.hasClients) {
            scheduleInit();
            return;
          }
          if (ctrl.offset != _currentVerticalOffset) {
            _isSyncing = true;
            try {
              ctrl.jumpTo(_currentVerticalOffset);
            } catch (_) {}
            _isSyncing = false;
          }
          isInitialized = true;
        });
      }

      scheduleInit();
      return ctrl;
    });
  }

  /// 모든 날짜 열 + 시간 열 수직 스크롤 동기화 (재진입 방지)
  void _syncAllScrollControllers(double offset, {ScrollController? except}) {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      for (final ctrl in _dayScrollControllers.values) {
        if (ctrl == except) continue;
        if (!ctrl.hasClients || ctrl.offset == offset) continue;
        try { ctrl.jumpTo(offset); } catch (_) {} // 스크롤 위치가 아직 attach 안 된 경우 무시
      }
      if (_timeColumnScrollController.hasClients &&
          _timeColumnScrollController.offset != offset) {
        try { _timeColumnScrollController.jumpTo(offset); } catch (_) {} // 동일
      }
    } finally {
      _isSyncing = false;
    }
  }

  /// bouncing 중 overscroll offset을 모든 컨트롤러에 전파
  /// correctPixels는 bounds 체크 없이 직접 pixels 설정 → 음수/초과 offset 전달 가능
  void _syncAllScrollControllersBouncing(
      double offset, {ScrollController? except}) {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      for (final ctrl in _dayScrollControllers.values) {
        if (ctrl == except || !ctrl.hasClients) continue;
        try {
          ctrl.position.correctPixels(offset);
          ctrl.position.notifyListeners();
        } catch (_) {} // position이 아직 attach 안 된 경우 무시
      }
      if (_timeColumnScrollController.hasClients) {
        try {
          _timeColumnScrollController.position.correctPixels(offset);
          _timeColumnScrollController.position.notifyListeners();
        } catch (_) {} // 동일
      }
    } finally {
      _isSyncing = false;
    }
  }

  /// 현재 페이지 ±5 범위 밖의 ScrollController를 해제하여 메모리 누수 방지
  void _evictDistantControllers(int currentPage) {
    final toRemove = _dayScrollControllers.keys
        .where((page) => (page - currentPage).abs() > 5)
        .toList();
    for (final page in toRemove) {
      _dayScrollControllers.remove(page)?.dispose();
    }
  }

  /// 현재 시간이 뷰포트 중앙에 오도록 스크롤
  void _scrollToCurrentTime() {
    final hourHeight = ref.read(homeCalendarControllerProvider).hourHeight;
    final now = DateTime.now();
    final currentOffset = hourHeight * (now.hour + now.minute / 60);

    // 임의의 active controller로 viewportDimension 파악
    double viewportHeight = 600; // fallback
    for (final ctrl in _dayScrollControllers.values) {
      if (ctrl.hasClients) {
        viewportHeight = ctrl.position.viewportDimension;
        break;
      }
    }
    if (_timeColumnScrollController.hasClients) {
      viewportHeight =
          _timeColumnScrollController.position.viewportDimension;
    }

    final maxExtent = (hourHeight * 24 - viewportHeight).clamp(0.0, double.infinity);
    final target =
        (currentOffset - viewportHeight / 2).clamp(0.0, maxExtent);
    _currentVerticalOffset = target;
    _syncAllScrollControllers(target);
  }

  DateTime _dateForPage(int page) {
    return _referenceDate.add(Duration(days: page));
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final hourHeight = ref.watch(
      homeCalendarControllerProvider.select((s) => s.hourHeight),
    );

    // 오늘 버튼 → 현재 시간 스크롤
    // animateToPage 진행 중이면 완료 후 실행 (스크롤 위치 경쟁 방지)
    ref.listen(scrollToCurrentTimeTriggerProvider, (prev, next) {
      if (prev == next) return;
      if (_isPageAnimating) {
        _scrollToCurrentTimePending = true;
      } else {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _scrollToCurrentTime());
      }
    });

    // 외부 날짜 변경 → PageView 동기화 (애니메이션 정책 분기)
    ref.listen(
      homeCalendarControllerProvider.select((s) => s.selectedStartDate),
      (prev, next) {
        if (prev == next) return;
        final targetPage = next.difference(_referenceDate).inDays;
        if (!_pageController.hasClients ||
            _pageController.page?.round() == targetPage) {
          return;
        }
        final kind = ref
            .read(homeCalendarControllerProvider.notifier)
            .consumeThreeDayTransition();
        if (kind == CalendarTransitionKind.animate) {
          _isPageAnimating = true;
          _pageController
              .animateToPage(
                targetPage,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              )
              .then((_) {
            if (mounted) {
              _isPageAnimating = false;
              // 도착 페이지에서 날짜 동기화
              ref
                  .read(homeCalendarControllerProvider.notifier)
                  .selectDateFromSwipe(_dateForPage(targetPage));
              // 애니메이션 중 예약된 scrollToCurrentTime 실행
              if (_scrollToCurrentTimePending) {
                _scrollToCurrentTimePending = false;
                _scrollToCurrentTime();
              }
            }
          });
        } else {
          _pageController.jumpToPage(targetPage);
        }
      },
    );

    // GestureDetector를 최상위로 배치 → 시간 열 포함 전체 영역에서 핀치 줌 인식
    // Stack으로 감싸서 수직 구분선을 Positioned overlay로 렌더링 (Row-level SizedBox 제거)
    return GestureDetector(
          onScaleStart: (_) {
            _baseHourHeight =
                ref.read(homeCalendarControllerProvider).hourHeight;
          },
          onScaleUpdate: (details) {
            if (details.pointerCount < 2) return;
            final oldHeight =
                ref.read(homeCalendarControllerProvider).hourHeight;
            final newHeight = (_baseHourHeight * details.scale)
                .clamp(minHourHeight, maxHourHeight);
            if (oldHeight > 0 && newHeight != oldHeight) {
              double viewportH = 600;
              if (_timeColumnScrollController.hasClients) {
                viewportH =
                    _timeColumnScrollController.position.viewportDimension;
              }
              final rawOffset =
                  _currentVerticalOffset * (newHeight / oldHeight);
              final maxOffset =
                  (newHeight * 24 - viewportH).clamp(0.0, double.infinity);
              final newOffset = rawOffset.clamp(0.0, maxOffset);
              _currentVerticalOffset = newOffset;
              _syncAllScrollControllers(newOffset);
            }
            unawaited(
              ref
                  .read(homeCalendarControllerProvider.notifier)
                  .updateHourHeight(newHeight),
            );
          },
          child: Stack(
          children: [
            Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 고정 시간 열 ──────────────────────────────
            SizedBox(
              width: timeColumnWidth,
              child: Column(
                children: [
                  // 헤더 높이 공백
                  SizedBox(height: threeDayHeaderHeight),
                  Container(
                      height: calendarDividerThickness,
                      color: context.separator),
                  // "종일" 레이블
                  SizedBox(
                    height: allDayRowHeight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '종일',
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: context.secondaryLabel,
                                ),
                      ),
                    ),
                  ),
                  Container(
                      height: calendarDividerThickness,
                      color: context.separator),
                  // 시간 레이블 + 캡슐 (수직 스크롤, 사용자 드래그 불가)
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _timeColumnScrollController,
                      physics: const NeverScrollableScrollPhysics(),
                      child: SizedBox(
                        height: hourHeight * 24,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // 시간 레이블 (1~23시)
                            // FractionalTranslation(-0.5) → 레이블 중앙이 구분선 y와 정확히 일치
                            for (int hour = 1; hour < 24; hour++)
                              Positioned(
                                top: hourHeight * hour,
                                right: 2,
                                child: FractionalTranslation(
                                  translation: const Offset(0, -0.5),
                                  child: Text(
                                    '${hour.toString().padLeft(2, '0')}:00',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: context.secondaryLabel,
                                        ),
                                  ),
                                ),
                              ),
                            // 현재 시간 캡슐: 구분선보다 나중에 paint → 구분선 위에 렌더링
                            CurrentTimeCapsule(hourHeight: hourHeight),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── 날짜 열 영역 ──────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const PageScrollPhysics(),
                // padEnds: false → 현재 페이지가 왼쪽 첫 번째 열에 표시됨 (오늘이 맨 왼쪽)
                padEnds: false,
                onPageChanged: (index) {
                  _evictDistantControllers(index);
                  // 스냅 애니메이션 완료 후 모든 컨트롤러 스크롤 위치 교정
                  // onPageChanged는 스냅 중간(0.5 경계)에 발화하므로 새로 진입하는
                  // 페이지의 컨트롤러가 stale offset으로 잠깐 보이는 현상 방지
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _syncAllScrollControllers(_currentVerticalOffset);
                  });
                  // animateToPage 중에는 중간 페이지 날짜 변경 건너뜀
                  // → monthly 캘린더가 중간 달을 순차 표시하는 현상 방지
                  if (_isPageAnimating) return;
                  ref
                      .read(homeCalendarControllerProvider.notifier)
                      .selectDateFromSwipe(_dateForPage(index));
                },
                itemBuilder: (context, index) {
                  final date = _dateForPage(index);
                  // Stack + Positioned(right border) → 헤더 행 아래부터만 right border 표시
                  return Stack(
                    children: [
                      Column(
                        children: [
                          // 요일/일자 헤더
                          SizedBox(
                            height: threeDayHeaderHeight,
                            child: _DayHeaderCell(date: date),
                          ),
                          Container(
                              height: calendarDividerThickness,
                              color: context.separator),
                          // 종일 이벤트 셀
                          AllDayCell(
                            events: _eventsForDate(date, allDay: true),
                          ),
                          Container(
                              height: calendarDividerThickness,
                              color: context.separator),
                          // 이벤트 그리드 (수직 스크롤)
                          // 핀치 줌은 ThreeDayCalendar 최상위 GestureDetector에서 처리
                          Expanded(
                            child: TimeGrid(
                              scrollController: _controllerForPage(index),
                              isToday: _isToday(date),
                              events: _eventsForDate(date, allDay: false),
                            ),
                          ),
                        ],
                      ),
                      // 헤더(28px) + 헤더구분선(0.5px) 아래부터 right border
                      Positioned(
                        top: threeDayHeaderHeight + calendarDividerThickness,
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: calendarDividerThickness,
                          color: context.separator,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        // ── 시간열↔날짜열 수직 구분선 (Positioned overlay) ──────────
        // Row-level SizedBox(0.5) 제거 → Positioned overlay로 항상 최상단에 렌더링
        // 헤더(28px) + 헤더구분선(0.5px) 아래부터 시작, 종일 행 포함 전체 하단까지 표시
        Positioned(
          left: timeColumnWidth,
          top: threeDayHeaderHeight + calendarDividerThickness,
          bottom: 0,
          child: SizedBox(
            width: calendarDividerThickness,
            child: ColoredBox(color: context.separator),
          ),
        ),
      ],
    ),
    );
  }
}

// ─── 헤더 셀 ────────────────────────────────────────────────────────────────

class _DayHeaderCell extends StatelessWidget {
  const _DayHeaderCell({required this.date});

  final DateTime date;

  static const _weekdayLabels = ['월', '화', '수', '목', '금', '토', '일'];
  String get _weekdayLabel => _weekdayLabels[date.weekday - 1];

  bool get _isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool get _isSaturday => date.weekday == DateTime.saturday;
  bool get _isSunday => date.weekday == DateTime.sunday;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _weekdayLabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _weekdayTextColor(context),
                ),
          ),
          const SizedBox(width: 4),
          _buildDayNumber(context),
        ],
      ),
    );
  }

  Color _weekdayTextColor(BuildContext context) {
    if (_isToday) return context.label;
    if (_isSaturday) return context.systemBlue;
    if (_isSunday) return context.systemRed;
    return context.secondaryLabel;
  }

  Color _dayNumberColor(BuildContext context) {
    if (_isSaturday) return context.systemBlue;
    if (_isSunday) return context.systemRed;
    return context.secondaryLabel;
  }

  Widget _buildDayNumber(BuildContext context) {
    final dayText = date.day.toString();
    if (_isToday) {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: context.label,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          dayText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.systemBackground,
              ),
        ),
      );
    }
    return Text(
      dayText,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: _dayNumberColor(context),
          ),
    );
  }
}
