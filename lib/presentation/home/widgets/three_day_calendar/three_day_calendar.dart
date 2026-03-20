import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/all_day_row.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/current_time_indicator.dart';
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

  /// 페이지별 ScrollController 반환 (없으면 생성, 리스너 자동 등록)
  ScrollController _controllerForPage(int page) {
    return _dayScrollControllers.putIfAbsent(page, () {
      final ctrl = ScrollController(
        initialScrollOffset: _currentVerticalOffset,
      );
      ctrl.addListener(() {
        if (_isSyncing || !ctrl.hasClients) return;
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
    return _referenceDate.add(Duration(days: page - _initialPage));
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
    ref.listen(scrollToCurrentTimeTriggerProvider, (prev, next) {
      if (prev == next) return;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollToCurrentTime());
    });

    // 외부 날짜 변경 → PageView 동기화 (애니메이션 정책 분기)
    ref.listen(
      homeCalendarControllerProvider.select((s) => s.selectedStartDate),
      (prev, next) {
        if (prev == next) return;
        final delta = next.difference(_referenceDate).inDays;
        final targetPage = _initialPage + delta;
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
            }
          });
        } else {
          _pageController.jumpToPage(targetPage);
        }
      },
    );

    // GestureDetector를 최상위로 배치 → 시간 열 포함 전체 영역에서 핀치 줌 인식
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
          child: Row(
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

            // ── 시간열↔날짜열 수직 구분선 ─────────────────
            // 헤더(28px) + 헤더구분선(0.5px) 영역은 구분선 없음, 종일 행부터 바닥까지 표시
            SizedBox(
              width: calendarDividerThickness,
              child: Column(
                children: [
                  SizedBox(height: threeDayHeaderHeight + calendarDividerThickness),
                  Expanded(child: ColoredBox(color: context.separator)),
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
                          const AllDayCell(),
                          Container(
                              height: calendarDividerThickness,
                              color: context.separator),
                          // 이벤트 그리드 (수직 스크롤)
                          // 핀치 줌은 ThreeDayCalendar 최상위 GestureDetector에서 처리
                          Expanded(
                            child: TimeGrid(
                              scrollController: _controllerForPage(index),
                              isToday: _isToday(date),
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
