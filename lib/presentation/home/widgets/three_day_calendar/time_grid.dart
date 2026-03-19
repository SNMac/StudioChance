import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/current_time_indicator.dart';
import 'package:studio_chance/presentation/providers/home_calendar_controller.dart';

/// 3일 캘린더 시간 그리드 위젯
/// 시간 레이블, 구분선, 현재 시간 인디케이터를 포함하며
/// 수직 스크롤과 핀치 줌을 지원함
class TimeGrid extends ConsumerStatefulWidget {
  const TimeGrid({super.key});

  @override
  ConsumerState<TimeGrid> createState() => _TimeGridState();
}

class _TimeGridState extends ConsumerState<TimeGrid> {
  late final ScrollController _scrollController;

  /// 핀치 줌 시작 시점의 기준 hourHeight
  double _baseHourHeight = defaultHourHeight;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // 레이아웃 완료 후 현재 시간으로 초기 스크롤
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentTime());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 현재 시간이 뷰포트 중앙에 오도록 스크롤
  void _scrollToCurrentTime() {
    if (!_scrollController.hasClients) return;
    final hourHeight = ref.read(homeCalendarControllerProvider).hourHeight;
    final now = DateTime.now();
    final currentOffset = hourHeight * (now.hour + now.minute / 60);
    // context.size 대신 scrollController의 viewportDimension 사용 (정확한 뷰포트 높이)
    final viewportHeight = _scrollController.position.viewportDimension;
    final target =
        (currentOffset - viewportHeight / 2).clamp(0.0, double.infinity);
    _scrollController.jumpTo(target);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeCalendarControllerProvider);
    final hourHeight = state.hourHeight;
    final totalHeight = hourHeight * 24;

    return GestureDetector(
      onScaleStart: (details) {
        _baseHourHeight =
            ref.read(homeCalendarControllerProvider).hourHeight;
      },
      onScaleUpdate: (details) {
        // 핀치 줌만 처리 (두 손가락 이상)
        if (details.pointerCount < 2) return;

        final newHeight =
            (_baseHourHeight * details.scale).clamp(minHourHeight, maxHourHeight);

        // 스크롤 위치를 비율로 유지 (_baseHourHeight 기준으로 계산해 누적 오차 방지)
        final ratio = _scrollController.hasClients
            ? _scrollController.offset / (_baseHourHeight * 24)
            : 0.0;

        // updateHourHeight는 Future<void>이지만 SharedPreferences 저장만 비동기,
        // 상태 업데이트는 동기적으로 수행됨
        unawaited(
          ref.read(homeCalendarControllerProvider.notifier).updateHourHeight(newHeight),
        );

        if (_scrollController.hasClients) {
          // 상한은 실제 스크롤 가능 범위(totalHeight - viewportDimension)로 계산
          final viewportDimension = _scrollController.position.viewportDimension;
          final maxOffset = (newHeight * 24 - viewportDimension).clamp(0.0, double.infinity);
          final newOffset = (ratio * (newHeight * 24)).clamp(0.0, maxOffset);
          _scrollController.jumpTo(newOffset);
        }
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        child: SizedBox(
          height: totalHeight,
          child: Stack(
            children: [
              // 시간 레이블 + 3열 빈 이벤트 영역 (배경 레이어)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: timeColumnWidth),
                  // 3열 빈 이벤트 영역
                  const Expanded(
                    child: Row(
                      children: [
                        Expanded(child: SizedBox()),
                        Expanded(child: SizedBox()),
                        Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                ],
              ),

              // 시간 구분선 및 레이블 (0~24시)
              for (int hour = 0; hour <= 24; hour++)
                Positioned(
                  top: hourHeight * hour,
                  left: 0,
                  right: 0,
                  child: Row(
                    children: [
                      SizedBox(
                        width: timeColumnWidth,
                        // 0시, 24시는 레이블 표시 안 함 (1~23시만 표시)
                        child: hour > 0 && hour < 24
                            ? Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 4),
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
                              )
                            : null,
                      ),
                      Expanded(
                        child: Divider(
                          height: 0,
                          thickness: calendarDividerThickness,
                          color: context.separator,
                        ),
                      ),
                    ],
                  ),
                ),

              // 현재 시간 인디케이터
              Positioned(
                top: CurrentTimeIndicator.topPosition(hourHeight),
                left: 0,
                right: 0,
                child: CurrentTimeIndicator(hourHeight: hourHeight),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
