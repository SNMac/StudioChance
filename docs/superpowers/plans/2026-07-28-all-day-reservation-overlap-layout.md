# 종일 예약 다중 겹침 레이아웃 처리 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 같은 날짜에 종일 예약이 2건 이상 겹칠 때, 현재의 단순 `Stack`(이벤트가 가려짐) 대신 대표 1건 + "+N" 초과 배지를 표시하고, 탭 시 목록 모달로 전체 이벤트를 확인할 수 있게 한다 ([#21](https://github.com/SNMac/StudioChance/issues/21)).

**Architecture:** `AllDayCell`은 `allDayRowHeight`(40px) 고정 높이의 단일 셀이라, `TimeGrid`가 사용하는 Union-Find + 그리디 인터벌 컬러링(시간축 좌우 stagger) 알고리즘은 적용 대상이 아니다 — `eventsForDate(date, allDay: true)`로 이미 특정 날짜로 필터링된 종일 이벤트는 전부 그 날짜를 공유하므로 항상 서로 겹치고, 시간축 자체가 없어 컬럼을 나눌 공간도 없다. 대신 TimeGrid에서 재사용 가능한 두 가지만 가져온다: (1) z-order 정렬 규칙(시작 시각 우선, 같으면 기간 짧은 것 우선)을 `calendar_events_utils.dart`의 공개 함수 `sortAllDayEventsForDisplay`로 추출해 테스트 가능하게 만들고, (2) TimeGrid의 N≥4 그룹 탭 처리(`showReservationListModal` 재사용)와 동일한 흐름을 `AllDayCell`의 N≥2 케이스에 적용한다. 정렬된 이벤트가 1건이면 기존과 동일하게 `ReservationCell` 전체를 표시하고, 2건 이상이면 대표 1건(정렬 결과의 첫 번째) + `_OverflowBadge`("+N-1")를 표시하며, 탭하면 `showReservationListModal` → 선택 → `onOpenDetailModal`로 이어지는, `TimeGrid._onCellTap`의 `groupEvents` 분기와 동일한 흐름을 사용한다.

**Tech Stack:** Flutter, 기존 `reservation_list_modal.dart`(`showReservationListModal`) 재사용. 새 패키지 의존성 없음.

## Global Constraints

- 커밋 메시지: 한국어, `<type>: #21 - <설명>` 형식
- `dart analyze` 클린 유지 (freezed 필드 변경 없으므로 `build_runner` 재실행 불필요)
- 이 프로젝트는 위젯 테스트(`testWidgets`)를 작성하지 않는 컨벤션을 따른다 (TimeGrid의 동등한 레이아웃 함수 `_computePositions`도 자동 테스트 없이 수동 시각 검증만 거쳤음). 따라서 순수 함수(`sortAllDayEventsForDisplay`)만 유닛 테스트하고, 위젯 렌더링/탭 동작은 이슈 체크리스트와 동일하게 `flutter run --target lib/main_dev.dart` 수동 검증으로 확인한다
- `all_day_row.dart`, `calendar_events_utils.dart`는 Presentation 레이어 — domain/data import 금지 규칙 준수 (기존과 동일, 이번 변경도 위반하지 않음)
- 겹침 처리 방식은 사용자와 확인 완료: N=1은 기존 유지, N≥2는 전부 동일하게 "대표 1건 + `+N-1` 배지" 처리 (세로 분할 방식은 40px 고정 높이에 2줄 텍스트가 들어갈 공간이 부족해 배제)

---

### Task 1: 종일 이벤트 정렬 규칙 `sortAllDayEventsForDisplay` 추가

**Files:**
- Modify: `lib/presentation/home/utils/calendar_events_utils.dart`
- Test: `test/presentation/home/utils/calendar_events_utils_test.dart`

**Interfaces:**
- Consumes: `ReservationDisplayData`(기존, `reservation_cell.dart`), 테스트 파일 상단에 이미 정의된 `_makeEvent({required id, required start, required end, bool isAllDay})` 헬퍼(기존, 재정의하지 않음)
- Produces: `List<ReservationDisplayData> sortAllDayEventsForDisplay(List<ReservationDisplayData> events)` — Task 2에서 `AllDayCell`이 이 함수로 대표 이벤트를 정렬한다.

- [x] **Step 1: 실패하는 테스트 작성**

`test/presentation/home/utils/calendar_events_utils_test.dart`의 `buildEventsFromReservations` 그룹 다음, `main()` 함수를 닫는 마지막 `}` 바로 앞에 새 그룹을 추가한다:

```dart
  // ===========================================================================
  // sortAllDayEventsForDisplay
  // ===========================================================================

  group('sortAllDayEventsForDisplay', () {
    test('시작 시각이 빠른 이벤트가 먼저 온다', () {
      final later = _makeEvent(
        id: 'later',
        start: today.add(const Duration(hours: 2)),
        end: today.add(const Duration(hours: 3)),
        isAllDay: true,
      );
      final earlier = _makeEvent(
        id: 'earlier',
        start: today,
        end: today.add(const Duration(hours: 1)),
        isAllDay: true,
      );

      final result = sortAllDayEventsForDisplay([later, earlier]);

      expect(result.map((e) => e.summary.id).toList(), ['earlier', 'later']);
    });

    test('시작 시각이 같으면 기간이 짧은 이벤트가 먼저 온다', () {
      final long = _makeEvent(
        id: 'long',
        start: today,
        end: today.add(const Duration(days: 2)),
        isAllDay: true,
      );
      final short = _makeEvent(
        id: 'short',
        start: today,
        end: today.add(const Duration(days: 1)),
        isAllDay: true,
      );

      final result = sortAllDayEventsForDisplay([long, short]);

      expect(result.map((e) => e.summary.id).toList(), ['short', 'long']);
    });

    test('원본 리스트를 변경하지 않는다', () {
      final a = _makeEvent(
        id: 'a',
        start: today.add(const Duration(hours: 5)),
        end: today.add(const Duration(hours: 6)),
        isAllDay: true,
      );
      final b = _makeEvent(
        id: 'b',
        start: today,
        end: today.add(const Duration(hours: 1)),
        isAllDay: true,
      );
      final original = [a, b];

      sortAllDayEventsForDisplay(original);

      expect(original.map((e) => e.summary.id).toList(), ['a', 'b']);
    });

    test('빈 목록 입력 시 빈 목록을 반환한다', () {
      final result = sortAllDayEventsForDisplay([]);
      expect(result, isEmpty);
    });
  });
```

- [x] **Step 2: 테스트 실행 후 실패 확인**

Run: `flutter test test/presentation/home/utils/calendar_events_utils_test.dart`
Expected: FAIL — `sortAllDayEventsForDisplay` 함수가 정의되어 있지 않음(컴파일 에러)

- [x] **Step 3: 최소 구현 작성**

`lib/presentation/home/utils/calendar_events_utils.dart` 파일 맨 끝(`eventsForDate` 함수 다음)에 추가:

```dart

/// 종일 이벤트를 배지 대표 이벤트 선정을 위해 정렬한다.
///
/// TimeGrid `_computePositions`의 z-order 규칙과 동일: 시작 시각이 빠른 것 우선,
/// 같으면 기간이 짧은 것 우선. 원본 리스트는 변경하지 않는다.
List<ReservationDisplayData> sortAllDayEventsForDisplay(
    List<ReservationDisplayData> events) {
  final sorted = [...events];
  sorted.sort((a, b) {
    final startCmp = a.summary.startTime.compareTo(b.summary.startTime);
    if (startCmp != 0) return startCmp;
    return a.summary.endTime
        .difference(a.summary.startTime)
        .compareTo(b.summary.endTime.difference(b.summary.startTime));
  });
  return sorted;
}
```

- [x] **Step 4: 테스트 실행 후 통과 확인**

Run: `flutter test test/presentation/home/utils/calendar_events_utils_test.dart`
Expected: PASS (기존 테스트 포함 전체 통과)

- [x] **Step 5: 커밋**

```bash
git add lib/presentation/home/utils/calendar_events_utils.dart test/presentation/home/utils/calendar_events_utils_test.dart
git commit -m "$(cat <<'EOF'
feat: #21 - 종일 예약 정렬 규칙(sortAllDayEventsForDisplay) 추가

EOF
)"
```

---

### Task 2: `AllDayCell` 대표 이벤트 + 초과 배지 렌더링 및 목록 모달 연동

**Files:**
- Modify: `lib/constants/ui_constants.dart`
- Modify: `lib/presentation/home/widgets/three_day_calendar/all_day_row.dart`

**Interfaces:**
- Consumes: `sortAllDayEventsForDisplay`(Task 1), `showReservationListModal(BuildContext, List<ReservationDisplayData>) → Future<ReservationSummary?>`(기존, `reservation_list_modal.dart`), `ReservationCell({data, clipContent, isHighlighted})`(기존, `reservation_cell.dart`), `context.tertiarySystemFill` / `context.secondaryLabel`(기존, `context_colors.dart`)
- Produces: 없음 (UI 최종 소비 지점)

- [x] **Step 1: `ui_constants.dart`에 배지 높이 상수 추가**

`lib/constants/ui_constants.dart`의 `const double allDayRowHeight = 40.0;` 바로 다음 줄에 추가:

```dart
const double allDayOverflowBadgeHeight = 14.0;
```

- [x] **Step 2: `all_day_row.dart` 전체 교체**

`lib/presentation/home/widgets/three_day_calendar/all_day_row.dart` 전체를 다음으로 교체한다:

```dart
import 'package:flutter/material.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/home/utils/calendar_events_utils.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_cell.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_list_modal.dart';

/// 3일 캘린더 종일 이벤트 셀 (날짜 1열)
class AllDayCell extends StatefulWidget {
  const AllDayCell({
    super.key,
    required this.events,
    required this.reservations,
    required this.onOpenDetailModal,
    required this.isInteractionBlocked,
  });

  final List<ReservationDisplayData> events;

  /// 탭 시 상세 모달에 전달할 전체 Reservation 맵 (id → Reservation)
  final Map<String, Reservation> reservations;

  /// 예약 셀 탭 시 상세 모달을 여는 콜백 (공간 옵션 선 조회 + 모달 표시 포함).
  final Future<void> Function(Reservation) onOpenDetailModal;

  /// true이면 셀 터치를 완전히 차단한다 (로딩 중 중복 탭 방지).
  final bool isInteractionBlocked;

  @override
  State<AllDayCell> createState() => _AllDayCellState();
}

class _AllDayCellState extends State<AllDayCell> {
  String? _highlightedId;

  Future<void> _onCellTap(ReservationDisplayData event) async {
    final reservation = widget.reservations[event.summary.id];
    if (reservation == null) return;
    setState(() => _highlightedId = event.summary.id);
    if (!mounted) return;
    await widget.onOpenDetailModal(reservation);
    if (!mounted) return;
    setState(() => _highlightedId = null);
  }

  /// N≥2 겹침 셀 탭 — 목록 모달 → 선택 → 상세 모달.
  /// TimeGrid._onCellTap의 groupEvents 분기(N≥4 그룹 처리)와 동일한 흐름.
  Future<void> _onGroupTap(List<ReservationDisplayData> events) async {
    final selected = await showReservationListModal(context, events);
    if (selected == null || !mounted) return;
    setState(() => _highlightedId = selected.id);
    final reservation = widget.reservations[selected.id];
    if (reservation == null) {
      setState(() => _highlightedId = null);
      return;
    }
    if (!mounted) return;
    await widget.onOpenDetailModal(reservation);
    if (!mounted) return;
    setState(() => _highlightedId = null);
  }

  @override
  Widget build(BuildContext context) {
    final sortedEvents = sortAllDayEventsForDisplay(widget.events);
    final hasOverflow = sortedEvents.length >= 2;

    return AbsorbPointer(
      absorbing: widget.isInteractionBlocked,
      child: SizedBox(
        height: allDayRowHeight,
        child: sortedEvents.isEmpty
            ? const SizedBox.shrink()
            : Stack(
                children: [
                  Positioned(
                    left: 1,
                    right: 8,
                    top: 1,
                    bottom: 4,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => hasOverflow
                          ? _onGroupTap(sortedEvents)
                          : _onCellTap(sortedEvents.first),
                      child: Stack(
                        children: [
                          ReservationCell(
                            data: sortedEvents.first,
                            clipContent: hasOverflow,
                            isHighlighted: _highlightedId ==
                                sortedEvents.first.summary.id,
                          ),
                          if (hasOverflow)
                            Positioned(
                              top: 2,
                              right: 4,
                              child: _OverflowBadge(
                                count: sortedEvents.length - 1,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// 종일 셀 겹침 초과 배지 ("+N"). N = 화면에 표시되지 않은 나머지 이벤트 수.
class _OverflowBadge extends StatelessWidget {
  const _OverflowBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: allDayOverflowBadgeHeight,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: context.tertiarySystemFill,
        borderRadius: BorderRadius.circular(allDayOverflowBadgeHeight / 2),
      ),
      alignment: Alignment.center,
      child: Text(
        '+$count',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: context.secondaryLabel,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
```

- [x] **Step 3: 정적 분석 확인**

Run: `dart analyze lib/presentation/home/widgets/three_day_calendar/all_day_row.dart lib/constants/ui_constants.dart`
Expected: 에러 없음

- [ ] **Step 4: 앱 실행 후 수동 검증**

Run: `flutter run --target lib/main_dev.dart`
홈 화면(3일 캘린더) → 같은 날짜에 종일 예약을 1건/2건/4건 등록 후 다음을 확인한다 (이슈 #21 체크리스트와 동일):
- 1건: 기존과 동일하게 `ReservationCell` 전체가 표시된다 (배지 없음)
- 2건 이상: 대표 1건(가장 빠른 시작 시각)만 표시되고 우측 상단에 "+N-1" 배지가 보인다
- 대표 셀 또는 배지 아무 곳이나 탭 → 예약 목록 모달이 열리고, 목록에서 항목 선택 → 상세 모달로 정상 연결된다
- 로딩 중(`isInteractionBlocked=true`)에는 셀 탭이 차단된다 (기존 `AbsorbPointer` 동작 유지 확인)

**미완료:** SDD 실행 환경(subagent 샌드박스)에 iOS/Android 시뮬레이터가 없어 이 단계는 수행하지 못했다. `dart analyze` 클린 확인과 브리프 코드 대 diff 1:1 대조로 구조적 정합성만 검증됨. 병합 전 사람이 직접 `flutter run --target lib/main_dev.dart`로 위 4가지 항목을 확인해야 한다.

- [x] **Step 5: 커밋**

```bash
git add lib/constants/ui_constants.dart lib/presentation/home/widgets/three_day_calendar/all_day_row.dart
git commit -m "$(cat <<'EOF'
feat: #21 - 종일 예약 겹침 시 대표 이벤트 + 초과 배지 표시 및 목록 모달 연동

EOF
)"
```
