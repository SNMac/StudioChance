# Phase 9: 캘린더 셀 탭 인터랙션 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 3일 캘린더 예약 셀 탭 인터랙션 구현 — z-순서 최상단 이동, 하이라이트, 상세 모달(하프 시트), N≥4 목록 모달, isContinuation 원본 날짜 네비게이션.

**Architecture:** `ReservationDisplayData`를 `ReservationSummary` 내장 구조로 재구성. `OverflowCell` 제거 후 N≥4도 스택 표시. `TimeGrid` → `ConsumerStatefulWidget` 전환으로 로컬 탭 상태 관리. `PendingHighlightId` provider로 cross-widget 하이라이트, `ScrollToTimeTrigger` provider로 isContinuation 수직 스크롤 조정.

**Tech Stack:** Flutter, Riverpod (riverpod_generator), Freezed, Platform-adaptive modals (iOS: showCupertinoSheet+SheetDetent, Android: DraggableScrollableSheet)

---

### Task 1: home_calendar_controller.dart — 새 Provider + 메서드 추가

**Files:**
- Modify: `lib/presentation/providers/home_calendar_controller.dart`

- [ ] **Step 1: `ScrollToTimeTrigger` 클래스를 `ScrollToCurrentTimeTrigger` 바로 아래에 추가**

```dart
/// isContinuation 셀 탭 시 지정 시간으로 수직 스크롤하는 트리거
@riverpod
class ScrollToTimeTrigger extends _$ScrollToTimeTrigger {
  @override
  DateTime? build() => null;

  void trigger(DateTime time) => state = time;
  void clear() => state = null;
}
```

- [ ] **Step 2: `PendingHighlightId` 클래스를 `ScrollToTimeTrigger` 바로 아래에 추가**

```dart
/// isContinuation 탭 시 원본 날짜 TimeGrid에 하이라이트를 전달하기 위한 Provider
@riverpod
class PendingHighlightId extends _$PendingHighlightId {
  @override
  String? build() => null;

  void set(String id) => state = id;
  void clear() => state = null;
}
```

- [ ] **Step 3: `HomeCalendarController`에 `selectDateFromContinuation()` 메서드 추가 (기존 `selectDateFromPicker` 아래)**

```dart
/// isContinuation 셀 탭 시 원본 날짜로 이동 (3일 캘린더 + 월간 캘린더 모두 animate)
void selectDateFromContinuation(DateTime date) {
  _threeDayTransition = CalendarTransitionKind.animate;
  _monthlyTransition = CalendarTransitionKind.animate;
  selectDate(date);
}
```

- [ ] **Step 4: build_runner 실행**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `home_calendar_controller.freezed.dart`, `home_calendar_controller.g.dart` 재생성 (새 provider 2개 추가)

- [ ] **Step 5: 커밋**

```bash
git add lib/presentation/providers/home_calendar_controller.dart \
        lib/presentation/providers/home_calendar_controller.g.dart \
        lib/presentation/providers/home_calendar_controller.freezed.dart
git commit -m "feat: #5 - ScrollToTimeTrigger, PendingHighlightId provider 및 selectDateFromContinuation 추가"
```

---

### Task 2: reservation_cell.dart — ReservationDisplayData 재구성

**Files:**
- Modify: `lib/presentation/home/widgets/three_day_calendar/reservation_cell.dart`

> 이 태스크 완료 후 `time_grid.dart`, `overflow_cell.dart`, `three_day_calendar.dart`가 일시적으로 깨짐 — Task 3에서 일괄 수정.

- [ ] **Step 1: 파일 전체를 아래 내용으로 교체**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:studio_chance/domain/entities/reservation_summary.dart';
import 'package:studio_chance/domain/enums/reservation_status.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

// ── 예약 셀 표시용 데이터 ─────────────────────────────────────────────────────

/// 예약 셀 렌더링에 필요한 최소 데이터.
/// [summary]는 도메인 ReservationSummary를 그대로 사용.
/// [isContinuation] / [continuesNextDay]는 셀 분할 로직에서만 추가됨.
class ReservationDisplayData {
  const ReservationDisplayData({
    required this.summary,
    this.isContinuation = false,
    this.continuesNextDay = false,
  });

  final ReservationSummary summary;

  /// true: 이전 날에서 이어지는 연속 셀 (텍스트·아이콘 미표시, 배경+스트립만)
  final bool isContinuation;

  /// true: 다음 날로 이어지는 셀 (하단 코너·여백 없음)
  final bool continuesNextDay;
}

// ── 예약 셀 위젯 ──────────────────────────────────────────────────────────────

class ReservationCell extends StatelessWidget {
  const ReservationCell({
    super.key,
    required this.data,
    this.clipContent = false,
    this.isHighlighted = false,
  });

  final ReservationDisplayData data;

  /// true: 스택 front/middle 셀 — 단일행, TextOverflow.clip
  /// false: 스택 back 셀 또는 단독 셀 — FittedBox scaleDown
  final bool clipContent;

  /// true: 배경 = foregroundColor, 스트립 = foregroundColor, 라벨 = white
  final bool isHighlighted;

  BorderRadius get _cellBorderRadius {
    const r = Radius.circular(4);
    return BorderRadius.only(
      topLeft: data.isContinuation ? Radius.zero : r,
      topRight: data.isContinuation ? Radius.zero : r,
      bottomLeft: data.continuesNextDay ? Radius.zero : r,
      bottomRight: data.continuesNextDay ? Radius.zero : r,
    );
  }

  @override
  Widget build(BuildContext context) {
    final storeColor = data.summary.storeSummary.color;
    final bgColor = isHighlighted
        ? Color(storeColor.foregroundColorValue)
        : Color(storeColor.backgroundColorValue);
    final fgColor = Color(storeColor.foregroundColorValue);
    final lblColor = isHighlighted ? Colors.white : Color(storeColor.labelColorValue);
    final borderRadius = _cellBorderRadius;

    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        children: [
          // 전체 배경
          Container(color: bgColor),

          // 좌측 4px 스트립
          // isHighlighted=true: fgColor == bgColor → 시각적으로 단일 색상
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: 4,
              child: ColoredBox(color: fgColor),
            ),
          ),

          // 외곽선 overlay
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: context.systemBackground,
                width: 0.5,
              ),
              borderRadius: borderRadius,
            ),
          ),

          // isContinuation=true: 배경+스트립만 (텍스트·아이콘 없음)
          if (!data.isContinuation)
            Positioned.fill(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 1.5,
                        right: clipContent ? 0 : 4,
                      ),
                      child: clipContent
                          ? _buildClipContent(context, lblColor)
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.topLeft,
                              child: _buildContentRow(context, lblColor),
                            ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildClipContent(BuildContext context, Color lblColor) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(color: lblColor);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 15.0,
          child: Center(
            child: _StatusIcon(status: data.summary.status, color: lblColor),
          ),
        ),
        const SizedBox(width: 2.5),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${data.summary.customerName} · ${data.summary.headCount}인',
                style: style,
                maxLines: 1,
                overflow: TextOverflow.clip,
              ),
              Text(
                data.summary.customerPhone,
                style: style,
                maxLines: 1,
                overflow: TextOverflow.clip,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContentRow(BuildContext context, Color lblColor) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(color: lblColor);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 15.0,
          child: Center(
            child: _StatusIcon(status: data.summary.status, color: lblColor),
          ),
        ),
        const SizedBox(width: 2.5),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${data.summary.customerName} · ${data.summary.headCount}인',
              style: style,
              maxLines: 1,
            ),
            Text(
              data.summary.customerPhone,
              style: style,
              maxLines: 1,
            ),
          ],
        ),
      ],
    );
  }
}

// ── 상태 아이콘 ───────────────────────────────────────────────────────────────

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status, required this.color});

  final ReservationStatus status;
  final Color color;

  static String _svgPath(ReservationStatus status) => switch (status) {
        ReservationStatus.confirmed =>
          'assets/images/icons/checkmark_circle_fill.svg',
        ReservationStatus.pending =>
          'assets/images/icons/circle_dashed.svg',
        ReservationStatus.canceled =>
          'assets/images/icons/circle_slash.svg',
      };

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _svgPath(status),
      width: 10,
      height: 10,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
```

- [ ] **Step 2: 커밋 (time_grid.dart / three_day_calendar.dart / overflow_cell.dart 일시적으로 깨짐 — 다음 태스크에서 일괄 수정)**

```bash
git add lib/presentation/home/widgets/three_day_calendar/reservation_cell.dart
git commit -m "feat: #5 - ReservationDisplayData ReservationSummary 내장 구조로 재구성, isHighlighted 추가"
```

---

### Task 3: OverflowCell 제거 + TimeGrid 기본 전환 + 목업 데이터 전환

**Files:**
- Delete: `lib/presentation/home/widgets/three_day_calendar/overflow_cell.dart`
- Modify: `lib/presentation/home/widgets/three_day_calendar/time_grid.dart`
- Modify: `lib/presentation/home/widgets/three_day_calendar/three_day_calendar.dart`

- [ ] **Step 1: `overflow_cell.dart` 삭제**

```bash
rm lib/presentation/home/widgets/three_day_calendar/overflow_cell.dart
```

- [ ] **Step 2: `time_grid.dart` 전체를 아래 내용으로 교체**

```dart
import 'dart:math' show max;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/current_time_indicator.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_cell.dart';
import 'package:studio_chance/presentation/providers/home_calendar_controller.dart';

/// N=2 겹침에서 시작 시간이 다를 때 (delta > 0) 적용하는 고정 stagger (px).
/// back 셀의 foreground strip(4px) + gap(4px) = 8px.
const double _differentStartStagger = 8.0;

/// 자정 넘김 셀의 바운스 연장 길이 (px).
const double _bounceExtension = 1000.0;

// ── 위치 계산 결과 ─────────────────────────────────────────────────────────────

class _PositionedItem {
  _PositionedItem({
    required this.event,
    required this.left,
    required this.right,
    required this.clipContent,
    this.groupEvents,
  });

  final ReservationDisplayData event;
  final double left;
  final double right;
  final bool clipContent;

  /// N≥4 그룹: non-null이면 탭 시 이벤트 목록 모달 표시
  final List<ReservationDisplayData>? groupEvents;
}

// ── 위치 계산 알고리즘 ─────────────────────────────────────────────────────────

/// 시간대 이벤트의 스택 위치를 계산.
///
/// [columnWidth]: 열 너비 (LayoutBuilder.constraints.maxWidth)
///
/// 알고리즘:
///   1. z 순서 정렬: 시작 빠른것 → 낮은 z (뒤), 같은 시작이면 짧은것 → 낮은 z (뒤)
///   2. 그리디 인터벌 컬러링 → 열 인덱스(col) 배정
///   3. Union-Find: 겹치는 이벤트들을 연결 컴포넌트로 묶음
///   4. 컴포넌트별 N = max(col) + 1
///   5a. N=2 전용 — 시작 시간 차이(delta)에 따른 stagger 결정:
///       - delta == 0 (동시 시작): cellWidth(= usableWidth/2) stagger
///       - delta > 0 (시작 시간 다름): [_differentStartStagger](8px 고정)
///   5b. 위치 계산: left = 1 + col × stagger, right = 8 고정
///       - N≥4 컴포넌트: groupEvents 채우기 (탭 시 목록 모달)
List<_PositionedItem> _computePositions(
    List<ReservationDisplayData> events, double columnWidth) {
  final usableWidth = columnWidth - 9.0; // 1(left) + 8(right)

  final timeEvents = events
      .where((e) => !e.summary.isAllDay)
      .toList();

  if (timeEvents.isEmpty) return [];

  // Step 1: z 순서 정렬
  timeEvents.sort((a, b) {
    final startCmp = a.summary.startTime.compareTo(b.summary.startTime);
    if (startCmp != 0) return startCmp;
    return a.summary.endTime
        .difference(a.summary.startTime)
        .compareTo(b.summary.endTime.difference(b.summary.startTime));
  });

  final n = timeEvents.length;

  // Step 2: 그리디 인터벌 컬러링 → 열 인덱스 배정
  final columnEndTimes = <DateTime>[];
  final colOf = <int>[];

  for (final event in timeEvents) {
    int col = -1;
    for (int c = 0; c < columnEndTimes.length; c++) {
      if (!columnEndTimes[c].isAfter(event.summary.startTime)) {
        col = c;
        columnEndTimes[c] = event.summary.endTime;
        break;
      }
    }
    if (col == -1) {
      col = columnEndTimes.length;
      columnEndTimes.add(event.summary.endTime);
    }
    colOf.add(col);
  }

  // Step 3: Union-Find — 겹치는 이벤트들을 같은 연결 컴포넌트로 묶음
  final parent = List<int>.generate(n, (i) => i);

  int findRoot(int x) {
    while (parent[x] != x) {
      parent[x] = parent[parent[x]];
      x = parent[x];
    }
    return x;
  }

  for (int i = 0; i < n; i++) {
    for (int j = i + 1; j < n; j++) {
      if (timeEvents[i].summary.startTime.isBefore(timeEvents[j].summary.endTime) &&
          timeEvents[j].summary.startTime.isBefore(timeEvents[i].summary.endTime)) {
        final pi = findRoot(i), pj = findRoot(j);
        if (pi != pj) parent[pi] = pj;
      }
    }
  }

  // Step 4: 컴포넌트별 최대 열 인덱스 → N
  final compMaxCol = <int, int>{};
  for (int i = 0; i < n; i++) {
    final root = findRoot(i);
    compMaxCol[root] = max(compMaxCol[root] ?? 0, colOf[i]);
  }

  // Step 5a: N=2 컴포넌트 전용 — 시작 시간 차이에 따른 stagger 결정
  final compStagger = <int, double>{};
  for (final root in compMaxCol.keys) {
    if (compMaxCol[root]! + 1 != 2) continue;

    final col0 = <int>[], col1 = <int>[];
    for (int k = 0; k < n; k++) {
      if (findRoot(k) != root) continue;
      (colOf[k] == 0 ? col0 : col1).add(k);
    }

    var minDeltaMin = double.infinity;
    for (final a in col0) {
      for (final b in col1) {
        if (timeEvents[a].summary.startTime.isBefore(timeEvents[b].summary.endTime) &&
            timeEvents[b].summary.startTime.isBefore(timeEvents[a].summary.endTime)) {
          final delta = timeEvents[b]
              .summary.startTime
              .difference(timeEvents[a].summary.startTime)
              .inMinutes
              .abs()
              .toDouble();
          if (delta < minDeltaMin) minDeltaMin = delta;
        }
      }
    }

    compStagger[root] =
        minDeltaMin == 0 ? usableWidth / 2 : _differentStartStagger;
  }

  // Step 5b: 위치 계산
  final result = <_PositionedItem>[];

  for (int i = 0; i < n; i++) {
    final root = findRoot(i);
    final numCols = (compMaxCol[root] ?? 0) + 1;
    final cellWidth = usableWidth / numCols;
    final col = colOf[i];
    final stagger = numCols == 2 ? (compStagger[root] ?? cellWidth) : cellWidth;

    // N≥4: groupEvents 채우기 (탭 시 목록 모달 표시)
    List<ReservationDisplayData>? groupEvents;
    if (numCols >= 4) {
      groupEvents = <ReservationDisplayData>[];
      for (int k = 0; k < n; k++) {
        if (findRoot(k) == root) groupEvents.add(timeEvents[k]);
      }
    }

    result.add(_PositionedItem(
      event: timeEvents[i],
      left: 1.0 + col * stagger,
      right: 8.0,
      clipContent: col > 0,
      groupEvents: groupEvents,
    ));
  }

  return result;
}

// ── TimeGrid 위젯 ──────────────────────────────────────────────────────────────

/// 3일 캘린더 날짜별 이벤트 그리드
class TimeGrid extends ConsumerStatefulWidget {
  const TimeGrid({
    super.key,
    required this.scrollController,
    required this.isToday,
    required this.events,
    required this.reservations,
  });

  final ScrollController scrollController;

  /// 해당 날짜가 오늘인지 여부
  final bool isToday;

  final List<ReservationDisplayData> events;

  /// 탭 시 상세 모달에 전달할 전체 Reservation 맵 (id → Reservation)
  final Map<String, Reservation> reservations;

  @override
  ConsumerState<TimeGrid> createState() => _TimeGridState();
}

class _TimeGridState extends ConsumerState<TimeGrid> {
  /// z-순서 최상단으로 올릴 셀 id
  String? _selectedId;

  /// 하이라이트 중인 셀 id (로컬)
  String? _highlightedId;

  ({double top, double height}) _placementFor(
      ReservationDisplayData event, double hourHeight) {
    final topGap = event.isContinuation ? 0.0 : 0.5;
    final bottomGap = event.continuesNextDay ? 0.0 : 1.5;
    final start = event.summary.startTime;
    final end = event.summary.endTime;
    var top = hourHeight * (start.hour + start.minute / 60) + topGap;
    var height =
        (hourHeight * end.difference(start).inMinutes / 60 - topGap - bottomGap)
            .clamp(1.0, double.infinity);

    if (event.isContinuation) {
      top -= _bounceExtension;
      height += _bounceExtension;
    }
    if (event.continuesNextDay) {
      height += _bounceExtension;
    }

    return (top: top, height: height);
  }

  @override
  Widget build(BuildContext context) {
    final hourHeight = ref.watch(
      homeCalendarControllerProvider.select((s) => s.hourHeight),
    );
    final externalHighlight = ref.watch(pendingHighlightIdProvider);
    final effectiveHighlightId = _highlightedId ?? externalHighlight;
    final totalHeight = hourHeight * 24;

    return SingleChildScrollView(
      controller: widget.scrollController,
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
        height: totalHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final positioned =
                _computePositions(widget.events, constraints.maxWidth);

            // z-순서: _selectedId 셀을 목록 맨 마지막(=맨 앞 z-순서)으로
            final orderedPositioned = _selectedId == null
                ? positioned
                : () {
                    final idx = positioned.indexWhere(
                        (p) => p.event.summary.id == _selectedId);
                    if (idx < 0) return positioned;
                    final result = List<_PositionedItem>.from(positioned);
                    result.add(result.removeAt(idx));
                    return result;
                  }();

            return Stack(
              clipBehavior: Clip.none,
              children: [
                const SizedBox.expand(),

                // 수평 시간 구분선 (1~23시)
                for (int hour = 1; hour < 24; hour++)
                  Positioned(
                    top: hourHeight * hour,
                    left: 0,
                    right: 0,
                    child: Divider(
                      height: 0,
                      thickness: calendarDividerThickness,
                      color: context.separator,
                    ),
                  ),

                // 이벤트 셀 (z 순서 — 먼저 = 뒤에, 나중 = 앞에)
                for (final item in orderedPositioned)
                  Builder(builder: (context) {
                    final p = _placementFor(item.event, hourHeight);
                    return Positioned(
                      top: p.top,
                      left: item.left,
                      right: item.right,
                      height: p.height,
                      child: ReservationCell(
                        data: item.event,
                        clipContent: item.clipContent,
                        isHighlighted:
                            effectiveHighlightId == item.event.summary.id,
                      ),
                    );
                  }),

                // 현재 시간선
                CurrentTimeLine(hourHeight: hourHeight, isToday: widget.isToday),
              ],
            );
          },
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: `three_day_calendar.dart`의 import 블록을 아래로 교체 (기존 import 아래에 추가)**

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/entities/reservation_summary.dart';
import 'package:studio_chance/domain/entities/store_member_info.dart';
import 'package:studio_chance/domain/entities/store_summary.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/enums/reservation_status.dart';
import 'package:studio_chance/domain/enums/store_color.dart';
import 'package:studio_chance/domain/enums/user_role.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/all_day_row.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/current_time_indicator.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_cell.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/time_grid.dart';
import 'package:studio_chance/presentation/providers/home_calendar_controller.dart';
```

- [ ] **Step 4: `_ThreeDayCalendarState`의 목업 데이터 블록 (`static final _mockEvents` 부터 `_eventsForDate` 메서드 끝까지)을 아래로 교체**

```dart
  // ── 목업 데이터 ────────────────────────────────────────────────────────────
  // TODO: Riverpod provider에서 실제 예약 데이터 수신으로 교체 예정.

  static final _mockData = _buildMockData();
  static List<ReservationDisplayData> get _mockEvents => _mockData.$1;
  static Map<String, Reservation> get _mockReservations => _mockData.$2;

  static StoreSummary _store(StoreColor color) =>
      StoreSummary(id: 's_${color.name}', name: '점포', color: color);

  static final _mockWriter = StoreMemberInfo(
    user: User(
      id: 'u1',
      name: '관리자',
      email: 'admin@test.com',
      nickname: '관리자',
      authProviders: [],
      storeInfos: [],
    ),
    role: UserRole.admin,
  );

  static (List<ReservationDisplayData>, Map<String, Reservation>) _buildMockData() {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final tomorrow = today.add(const Duration(days: 1));
    final dayAfter = today.add(const Duration(days: 2));

    // ── 기본 ReservationSummary 목록 (id → summary) ────────────────────────
    final summaries = <String, ReservationSummary>{
      // 오늘: 종일 단독
      'e01': ReservationSummary(
        id: 'e01', storeSummary: _store(StoreColor.green),
        status: ReservationStatus.confirmed,
        customerName: '유훈자', headCount: 2, customerPhone: '010-3109-6381',
        isAllDay: true,
        startTime: today, endTime: today.add(const Duration(days: 1)),
      ),
      // 오늘: 07:00~08:30 단독
      'e02': ReservationSummary(
        id: 'e02', storeSummary: _store(StoreColor.green),
        status: ReservationStatus.confirmed,
        customerName: '유훈자', headCount: 2, customerPhone: '010-3109-6381',
        isAllDay: false,
        startTime: today.add(const Duration(hours: 7)),
        endTime: today.add(const Duration(hours: 8, minutes: 30)),
      ),
      // 오늘: 10:00~ 4개 동시 겹침 (N=4, groupEvents로 처리)
      'e03': ReservationSummary(
        id: 'e03', storeSummary: _store(StoreColor.red),
        status: ReservationStatus.confirmed,
        customerName: '박지원', headCount: 1, customerPhone: '010-1111-2222',
        isAllDay: false,
        startTime: today.add(const Duration(hours: 10)),
        endTime: today.add(const Duration(hours: 11)),
      ),
      'e04': ReservationSummary(
        id: 'e04', storeSummary: _store(StoreColor.blue),
        status: ReservationStatus.confirmed,
        customerName: '최수아', headCount: 2, customerPhone: '010-3333-4444',
        isAllDay: false,
        startTime: today.add(const Duration(hours: 10)),
        endTime: today.add(const Duration(hours: 12)),
      ),
      'e05': ReservationSummary(
        id: 'e05', storeSummary: _store(StoreColor.green),
        status: ReservationStatus.canceled,
        customerName: '김민준', headCount: 4, customerPhone: '010-5555-1234',
        isAllDay: false,
        startTime: today.add(const Duration(hours: 10)),
        endTime: today.add(const Duration(hours: 13)),
      ),
      'e06': ReservationSummary(
        id: 'e06', storeSummary: _store(StoreColor.yellow),
        status: ReservationStatus.pending,
        customerName: '이서준', headCount: 3, customerPhone: '010-7777-9999',
        isAllDay: false,
        startTime: today.add(const Duration(hours: 10)),
        endTime: today.add(const Duration(hours: 14)),
      ),
      // 오늘: 16:00~17:00 단독
      'e07': ReservationSummary(
        id: 'e07', storeSummary: _store(StoreColor.purple),
        status: ReservationStatus.canceled,
        customerName: '정하은', headCount: 1, customerPhone: '010-8888-4444',
        isAllDay: false,
        startTime: today.add(const Duration(hours: 16)),
        endTime: today.add(const Duration(hours: 17)),
      ),
      // 오늘 22:00 ~ 내일 02:00 (자정 넘김)
      'e08': ReservationSummary(
        id: 'e08', storeSummary: _store(StoreColor.indigo),
        status: ReservationStatus.confirmed,
        customerName: '이도윤', headCount: 3, customerPhone: '010-5050-7070',
        isAllDay: false,
        startTime: today.add(const Duration(hours: 22)),
        endTime: tomorrow.add(const Duration(hours: 2)),
      ),
      // 내일: N=2, delta=0 (동시 시작)
      'e09': ReservationSummary(
        id: 'e09', storeSummary: _store(StoreColor.orange),
        status: ReservationStatus.confirmed,
        customerName: '나현우', headCount: 2, customerPhone: '010-2222-1111',
        isAllDay: false,
        startTime: tomorrow.add(const Duration(hours: 9)),
        endTime: tomorrow.add(const Duration(hours: 11)),
      ),
      'e10': ReservationSummary(
        id: 'e10', storeSummary: _store(StoreColor.indigo),
        status: ReservationStatus.pending,
        customerName: '임지수', headCount: 5, customerPhone: '010-4444-3333',
        isAllDay: false,
        startTime: tomorrow.add(const Duration(hours: 9)),
        endTime: tomorrow.add(const Duration(hours: 13)),
      ),
      // 내일: N=3, delta=0
      'e11': ReservationSummary(
        id: 'e11', storeSummary: _store(StoreColor.green),
        status: ReservationStatus.confirmed,
        customerName: '강민서', headCount: 3, customerPhone: '010-6666-5555',
        isAllDay: false,
        startTime: tomorrow.add(const Duration(hours: 13)),
        endTime: tomorrow.add(const Duration(hours: 15)),
      ),
      'e12': ReservationSummary(
        id: 'e12', storeSummary: _store(StoreColor.yellow),
        status: ReservationStatus.pending,
        customerName: '오세진', headCount: 2, customerPhone: '010-8888-7777',
        isAllDay: false,
        startTime: tomorrow.add(const Duration(hours: 13)),
        endTime: tomorrow.add(const Duration(hours: 16)),
      ),
      'e13': ReservationSummary(
        id: 'e13', storeSummary: _store(StoreColor.purple),
        status: ReservationStatus.canceled,
        customerName: '윤채원', headCount: 1, customerPhone: '010-0000-9999',
        isAllDay: false,
        startTime: tomorrow.add(const Duration(hours: 13)),
        endTime: tomorrow.add(const Duration(hours: 17)),
      ),
      // 내일: N=2, delta=20분
      'e14': ReservationSummary(
        id: 'e14', storeSummary: _store(StoreColor.red),
        status: ReservationStatus.confirmed,
        customerName: '한소희', headCount: 2, customerPhone: '010-1357-2468',
        isAllDay: false,
        startTime: tomorrow.add(const Duration(hours: 17)),
        endTime: tomorrow.add(const Duration(hours: 19, minutes: 30)),
      ),
      'e15': ReservationSummary(
        id: 'e15', storeSummary: _store(StoreColor.blue),
        status: ReservationStatus.pending,
        customerName: '도경수', headCount: 3, customerPhone: '010-2468-1357',
        isAllDay: false,
        startTime: tomorrow.add(const Duration(hours: 17, minutes: 20)),
        endTime: tomorrow.add(const Duration(hours: 19)),
      ),
      // 내일: N=2, delta=30분
      'e16': ReservationSummary(
        id: 'e16', storeSummary: _store(StoreColor.orange),
        status: ReservationStatus.confirmed,
        customerName: '박보검', headCount: 4, customerPhone: '010-9999-1111',
        isAllDay: false,
        startTime: tomorrow.add(const Duration(hours: 20, minutes: 30)),
        endTime: tomorrow.add(const Duration(hours: 23)),
      ),
      'e17': ReservationSummary(
        id: 'e17', storeSummary: _store(StoreColor.indigo),
        status: ReservationStatus.canceled,
        customerName: '김태리', headCount: 1, customerPhone: '010-1111-9999',
        isAllDay: false,
        startTime: tomorrow.add(const Duration(hours: 21)),
        endTime: tomorrow.add(const Duration(hours: 22, minutes: 30)),
      ),
      // 모레: 종일 단독
      'e18': ReservationSummary(
        id: 'e18', storeSummary: _store(StoreColor.orange),
        status: ReservationStatus.pending,
        customerName: '최수아', headCount: 5, customerPhone: '010-2222-3333',
        isAllDay: true,
        startTime: dayAfter, endTime: dayAfter.add(const Duration(days: 1)),
      ),
      // 모레: 시간대 단독들
      'e19': ReservationSummary(
        id: 'e19', storeSummary: _store(StoreColor.indigo),
        status: ReservationStatus.confirmed,
        customerName: '한지민', headCount: 3, customerPhone: '010-1234-5678',
        isAllDay: false,
        startTime: dayAfter.add(const Duration(hours: 10)),
        endTime: dayAfter.add(const Duration(hours: 12)),
      ),
      'e20': ReservationSummary(
        id: 'e20', storeSummary: _store(StoreColor.blue),
        status: ReservationStatus.confirmed,
        customerName: '서동현', headCount: 1, customerPhone: '010-9876-5432',
        isAllDay: false,
        startTime: dayAfter.add(const Duration(hours: 15)),
        endTime: dayAfter.add(const Duration(hours: 16)),
      ),
      'e21': ReservationSummary(
        id: 'e21', storeSummary: _store(StoreColor.red),
        status: ReservationStatus.canceled,
        customerName: '권나연', headCount: 4, customerPhone: '010-5678-1234',
        isAllDay: false,
        startTime: dayAfter.add(const Duration(hours: 17)),
        endTime: dayAfter.add(const Duration(hours: 19)),
      ),
      // 모레: N=2, delta=60분
      'e22': ReservationSummary(
        id: 'e22', storeSummary: _store(StoreColor.orange),
        status: ReservationStatus.confirmed,
        customerName: '송민호', headCount: 6, customerPhone: '010-1111-3333',
        isAllDay: false,
        startTime: dayAfter.add(const Duration(hours: 20)),
        endTime: dayAfter.add(const Duration(hours: 24)),
      ),
      'e23': ReservationSummary(
        id: 'e23', storeSummary: _store(StoreColor.blue),
        status: ReservationStatus.pending,
        customerName: '백지현', headCount: 2, customerPhone: '010-2222-4444',
        isAllDay: false,
        startTime: dayAfter.add(const Duration(hours: 21)),
        endTime: dayAfter.add(const Duration(hours: 23)),
      ),
    };

    // ── ReservationDisplayData 목록 ────────────────────────────────────────
    final events = summaries.values
        .map((s) => ReservationDisplayData(summary: s))
        .toList();

    // ── Reservation 맵 (탭 시 상세 모달에 전달) ──────────────────────────────
    final reservations = summaries.map(
      (id, s) => MapEntry(
        id,
        Reservation(
          id: id,
          storeSummary: s.storeSummary,
          writer: _mockWriter,
          status: s.status,
          customerName: s.customerName,
          headCount: s.headCount,
          customerPhone: s.customerPhone,
          memo: '',
          isAllDay: s.isAllDay,
          startTime: s.startTime,
          endTime: s.endTime,
          platform: '',
          paymentMethod: '',
          calculatedPrice: 0,
          priceAdjustment: 0,
          totalPrice: 0,
        ),
      ),
    );

    return (events, reservations);
  }

  /// 특정 날짜의 이벤트 목록 반환.
  /// 자정을 넘기는 시간대 이벤트는 두 날짜에 각각 분할:
  ///   - 시작일: endTime을 자정으로 제한 (summary.copyWith), continuesNextDay=true
  ///   - 익일: startTime=자정 (summary.copyWith), isContinuation=true
  static List<ReservationDisplayData> _eventsForDate(
      DateTime date, {required bool allDay}) {
    final dateStart = DateTime(date.year, date.month, date.day);
    final dateMidnight = dateStart.add(const Duration(days: 1));
    final result = <ReservationDisplayData>[];

    for (final e in _mockEvents) {
      if (e.summary.isAllDay != allDay) continue;

      if (allDay) {
        final s = e.summary.startTime;
        if (s.year == date.year && s.month == date.month && s.day == date.day) {
          result.add(e);
        }
        continue;
      }

      final start = e.summary.startTime;
      final end = e.summary.endTime;

      // 이 날짜에 시작하는 이벤트
      if (start.year == date.year &&
          start.month == date.month &&
          start.day == date.day) {
        if (end.isAfter(dateMidnight)) {
          result.add(ReservationDisplayData(
            summary: e.summary.copyWith(endTime: dateMidnight),
            continuesNextDay: true,
          ));
        } else {
          result.add(e);
        }
        continue;
      }

      // 이전 날에 시작해서 이 날짜까지 이어지는 이벤트 → 연속 셀
      if (start.isBefore(dateStart) && end.isAfter(dateStart)) {
        result.add(ReservationDisplayData(
          summary: e.summary.copyWith(startTime: dateStart),
          isContinuation: true,
        ));
      }
    }

    return result;
  }
```

- [ ] **Step 5: `TimeGrid` 호출부에 `reservations` 파라미터 추가 (three_day_calendar.dart 내 `itemBuilder`)**

기존:
```dart
Expanded(
  child: TimeGrid(
    scrollController: _controllerForPage(index),
    isToday: _isToday(date),
    events: _eventsForDate(date, allDay: false),
  ),
),
```

변경 후:
```dart
Expanded(
  child: TimeGrid(
    scrollController: _controllerForPage(index),
    isToday: _isToday(date),
    events: _eventsForDate(date, allDay: false),
    reservations: _mockReservations,
  ),
),
```

- [ ] **Step 6: `flutter run`으로 앱 실행, 시각적 파리티 확인 (탭 이전과 동일하게 보여야 함)**

기대 결과:
- 오늘 10:00 4개 겹침 → OverflowCell 없이 4개 스택으로 표시 (폭 좁아짐)
- 자정 넘김 셀 연속 표시 정상
- 종일 셀 정상

- [ ] **Step 7: 커밋**

```bash
git add lib/presentation/home/widgets/three_day_calendar/time_grid.dart \
        lib/presentation/home/widgets/three_day_calendar/three_day_calendar.dart
git rm lib/presentation/home/widgets/three_day_calendar/overflow_cell.dart
git commit -m "feat: #5 - OverflowCell 제거, TimeGrid ConsumerStatefulWidget 전환, 목업 데이터 ReservationSummary 구조로 전환"
```

---

### Task 4: reservation_detail_modal.dart + reservation_list_modal.dart — 신규

**Files:**
- Create: `lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart`
- Create: `lib/presentation/home/widgets/three_day_calendar/reservation_list_modal.dart`

- [ ] **Step 1: `reservation_detail_modal.dart` 생성**

```dart
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:studio_chance/domain/entities/reservation.dart';

/// 예약 상세 모달 (플레이스홀더 — 실제 디자인은 별도 Phase에서 구현)
///
/// 하프 시트로 시작, 위로 드래그하면 전체 화면을 덮음.
/// 뒤에 캘린더 셀이 보이므로 isHighlighted=true 상태가 유지됨.
class ReservationDetailModal extends StatelessWidget {
  const ReservationDetailModal({
    super.key,
    required this.reservation,
    this.scrollController,
  });

  final Reservation reservation;

  /// Android DraggableScrollableSheet에서 전달받는 ScrollController
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 드래그 핸들 (pill)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 플레이스홀더 내용
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              reservation.customerName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// 예약 상세 모달 표시 (플랫폼 적응형).
///
/// iOS: [showCupertinoSheet] + SheetDetent.medium/large (드래그로 full-screen 확장)
/// Android: [showModalBottomSheet] + [DraggableScrollableSheet] (초기 50%)
Future<void> showReservationDetailModal(
    BuildContext context, Reservation reservation) {
  if (Platform.isIOS) {
    return showCupertinoSheet<void>(
      context: context,
      detents: const [SheetDetent.medium, SheetDetent.large],
      builder: (_) => ReservationDetailModal(reservation: reservation),
    );
  }
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.5,
      maxChildSize: 1.0,
      expand: false,
      builder: (_, controller) => ReservationDetailModal(
        reservation: reservation,
        scrollController: controller,
      ),
    ),
  );
}
```

- [ ] **Step 2: `reservation_list_modal.dart` 생성**

```dart
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/domain/entities/reservation_summary.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_cell.dart';

/// N≥4 그룹 이벤트 목록 모달.
///
/// 선택된 [ReservationSummary]를 반환 (취소 시 null).
class ReservationListModal extends StatelessWidget {
  const ReservationListModal({super.key, required this.events});

  final List<ReservationDisplayData> events;

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: GroupedFormContainer(
            children: [
              for (final event in events)
                SizedBox(
                  height: inputFormComponentHeight,
                  child: CupertinoButton(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    onPressed: () => Navigator.pop(context, event.summary),
                    child: Row(
                      children: [
                        // 색상 도트
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(event.summary.storeSummary.color
                                .foregroundColorValue),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 고객명
                        Expanded(
                          child: Text(
                            event.summary.customerName,
                            style: Theme.of(context).textTheme.bodyLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // 시간 범위
                        Text(
                          '${timeFormat.format(event.summary.startTime)}~'
                          '${timeFormat.format(event.summary.endTime)}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.normal,
                                color: context.secondaryLabel,
                              ),
                        ),
                        const SizedBox(width: 12),
                        // chevron
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 10),
                          child: Icon(
                            CupertinoIcons.chevron_forward,
                            color: context.tertiaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 이벤트 목록 모달 표시 (플랫폼 적응형).
///
/// 선택된 [ReservationSummary]를 반환 (취소 시 null).
Future<ReservationSummary?> showReservationListModal(
    BuildContext context, List<ReservationDisplayData> events) {
  if (Platform.isIOS) {
    return showCupertinoSheet<ReservationSummary>(
      context: context,
      builder: (_) => ReservationListModal(events: events),
    );
  }
  return showModalBottomSheet<ReservationSummary>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => ReservationListModal(events: events),
  );
}
```

> **Note:** `intl` 패키지(`DateFormat`)가 `pubspec.yaml`에 없다면 `flutter pub add intl` 실행 후 import 추가.

- [ ] **Step 3: 커밋**

```bash
git add lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart \
        lib/presentation/home/widgets/three_day_calendar/reservation_list_modal.dart
git commit -m "feat: #5 - ReservationDetailModal(하프 시트 플레이스홀더), ReservationListModal 신규 추가"
```

---

### Task 5: time_grid.dart — 탭 인터랙션 구현

**Files:**
- Modify: `lib/presentation/home/widgets/three_day_calendar/time_grid.dart`

- [ ] **Step 1: import에 모달 파일 2개 추가 (`time_grid.dart` 상단 import 블록)**

```dart
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_list_modal.dart';
```

- [ ] **Step 2: `_TimeGridState`에 `_onCellTap` 메서드 추가 (`_placementFor` 메서드 바로 아래)**

```dart
  Future<void> _onCellTap(BuildContext context, _PositionedItem item) async {
    if (item.groupEvents != null) {
      // ② N≥4 그룹 셀 탭 — 목록 모달 → 선택 → 상세 모달
      final selected =
          await showReservationListModal(context, item.groupEvents!);
      if (selected == null || !mounted) return;
      setState(() {
        _highlightedId = selected.id;
        _selectedId = selected.id;
      });
      final reservation = widget.reservations[selected.id];
      if (reservation == null || !mounted) return;
      await showReservationDetailModal(context, reservation);
      if (!mounted) return;
      setState(() {
        _highlightedId = null;
        _selectedId = null;
      });
    } else if (item.event.isContinuation) {
      // ③ isContinuation 셀 탭 — 원본 날짜로 이동 + cross-widget 하이라이트 + 상세 모달
      final reservation = widget.reservations[item.event.summary.id];
      if (reservation == null) return;
      final originalStartTime = reservation.startTime;
      final originalDate = DateTime(
        originalStartTime.year,
        originalStartTime.month,
        originalStartTime.day,
      );
      ref.read(pendingHighlightIdProvider.notifier).set(item.event.summary.id);
      ref
          .read(homeCalendarControllerProvider.notifier)
          .selectDateFromContinuation(originalDate);
      ref.read(scrollToTimeTriggerProvider.notifier).trigger(originalStartTime);
      await showReservationDetailModal(context, reservation);
      if (!mounted) return;
      ref.read(pendingHighlightIdProvider.notifier).clear();
    } else {
      // ① 일반 셀 탭
      setState(() {
        _highlightedId = item.event.summary.id;
        _selectedId = item.event.summary.id;
      });
      final reservation = widget.reservations[item.event.summary.id];
      if (reservation == null || !mounted) return;
      await showReservationDetailModal(context, reservation);
      if (!mounted) return;
      setState(() {
        _highlightedId = null;
        _selectedId = null;
      });
    }
  }
```

- [ ] **Step 3: `build()`의 이벤트 셀 렌더링 부분에 `GestureDetector` 추가**

기존 (`for (final item in orderedPositioned)` 블록 내부):
```dart
for (final item in orderedPositioned)
  Builder(builder: (context) {
    final p = _placementFor(item.event, hourHeight);
    return Positioned(
      top: p.top,
      left: item.left,
      right: item.right,
      height: p.height,
      child: ReservationCell(
        data: item.event,
        clipContent: item.clipContent,
        isHighlighted:
            effectiveHighlightId == item.event.summary.id,
      ),
    );
  }),
```

변경 후:
```dart
for (final item in orderedPositioned)
  Builder(builder: (context) {
    final p = _placementFor(item.event, hourHeight);
    return Positioned(
      top: p.top,
      left: item.left,
      right: item.right,
      height: p.height,
      child: GestureDetector(
        onTap: () => _onCellTap(context, item),
        child: ReservationCell(
          data: item.event,
          clipContent: item.clipContent,
          isHighlighted:
              effectiveHighlightId == item.event.summary.id,
        ),
      ),
    );
  }),
```

- [ ] **Step 4: `flutter run`으로 탭 인터랙션 검증**

체크리스트:
- 일반 셀 탭 → 셀 하이라이트(foreground 색) + z-순서 최상단 + 하프 시트 모달(고객명 표시)
- 모달 닫기 → 하이라이트 해제
- 오늘 10:00 4개 겹침 셀 중 하나 탭 → 목록 모달 → 선택 → 상세 모달
- isContinuation 셀 탭 → 원본 날짜로 페이지 이동 (Task 6 이후 스크롤 검증)
- 하프 시트 위로 드래그 → 전체 화면 덮음 (iOS 기준)

- [ ] **Step 5: 커밋**

```bash
git add lib/presentation/home/widgets/three_day_calendar/time_grid.dart
git commit -m "feat: #5 - TimeGrid 탭 인터랙션 구현 (일반 셀, N≥4 그룹, isContinuation 세 가지 흐름)"
```

---

### Task 6: three_day_calendar.dart — scrollToTimeTrigger 처리 추가

**Files:**
- Modify: `lib/presentation/home/widgets/three_day_calendar/three_day_calendar.dart`

- [ ] **Step 1: `_ThreeDayCalendarState`에 `_scrollToTime` 헬퍼 추가 (`_scrollToCurrentTime` 바로 아래)**

```dart
  /// 지정 시간이 뷰포트 중앙에 오도록 스크롤 (isContinuation 탭 후 호출)
  void _scrollToTime(DateTime time) {
    final hourHeight = ref.read(homeCalendarControllerProvider).hourHeight;
    final offset = hourHeight * (time.hour + time.minute / 60);

    double viewportHeight = 600; // fallback
    for (final ctrl in _dayScrollControllers.values) {
      if (ctrl.hasClients) {
        viewportHeight = ctrl.position.viewportDimension;
        break;
      }
    }
    if (_timeColumnScrollController.hasClients) {
      viewportHeight = _timeColumnScrollController.position.viewportDimension;
    }

    final maxExtent =
        (hourHeight * 24 - viewportHeight).clamp(0.0, double.infinity);
    final target =
        (offset - viewportHeight / 2).clamp(0.0, maxExtent);
    _currentVerticalOffset = target;
    _syncAllScrollControllers(target);
  }
```

- [ ] **Step 2: `animateToPage.then()` 콜백에 scrollToTimeTrigger 처리 추가**

기존 `.then((_) { ... })` 블록 내부에서 `_scrollToCurrentTimePending` 처리 아래에 추가:

```dart
.then((_) {
  if (mounted) {
    _isPageAnimating = false;
    ref
        .read(homeCalendarControllerProvider.notifier)
        .selectDateFromSwipe(_dateForPage(targetPage));
    if (_scrollToCurrentTimePending) {
      _scrollToCurrentTimePending = false;
      _scrollToCurrentTime();
    }
    // isContinuation 탭 → 해당 시간으로 수직 스크롤
    final scrollToTime = ref.read(scrollToTimeTriggerProvider);
    if (scrollToTime != null) {
      _scrollToTime(scrollToTime);
      ref.read(scrollToTimeTriggerProvider.notifier).clear();
    }
  }
});
```

- [ ] **Step 3: `flutter run`으로 isContinuation 탭 전체 흐름 검증**

체크리스트:
- isContinuation 셀(이도윤, 내일 00:00~02:00) 탭 →
  - 오늘 날짜(e08 원본)로 페이지 animate 이동
  - 22:00 시간대로 수직 스크롤
  - 원본 셀 하이라이트(pendingHighlightIdProvider)
  - 상세 모달 표시 (고객명: 이도윤)
  - 모달 닫기 → 하이라이트 해제

- [ ] **Step 4: 커밋**

```bash
git add lib/presentation/home/widgets/three_day_calendar/three_day_calendar.dart
git commit -m "feat: #5 - isContinuation 탭 시 원본 시간대 수직 스크롤 처리 추가"
```

---

## 수정 대상 파일 요약

| 파일 | 태스크 | 변경 유형 |
|------|--------|---------|
| `home_calendar_controller.dart` | Task 1 | ScrollToTimeTrigger, PendingHighlightId 추가, selectDateFromContinuation 메서드 추가 |
| `reservation_cell.dart` | Task 2 | ReservationDisplayData 재구성, isHighlighted 추가, 색상/상태 매핑 도메인 enum으로 전환 |
| `overflow_cell.dart` | Task 3 | **삭제** |
| `time_grid.dart` | Task 3, 5 | ConsumerStatefulWidget 전환, _PositionedItem 재구성, groupEvents N≥4, 탭 핸들러 |
| `three_day_calendar.dart` | Task 3, 6 | 목업 데이터 전환, _eventsForDate 업데이트, scrollToTimeTrigger 처리 |
| `reservation_detail_modal.dart` | Task 4 | **신규** (플레이스홀더 하프 시트) |
| `reservation_list_modal.dart` | Task 4 | **신규** (GroupedFormContainer 목록) |

## 스코프 아웃 (추후)

- `ReservationDetailModal` 실제 디자인 구현
- 실제 Firestore 데이터 연결 (mock 제거)
