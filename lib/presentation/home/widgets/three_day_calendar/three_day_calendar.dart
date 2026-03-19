import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/all_day_row.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/time_grid.dart';
import 'package:studio_chance/presentation/providers/home_calendar_controller.dart';

/// 3일 캘린더 최상위 위젯
/// PageView로 전체 영역을 감싸 연속 스크롤 + 1일 스냅 날짜 이동을 지원함
/// 시간 그리드 수직 스크롤은 shared ScrollController로 페이지 간 위치 유지
class ThreeDayCalendar extends ConsumerStatefulWidget {
  const ThreeDayCalendar({super.key});

  @override
  ConsumerState<ThreeDayCalendar> createState() => _ThreeDayCalendarState();
}

class _ThreeDayCalendarState extends ConsumerState<ThreeDayCalendar> {
  static const _initialPage = 10000;

  /// 앱 시작 시 기준일 (시간 제거)
  final _referenceDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  late final PageController _pageController;

  /// 모든 페이지가 공유하는 수직 ScrollController (스크롤 위치 유지)
  late final ScrollController _sharedScrollController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
    _sharedScrollController = ScrollController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _sharedScrollController.dispose();
    super.dispose();
  }

  /// 현재 시간이 뷰포트 중앙에 오도록 스크롤
  void _scrollToCurrentTime() {
    if (!_sharedScrollController.hasClients) return;
    final hourHeight = ref.read(homeCalendarControllerProvider).hourHeight;
    final now = DateTime.now();
    final currentOffset = hourHeight * (now.hour + now.minute / 60);
    final viewportHeight = _sharedScrollController.position.viewportDimension;
    final maxExtent = _sharedScrollController.position.maxScrollExtent;
    final target =
        (currentOffset - viewportHeight / 2).clamp(0.0, maxExtent);
    _sharedScrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// 페이지 인덱스를 날짜로 변환
  DateTime _dateForPage(int page) {
    return _referenceDate.add(Duration(days: page - _initialPage));
  }

  @override
  Widget build(BuildContext context) {
    // 오늘 버튼 클릭 시 현재 시간으로 스크롤
    ref.listen(scrollToCurrentTimeTriggerProvider, (prev, next) {
      if (prev == next) return;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentTime());
    });

    // 외부(goToToday, 월간 캘린더 선택)에서 selectedStartDate 변경 시 PageView 동기화
    ref.listen(
      homeCalendarControllerProvider.select((s) => s.selectedStartDate),
      (prev, next) {
        if (prev == next) return;
        final delta = next.difference(_referenceDate).inDays;
        final targetPage = _initialPage + delta;
        if (_pageController.hasClients &&
            _pageController.page?.round() != targetPage) {
          _pageController.jumpToPage(targetPage);
        }
      },
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // 열 사이 구분선 위치 계산
        // 가용 너비 = 전체 - 시간 열(44) - gap(1.5)
        final colWidth = (constraints.maxWidth - timeColumnWidth - 1.5) / 3;
        // 구분선 시작 top = 헤더(28) + 헤더 구분선(0.5)
        const dividerTop = threeDayHeaderHeight + 0.5;

        return Stack(
      children: [
        // PageView가 전체 영역을 감싸 좌우 스와이프 감지
        PageView.builder(
          controller: _pageController,
          physics: const PageScrollPhysics(),
          onPageChanged: (index) {
            final newStart = _dateForPage(index);
            ref
                .read(homeCalendarControllerProvider.notifier)
                .selectDate(newStart);
          },
          itemBuilder: (context, index) {
            return Column(
              children: [
                // 요일/일자 헤더 (구분선 없음)
                SizedBox(
                  height: threeDayHeaderHeight,
                  child: _ThreeDayHeaderPage(startDate: _dateForPage(index)),
                ),
                // 헤더 하단 구분선
                Divider(
                  height: 0.5,
                  thickness: 0.5,
                  color: context.separator,
                ),
                // 종일 이벤트 행
                const AllDayRow(),
                // 시간 그리드 (shared ScrollController로 수직 위치 유지)
                Expanded(
                  child: TimeGrid(scrollController: _sharedScrollController),
                ),
              ],
            );
          },
        ),
        // 시간 열↔날짜 열 세로 구분선 오버레이
        // 종일 행 상단(dividerTop)부터 시작, bouncing 시에도 끊기지 않도록 전체 높이
        Positioned(
          left: timeColumnWidth + 1.0,
          top: dividerTop,
          bottom: 0,
          child: Container(width: 0.5, color: context.separator),
        ),
        // 1번째↔2번째 열 사이 구분선
        Positioned(
          left: timeColumnWidth + 1.5 + colWidth,
          top: dividerTop,
          bottom: 0,
          child: Container(width: 0.5, color: context.separator),
        ),
        // 2번째↔3번째 열 사이 구분선
        Positioned(
          left: timeColumnWidth + 1.5 + colWidth * 2 + 0.5,
          top: dividerTop,
          bottom: 0,
          child: Container(width: 0.5, color: context.separator),
        ),
      ],
        );
      },
    );
  }
}

/// PageView 각 페이지용 헤더 (요일+일자 수평 표시, 구분선 없음)
class _ThreeDayHeaderPage extends StatelessWidget {
  const _ThreeDayHeaderPage({required this.startDate});

  final DateTime startDate;

  @override
  Widget build(BuildContext context) {
    final days = List.generate(3, (i) => startDate.add(Duration(days: i)));

    return Row(
      children: [
        // 좌측 시간 컬럼 너비 확보 (구분선 없음)
        SizedBox(width: timeColumnWidth + 1.5),
        // 3열 날짜 헤더 (열 사이 구분선 없음)
        Expanded(
          child: Row(
            children: days
                .map((day) => Expanded(child: _DayHeaderCell(date: day)))
                .toList(),
          ),
        ),
      ],
    );
  }
}

/// 하루 날짜 헤더 셀: 요일 + 일자 수평 표시
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
