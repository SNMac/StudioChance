import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/home/widgets/home_nav_bar.dart';
import 'package:studio_chance/presentation/home/widgets/home_tab_bar.dart';
import 'package:studio_chance/presentation/home/widgets/monthly_calendar/monthly_calendar.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/three_day_calendar.dart';
import 'package:studio_chance/presentation/providers/home_calendar_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMonthlyCalendarVisible = ref.watch(
      homeCalendarControllerProvider.select((s) => s.isMonthlyCalendarVisible),
    );

    return Scaffold(
      backgroundColor: context.systemBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HomeNavBar(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: isMonthlyCalendarVisible ? monthlyCalendarHeight : 0,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(),
              child: OverflowBox(
                maxHeight: monthlyCalendarHeight,
                alignment: Alignment.topCenter,
                child: const MonthlyCalendar(),
              ),
            ),
            const Expanded(
              child: ThreeDayCalendar(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const HomeTabBar(),
    );
  }
}
