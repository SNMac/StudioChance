import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/home/widgets/monthly_calendar/monthly_calendar_grid.dart';
import 'package:studio_chance/presentation/home/widgets/monthly_calendar/monthly_calendar_header.dart';
import 'package:studio_chance/presentation/providers/home_calendar_controller.dart';

/// 월간 캘린더 (요일 헤더 + 날짜 그리드 조합, PageView로 좌우 스크롤 가능)
class MonthlyCalendar extends ConsumerStatefulWidget {
  const MonthlyCalendar({super.key});

  @override
  ConsumerState<MonthlyCalendar> createState() => _MonthlyCalendarState();
}

class _MonthlyCalendarState extends ConsumerState<MonthlyCalendar> {
  static const _initialPage = 10000;
  final _referenceMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// displayedMonth에 해당하는 PageView 페이지로 이동 (애니메이션 또는 즉시)
  void _syncPageToMonth(DateTime month) {
    final totalMonths = month.year * 12 + (month.month - 1);
    final refTotalMonths =
        _referenceMonth.year * 12 + (_referenceMonth.month - 1);
    final targetPage = _initialPage + (totalMonths - refTotalMonths);
    if (!_pageController.hasClients ||
        _pageController.page?.round() == targetPage) {
      return;
    }
    final kind = ref
        .read(homeCalendarControllerProvider.notifier)
        .consumeMonthlyTransition();
    if (kind == CalendarTransitionKind.animate) {
      _pageController.animateToPage(
        targetPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _pageController.jumpToPage(targetPage);
    }
  }

  /// 페이지 인덱스를 해당 월의 DateTime으로 변환
  DateTime _monthForPage(int page) {
    final totalMonths = _referenceMonth.year * 12 +
        (_referenceMonth.month - 1) +
        (page - _initialPage);
    final year = totalMonths ~/ 12;
    final month = totalMonths % 12 + 1;
    return DateTime(year, month, 1);
  }

  @override
  Widget build(BuildContext context) {
    final selectedStartDate = ref.watch(
      homeCalendarControllerProvider.select((s) => s.selectedStartDate),
    );

    // 외부(selectDate, goToToday 등)에서 displayedMonth가 변경될 때 PageView 동기화
    ref.listen(
      homeCalendarControllerProvider.select((s) => s.displayedMonth),
      (prev, next) {
        if (prev == next) return;
        _syncPageToMonth(next);
      },
    );

    // 월간 캘린더가 열릴 때 현재 displayedMonth로 페이지 동기화
    // (숨겨진 상태에서 jumpToPage가 실패할 경우를 대비)
    ref.listen(
      homeCalendarControllerProvider.select((s) => s.isMonthlyCalendarVisible),
      (prev, next) {
        if (next == true) {
          final displayedMonth = ref.read(
            homeCalendarControllerProvider.select((s) => s.displayedMonth),
          );
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _syncPageToMonth(displayedMonth);
          });
        }
      },
    );

    return ColoredBox(
      color: context.systemBackground,
      child: Column(
        children: [
          // 요일 헤더: 전체 높이에서 날짜 그리드 높이를 뺀 만큼 사용
          SizedBox(
            height: monthlyCalendarHeight - monthlyCalendarDayRowHeight * 5,
            child: const MonthlyCalendarHeader(),
          ),
          SizedBox(
            height: monthlyCalendarDayRowHeight * 5,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                final newMonth = _monthForPage(index);
                ref
                    .read(homeCalendarControllerProvider.notifier)
                    .setDisplayedMonth(newMonth);
              },
              itemBuilder: (context, index) {
                return MonthlyCalendarGrid(
                  displayedMonth: _monthForPage(index),
                  selectedStartDate: selectedStartDate,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
