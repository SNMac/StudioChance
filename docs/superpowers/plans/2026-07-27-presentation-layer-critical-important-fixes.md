# Presentation Layer Critical/Important 이슈 수정 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** GitHub 이슈 [#16](https://github.com/SNMac/StudioChance/issues/16)에서 지적된 Presentation Layer의 Critical 2건, Important 6건, Minor 2건(총 10건)을 각각 독립적으로 검증 가능한 최소 단위로 수정한다.

**Architecture:** 기존 Clean Architecture(Data/Domain/Presentation) 구조를 그대로 유지한다. `presentation/home/widgets`, `presentation/providers`, `presentation/onboarding`, `presentation/commons`의 기존 파일만 손댄다. 새 계층이나 추상화는 추가하지 않는다. [C-1]은 CLAUDE.md에 이미 문서화된 "두 detent 시트" 패턴(`reservation_detail_modal.dart`에 기 구현됨)을 그대로 재사용한다.

**Tech Stack:** Flutter/Dart, `flutter_riverpod`+`riverpod_generator`(`@riverpod`), `fpdart`(`Either`), `mocktail`(컨트롤러 단위 테스트), `logger`.

## Global Constraints

- `DraggableScrollableSheet` 사용 금지 — `showModalBottomSheet(isScrollControlled: true, enableDrag: false)` + `LayoutBuilder` + `AnimationController(lowerBound: initialSize, upperBound: 1.0)` 패턴만 허용 (CLAUDE.md "모달 시트 패턴")
- 명령형 Either 스타일(`isLeft()`/`isRight()` + `getLeft().toNullable()!`) 프로덕션 코드 금지, `result.fold((error) => ..., (value) => ...)` 함수형 패턴만 사용
- 콘솔 출력은 `logger` 패키지만 사용
- `ref.watch(provider)` → use case/provider 의존성은 `ref.watch`로 조회 (반응성 유지, CLAUDE.md "성능 규칙")
- `build()` 내 반복 호출되는 `DateTime.now()`는 루프/빌드 진입 시 1회만 `final` 변수로 계산
- 커밋 메시지: `<type>: #16 - <한국어 설명>` 형식, 태스크 단위로 커밋
- 브랜치: `refactor/#16-presentation-layer` (이미 checkout됨 — 새로 생성하지 않는다)
- 정식 출시 전(프로덕션 데이터 없음)이므로 Firestore 스키마/문서 변경에 대한 마이그레이션은 고려하지 않는다
- Freezed/riverpod provider 시그니처를 바꾸는 태스크는 없으므로 `build_runner` 재실행 불필요

---

## File Structure

| 파일 | 역할 |
|---|---|
| `lib/presentation/home/widgets/store_filter_modal.dart` | [C-1] `DraggableScrollableSheet` → 두 detent 시트 패턴으로 교체 |
| `lib/presentation/home/widgets/three_day_calendar/reservation_list_modal.dart` | [C-1] `DraggableScrollableSheet` → 두 detent 시트 패턴으로 교체 |
| `lib/presentation/onboarding/controllers/onboarding_nickname_controller.dart` | [C-2] `isLeft()/getLeft().toNullable()!` → `fold` 함수형 스타일 |
| `lib/presentation/providers/app_auth_controller.dart` | [I-1] catch 블록 로깅 추가 |
| `lib/presentation/providers/store_detail_provider.dart` | [I-2] `ref.read` → `ref.watch` |
| `lib/presentation/providers/home_reservation_actions_controller.dart` | [I-3] `StackTrace.current`를 `await` 직후로 호이스트 (3곳) |
| `lib/presentation/providers/reservation_ocr_controller.dart` | [I-3] 동일 (1곳) |
| `lib/presentation/commons/store_input/controllers/store_creation_controller.dart` | [I-3] 동일 (1곳) |
| `lib/presentation/commons/store_input/controllers/store_update_controller.dart` | [I-3] 동일 (1곳) |
| `lib/presentation/home/widgets/three_day_calendar/three_day_calendar.dart` | [I-4] `_DayHeaderCell`에 `isToday` 파라미터 전달 |
| `lib/presentation/home/widgets/monthly_calendar/monthly_calendar.dart` | [I-5] `DateTime.now()` 단일 변수화 |
| `lib/presentation/providers/home_reservations_provider.dart` | [I-6] `ref.read` → `ref.watch` |
| `lib/presentation/commons/extensions/time_formatter.dart` | [M-1] `DateTime` extension 신규 추가 |
| `lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart` | [M-1] 중복 `_formatDateTime` 제거, extension 사용 |
| `lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart` | [M-1] 동일 |
| `lib/presentation/home/screens/home_screen.dart` | [M-2] 더미 `User` → 실제 로그인 유저 정보 사용 |
| `test/presentation/onboarding/controllers/onboarding_nickname_controller_test.dart` | [C-2] 신규 컨트롤러 테스트 |

각 태스크는 파일 하나 또는 강하게 결합된 파일 소수만 건드리며, 태스크 단위로 커밋한다.

---

## Task 1: [C-1] `store_filter_modal.dart` — `DraggableScrollableSheet` 제거

**Files:**
- Modify: `lib/presentation/home/widgets/store_filter_modal.dart`

**Interfaces:**
- Consumes: `ModalGrabber`(`lib/presentation/commons/widgets/modal_grabber.dart`), `ModalAppBar`(`lib/presentation/commons/widgets/app_bar/modal_app_bar.dart`), `modalTopCornerRadius`(`lib/constants/ui_constants.dart`), `modalBarrierColor`(`lib/presentation/colors.dart`)
- Produces: `showStoreFilterModal(BuildContext)` — 시그니처 불변, 내부 구현만 교체

이 위젯은 참조 구현인 `reservation_detail_modal.dart`(단일 모드)와 달리 편집 모드 전환이 없는 단일 화면이므로, Listener 기반 드래그/스냅 로직만 재사용하고 `_isEditing` 분기·Stack+Offstage 이중 스크롤은 가져오지 않는다.

- [x] **Step 1: `StoreFilterModal`을 `ConsumerStatefulWidget`으로 전환하고 드래그 시트 구조 적용**

`lib/presentation/home/widgets/store_filter_modal.dart` 전체를 다음으로 교체한다:

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/colors.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/extensions/store_color_extensions.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/app_bar_action_button.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/modal_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/modal_grabber.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/presentation/providers/home_store_filter_controller.dart';

const double _kModalInitialSize = 0.5;
const double _kModalMaxSize = 1.0;

/// 점포 필터 모달.
///
/// 각 항목: (색상 도트) (점포명) (역할) — checkmark로 선택 상태 표시.
/// 탭 시 [HomeStoreFilterController]를 통해 선택/해제 토글.
///
/// 두 detent 시트: [showModalBottomSheet]가 `maxAvailableHeight`를 전달하고,
/// 이 위젯이 [AnimationController]로 높이를 직접 제어한다 (CLAUDE.md "모달 시트 패턴").
class StoreFilterModal extends ConsumerStatefulWidget {
  const StoreFilterModal({super.key, required this.maxAvailableHeight});

  final double maxAvailableHeight;

  @override
  ConsumerState<StoreFilterModal> createState() => _StoreFilterModalState();
}

class _StoreFilterModalState extends ConsumerState<StoreFilterModal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sheetController;
  double _grabberDragStartSize = _kModalInitialSize;
  double _grabberDragStartY = 0;

  @override
  void initState() {
    super.initState();
    _sheetController = AnimationController(
      vsync: this,
      value: _kModalInitialSize,
      lowerBound: _kModalInitialSize,
      upperBound: _kModalMaxSize,
    );
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  void _dismissModal() {
    Navigator.pop(context);
  }

  void _animateTo(double target) {
    _sheetController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _snapToNearest() {
    const mid = (_kModalInitialSize + _kModalMaxSize) / 2;
    _animateTo(_sheetController.value >= mid ? _kModalMaxSize : _kModalInitialSize);
  }

  @override
  Widget build(BuildContext context) {
    final storeInfos = ref.watch(
      currentUserProvider.select((u) => u.asData?.value?.storeInfos ?? []),
    );
    final selectedIds = ref.watch(homeStoreFilterControllerProvider);
    final notifier = ref.read(homeStoreFilterControllerProvider.notifier);
    final isAllSelected = selectedIds.length == storeInfos.length;

    return AnimatedBuilder(
      animation: _sheetController,
      builder: (ctx, child) => SizedBox(
        height: widget.maxAvailableHeight * _sheetController.value,
        child: child,
      ),
      child: Material(
        color: context.systemGroupedBackground,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(modalTopCornerRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 그라버·앱바 영역 드래그 → 시트 높이 직접 제어.
            // Listener(raw pointer)로 제스처 아레나 완전 우회.
            Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (event) {
                _grabberDragStartSize = _sheetController.value;
                _grabberDragStartY = event.position.dy;
              },
              onPointerMove: (event) {
                final delta = -event.delta.dy / widget.maxAvailableHeight;
                _sheetController.value = (_sheetController.value + delta)
                    .clamp(_kModalInitialSize, _kModalMaxSize);
              },
              onPointerUp: (event) {
                final totalDy = event.position.dy - _grabberDragStartY;
                if (totalDy.abs() < 10) return;
                if (totalDy > 30) {
                  if (_grabberDragStartSize <= _kModalInitialSize + 0.05) {
                    _dismissModal();
                  } else {
                    _animateTo(_kModalInitialSize);
                  }
                } else if (totalDy < -30) {
                  _animateTo(_kModalMaxSize);
                } else {
                  _snapToNearest();
                }
              },
              onPointerCancel: (_) => _snapToNearest(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ModalGrabber(),
                  ModalAppBar(
                    title: '점포 선택',
                    actions: [
                      AppBarActionButton(
                        label: isAllSelected ? '전체 해제' : '전체 선택',
                        onPressed: notifier.toggleAll,
                        isRegularWeight: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: SafeAreaWithPadding(
                  top: false,
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    horizontalPadding,
                    16,
                    horizontalPadding,
                    8,
                  ),
                  child: GroupedFormContainer(
                    children: [
                      for (final info in storeInfos)
                        SizedBox(
                          height: inputFormComponentHeight,
                          child: CupertinoButton(
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: horizontalPadding,
                            ),
                            onPressed: () => notifier.toggle(info.id),
                            child: Row(
                              children: [
                                // 색상 도트
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(info.color.foregroundColorValue),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // 점포명
                                Expanded(
                                  child: Text(
                                    info.name,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // 역할명
                                Text(
                                  info.role.displayName,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.normal,
                                        color: context.secondaryLabel,
                                      ),
                                ),
                                const SizedBox(width: 12),
                                // 선택 checkmark — 항상 20px 폭을 점유하여 역할명 위치 고정
                                SizedBox(
                                  width: 20,
                                  child: selectedIds.contains(info.id)
                                      ? Icon(
                                          CupertinoIcons.checkmark_alt,
                                          size: 20,
                                          color: context.systemBlue,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 점포 필터 모달 표시.
Future<void> showStoreFilterModal(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    barrierColor: modalBarrierColor,
    builder: (ctx) => LayoutBuilder(
      builder: (_, constraints) =>
          StoreFilterModal(maxAvailableHeight: constraints.maxHeight),
    ),
  );
}
```

- [x] **Step 2: 정적 분석 확인**

Run: `dart analyze lib/presentation/home/widgets/store_filter_modal.dart`
Expected: 에러 없음

- [x] **Step 3: 앱 실행 후 수동 검증**

Run: `flutter run --target lib/main_dev.dart`
홈 화면 → 필터 버튼 탭 → 점포 필터 모달 오픈. 다음을 확인한다:
- 그라버/앱바 영역을 아래로 짧게 드래그 → 0.5로 스냅 유지, 세게(30px 초과) 드래그 → dismiss
- 그라버/앱바 영역을 위로 드래그 → 1.0(전체 높이)로 확장
- 리스트 스크롤이 정상 동작 (드래그 핸들 영역 밖에서는 일반 스크롤)
- 점포 탭 시 선택/해제 checkmark 토글, "전체 선택"/"전체 해제" 버튼 정상 동작

- [x] **Step 4: 커밋**

```bash
git add lib/presentation/home/widgets/store_filter_modal.dart
git commit -m "$(cat <<'EOF'
fix: #16 - [C-1] StoreFilterModal의 DraggableScrollableSheet를 허용 패턴으로 교체

CLAUDE.md에서 명시적으로 금지된 DraggableScrollableSheet는 내부 gesture
tracking이 BottomSheet.onClosing → Navigator.pop을 독립 호출하여 커스텀
제스처 처리와 충돌한다. showModalBottomSheet(enableDrag: false) +
LayoutBuilder + AnimationController + Listener 기반 두 detent 시트
패턴(reservation_detail_modal.dart 기 구현)으로 교체.
EOF
)"
```

---

## Task 2: [C-1] `reservation_list_modal.dart` — `DraggableScrollableSheet` 제거

**Files:**
- Modify: `lib/presentation/home/widgets/three_day_calendar/reservation_list_modal.dart`

**Interfaces:**
- Consumes: Task 1과 동일한 공통 위젯/상수
- Produces: `showReservationListModal(BuildContext, List<ReservationDisplayData>) → Future<ReservationSummary?>` — 시그니처 불변

`ReservationListModal`은 `StatelessWidget`이었으나 `AnimationController`를 위해 `StatefulWidget`으로 전환한다. 항목 탭 시 `Navigator.pop(context, event.summary)`로 값을 반환하는 기존 동작은 유지한다.

- [x] **Step 1: `ReservationListModal`을 `StatefulWidget`으로 전환하고 드래그 시트 구조 적용**

`lib/presentation/home/widgets/three_day_calendar/reservation_list_modal.dart` 전체를 다음으로 교체한다:

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/domain/entities/reservation_summary.dart';
import 'package:studio_chance/presentation/colors.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/extensions/store_color_extensions.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/modal_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';
import 'package:studio_chance/presentation/commons/widgets/modal_grabber.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_cell.dart';

final _timeFormat = DateFormat('HH:mm');

const double _kModalInitialSize = 0.5;
const double _kModalMaxSize = 1.0;

/// N≥4 그룹 이벤트 목록 모달.
///
/// 선택된 [ReservationSummary]를 반환 (취소 시 null).
/// 배경/shape/barrierColor는 [showReservationListModal]의 showModalBottomSheet가 제공.
/// Grabber는 [ModalGrabber] 컴포넌트 사용.
///
/// 두 detent 시트: [showReservationListModal]이 `maxAvailableHeight`를 전달하고,
/// 이 위젯이 [AnimationController]로 높이를 직접 제어한다 (CLAUDE.md "모달 시트 패턴").
class ReservationListModal extends StatefulWidget {
  const ReservationListModal({
    super.key,
    required this.events,
    required this.maxAvailableHeight,
  });

  final List<ReservationDisplayData> events;
  final double maxAvailableHeight;

  @override
  State<ReservationListModal> createState() => _ReservationListModalState();
}

class _ReservationListModalState extends State<ReservationListModal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sheetController;
  double _grabberDragStartSize = _kModalInitialSize;
  double _grabberDragStartY = 0;

  @override
  void initState() {
    super.initState();
    _sheetController = AnimationController(
      vsync: this,
      value: _kModalInitialSize,
      lowerBound: _kModalInitialSize,
      upperBound: _kModalMaxSize,
    );
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  void _dismissModal() {
    Navigator.pop(context);
  }

  void _animateTo(double target) {
    _sheetController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _snapToNearest() {
    const mid = (_kModalInitialSize + _kModalMaxSize) / 2;
    _animateTo(_sheetController.value >= mid ? _kModalMaxSize : _kModalInitialSize);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sheetController,
      builder: (ctx, child) => SizedBox(
        height: widget.maxAvailableHeight * _sheetController.value,
        child: child,
      ),
      child: Material(
        color: context.systemGroupedBackground,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(modalTopCornerRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 그라버·앱바 영역 드래그 → 시트 높이 직접 제어.
            // Listener(raw pointer)로 제스처 아레나 완전 우회.
            Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (event) {
                _grabberDragStartSize = _sheetController.value;
                _grabberDragStartY = event.position.dy;
              },
              onPointerMove: (event) {
                final delta = -event.delta.dy / widget.maxAvailableHeight;
                _sheetController.value = (_sheetController.value + delta)
                    .clamp(_kModalInitialSize, _kModalMaxSize);
              },
              onPointerUp: (event) {
                final totalDy = event.position.dy - _grabberDragStartY;
                if (totalDy.abs() < 10) return;
                if (totalDy > 30) {
                  if (_grabberDragStartSize <= _kModalInitialSize + 0.05) {
                    _dismissModal();
                  } else {
                    _animateTo(_kModalInitialSize);
                  }
                } else if (totalDy < -30) {
                  _animateTo(_kModalMaxSize);
                } else {
                  _snapToNearest();
                }
              },
              onPointerCancel: (_) => _snapToNearest(),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ModalGrabber(),
                  ModalAppBar(title: '예약 목록'),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: SafeAreaWithPadding(
                  top: false,
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    horizontalPadding,
                    16,
                    horizontalPadding,
                    8,
                  ),
                  child: GroupedFormContainer(
                    children: [
                      for (final event in widget.events)
                        SizedBox(
                          height: inputFormComponentHeight,
                          child: CupertinoButton(
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: horizontalPadding,
                            ),
                            onPressed: () =>
                                Navigator.pop(context, event.summary),
                            child: Row(
                              children: [
                                // 색상 도트
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(
                                      event
                                          .summary
                                          .storeSummary
                                          .color
                                          .foregroundColorValue,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // 고객명 · 인원
                                Expanded(
                                  child: Text(
                                    '${event.summary.customerName} · ${event.summary.headCount}인',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // 시간 범위
                                Text(
                                  '${_timeFormat.format(event.summary.startTime)}~'
                                  '${_timeFormat.format(event.summary.endTime)}',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
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
            ),
          ],
        ),
      ),
    );
  }
}

/// 이벤트 목록 모달 표시.
///
/// iOS/Android 공통으로 [showModalBottomSheet] 사용.
/// - barrierColor: 20% 불투명 검정 (scrim)
/// - shape: 상단 코너 radius 10 ([ReservationListModal] 내부 Material에서 적용)
/// - Grabber: [ReservationListModal] 위젯 내부 렌더링 (iOS 스타일 커스텀)
/// - 두 detent(0.5 / 1.0): 그라버·앱바 영역 드래그로 전환, 초기 크기 아래로
///   더 당기면 dismiss
///
/// 선택된 [ReservationSummary]를 반환 (취소 시 null).
Future<ReservationSummary?> showReservationListModal(
  BuildContext context,
  List<ReservationDisplayData> events,
) {
  return showModalBottomSheet<ReservationSummary>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    barrierColor: modalBarrierColor,
    builder: (ctx) => LayoutBuilder(
      builder: (_, constraints) => ReservationListModal(
        events: events,
        maxAvailableHeight: constraints.maxHeight,
      ),
    ),
  );
}
```

- [x] **Step 2: 정적 분석 확인**

Run: `dart analyze lib/presentation/home/widgets/three_day_calendar/reservation_list_modal.dart`
Expected: 에러 없음

- [x] **Step 3: 앱 실행 후 수동 검증**

Run: `flutter run --target lib/main_dev.dart`
3일 캘린더에서 N≥4건 겹치는 이벤트 셀 탭 → 예약 목록 모달 오픈. 다음을 확인한다:
- Task 1과 동일한 드래그/스냅/dismiss 동작
- 목록 항목 탭 시 모달이 닫히고 선택된 예약의 상세 모달로 정상 전환

- [x] **Step 4: 커밋**

```bash
git add lib/presentation/home/widgets/three_day_calendar/reservation_list_modal.dart
git commit -m "$(cat <<'EOF'
fix: #16 - [C-1] ReservationListModal의 DraggableScrollableSheet를 허용 패턴으로 교체

Task 1(StoreFilterModal)과 동일한 사유로 DraggableScrollableSheet를
제거하고 두 detent 시트 패턴으로 교체.
EOF
)"
```

---

## Task 3: [C-2] `onboarding_nickname_controller.dart` — `fold` 함수형 스타일로 전환

**Files:**
- Modify: `lib/presentation/onboarding/controllers/onboarding_nickname_controller.dart`
- Test: `test/presentation/onboarding/controllers/onboarding_nickname_controller_test.dart` (신규)

**Interfaces:**
- Consumes: `UserUseCase.getCurrentUser()`, `UserUseCase.updateUser({required String uid, String? nickname})`(둘 다 기존, `lib/domain/use_cases/user_use_case.dart`)
- Produces: `OnboardingNicknameController.saveNicknameToRemote(String nickname)` — 반환 타입/외부 동작 불변, 내부 구현만 `fold`로 교체

- [x] **Step 1: 실패하는 테스트 작성**

`test/presentation/onboarding/controllers/onboarding_nickname_controller_test.dart` 신규 생성:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/common/exceptions/user_exceptions.dart';
import 'package:studio_chance/domain/use_cases/user_use_case.dart';
import 'package:studio_chance/domain/use_cases/user_use_case_provider.dart';
import 'package:studio_chance/presentation/onboarding/controllers/onboarding_nickname_controller.dart';

import '../../../../helpers/fake_entities.dart';

class MockUserUseCase extends Mock implements UserUseCase {}

void main() {
  late MockUserUseCase mockUserUseCase;
  late ProviderContainer container;

  setUp(() {
    mockUserUseCase = MockUserUseCase();
    container = ProviderContainer(
      overrides: [
        userUseCaseProvider.overrideWith((ref) => mockUserUseCase),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('saveNicknameToRemote', () {
    test('닉네임이 비어있으면 UserValidationException으로 AsyncError가 된다', () async {
      final notifier = container.read(
        onboardingNicknameControllerProvider.notifier,
      );

      await notifier.saveNicknameToRemote('   ');

      final state = container.read(onboardingNicknameControllerProvider);
      expect(state, isA<AsyncError>());
      expect(state.error, isA<UserValidationException>());
      verifyNever(() => mockUserUseCase.getCurrentUser());
    });

    test('getCurrentUser 실패 시 원본 예외로 AsyncError가 된다', () async {
      final exception = UserNotFoundException(message: '조회 실패');
      when(() => mockUserUseCase.getCurrentUser())
          .thenAnswer((_) async => left(exception));
      final notifier = container.read(
        onboardingNicknameControllerProvider.notifier,
      );

      await notifier.saveNicknameToRemote('닉네임');

      final state = container.read(onboardingNicknameControllerProvider);
      expect(state, isA<AsyncError>());
      expect(state.error, exception);
      verifyNever(
        () => mockUserUseCase.updateUser(
          uid: any(named: 'uid'),
          nickname: any(named: 'nickname'),
        ),
      );
    });

    test('currentUser가 null이면 UserNotFoundException으로 AsyncError가 된다', () async {
      when(() => mockUserUseCase.getCurrentUser())
          .thenAnswer((_) async => right(null));
      final notifier = container.read(
        onboardingNicknameControllerProvider.notifier,
      );

      await notifier.saveNicknameToRemote('닉네임');

      final state = container.read(onboardingNicknameControllerProvider);
      expect(state, isA<AsyncError>());
      expect(state.error, isA<UserNotFoundException>());
    });

    test('updateUser 실패 시 원본 예외로 AsyncError가 된다', () async {
      final exception = UserNotFoundException(message: '업데이트 실패');
      when(() => mockUserUseCase.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      when(
        () => mockUserUseCase.updateUser(
          uid: any(named: 'uid'),
          nickname: any(named: 'nickname'),
        ),
      ).thenAnswer((_) async => left(exception));
      final notifier = container.read(
        onboardingNicknameControllerProvider.notifier,
      );

      await notifier.saveNicknameToRemote('닉네임');

      final state = container.read(onboardingNicknameControllerProvider);
      expect(state, isA<AsyncError>());
      expect(state.error, exception);
    });

    test('성공 시 AsyncData(null)이 되고 updateUser가 올바른 인자로 호출된다', () async {
      when(() => mockUserUseCase.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      when(
        () => mockUserUseCase.updateUser(
          uid: any(named: 'uid'),
          nickname: any(named: 'nickname'),
        ),
      ).thenAnswer((_) async => right(null));
      final notifier = container.read(
        onboardingNicknameControllerProvider.notifier,
      );

      await notifier.saveNicknameToRemote('새닉네임');

      final state = container.read(onboardingNicknameControllerProvider);
      expect(state, const AsyncData<void>(null));
      verify(
        () => mockUserUseCase.updateUser(
          uid: fakeUser.id,
          nickname: '새닉네임',
        ),
      ).called(1);
    });
  });
}
```

- [x] **Step 2: 테스트 실행하여 실패 확인**

Run: `flutter test test/presentation/onboarding/controllers/onboarding_nickname_controller_test.dart`
Expected: FAIL — `import 'package:fpdart/fpdart.dart';`를 추가하지 않아 `left`/`right` 미정의 컴파일 에러가 나거나(추가 시), `UserNotFoundException`을 `Exception`으로 던지는 현재 구현에서도 대부분의 `expect(state.error, exception)` 동일성 비교는 통과할 수 있으나 최소 1개 이상(예: 빈 닉네임 케이스에서 `getCurrentUser` 호출 여부)이 현재 구현과 다를 수 있다. 실제로는 컴파일부터 확인한다: 테스트 파일에 `left`/`right`를 쓰려면 `package:fpdart/fpdart.dart` import가 필요하므로 아래처럼 상단에 추가한다.

```dart
import 'package:fpdart/fpdart.dart';
```

위 import를 테스트 파일 상단(`import 'package:flutter_riverpod/flutter_riverpod.dart';` 바로 아래)에 추가한 뒤 다시 실행한다.

Run: `flutter test test/presentation/onboarding/controllers/onboarding_nickname_controller_test.dart`
Expected: 현재 구현(`isLeft()` + `getLeft().toNullable()!`)에서도 이 테스트들은 로직상 통과할 가능성이 높다 — 이번 수정은 동작이 아니라 금지된 명령형 패턴 자체를 제거하는 것이 목적이므로, 이 테스트 스위트는 "리팩터 전후 동일 동작 보장"을 위한 회귀 테스트로 기능한다. PASS 하더라도 다음 Step으로 진행한다.

- [x] **Step 3: `onboarding_nickname_controller.dart` 수정**

`lib/presentation/onboarding/controllers/onboarding_nickname_controller.dart`의 `saveNicknameToRemote` 메서드(20-45행)를 다음으로 교체한다:

```dart
  /// 닉네임을 원격 DB에 저장
  Future<void> saveNicknameToRemote(String nickname) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      if (nickname.trim().isEmpty) {
        throw UserValidationException(message: '닉네임이 입력되지 않았습니다.');
      }

      final userUseCase = ref.read(userUseCaseProvider);
      final userResult = await userUseCase.getCurrentUser();

      final currentUser = userResult.fold(
        (error) => throw error,
        (user) => user,
      );

      if (currentUser == null) {
        throw UserNotFoundException(message: '로그인 정보를 찾을 수 없습니다.');
      }

      final updateResult = await userUseCase.updateUser(
        uid: currentUser.id,
        nickname: nickname,
      );

      updateResult.fold(
        (error) => throw error,
        (_) {},
      );
    });
  }
```

이 `(error) => throw error` 패턴은 같은 파일 그룹의 `app_auth_controller.dart:25`에 이미 존재하는 프로젝트 관례와 동일하다 — `isLeft()`/`getLeft().toNullable()!` 없이 `fold`만으로 성공값을 꺼내거나 실패를 던진다.

- [x] **Step 4: 테스트 실행하여 통과 확인**

Run: `flutter test test/presentation/onboarding/controllers/onboarding_nickname_controller_test.dart`
Expected: 전체 PASS

- [x] **Step 5: 정적 분석 및 전체 테스트 확인**

Run: `dart analyze`
Expected: 에러 없음

Run: `flutter test`
Expected: 전체 PASS

- [x] **Step 6: 커밋**

```bash
git add lib/presentation/onboarding/controllers/onboarding_nickname_controller.dart \
  test/presentation/onboarding/controllers/onboarding_nickname_controller_test.dart
git commit -m "$(cat <<'EOF'
fix: #16 - [C-2] OnboardingNicknameController의 금지된 명령형 Either 스타일 제거

isLeft() + getLeft().toNullable()! 패턴은 toNullable()의 강제 언래핑으로
런타임 크래시 위험이 있고 CLAUDE.md에서 명시적으로 금지한 스타일이다.
app_auth_controller.dart:25와 동일한 fold((error) => throw error, ...)
패턴으로 교체. 리팩터 전후 동일 동작을 보장하는 컨트롤러 테스트를 신규 추가.
EOF
)"
```

---

## Task 4: [I-1] `app_auth_controller.dart` — catch 블록 로깅 추가

**Files:**
- Modify: `lib/presentation/providers/app_auth_controller.dart`

**Interfaces:**
- Consumes: `Logger`(`package:logger/logger.dart`, 프로젝트 관례)
- Produces: 없음(로깅만 추가, 반환 타입/동작 불변)

- [x] **Step 1: `app_auth_controller.dart` 수정**

파일 상단 import에 추가:

```dart
import 'package:logger/logger.dart';
```

`AppAuthController` 클래스(28-48행)를 다음으로 교체:

```dart
@Riverpod(keepAlive: true)
class AppAuthController extends _$AppAuthController {
  final _logger = Logger();

  @override
  Future<AppStatus> build() async {
    try {
      final userState = await ref.watch(currentUserProvider.future);

      if (userState == null) {
        return AppStatus.unauthenticated;
      }

      if (userState.isNewUser) {
        return AppStatus.onboarding;
      }

      return AppStatus.authenticated;
    } catch (e) {
      _logger.e('앱 인증 상태 확인 실패 — AppStatus.error로 진입', error: e);
      return AppStatus.error;
    }
  }
}
```

- [x] **Step 2: 정적 분석 확인**

Run: `dart analyze lib/presentation/providers/app_auth_controller.dart`
Expected: 에러 없음

- [x] **Step 3: 전체 테스트 확인**

Run: `flutter test`
Expected: 전체 PASS (기존 테스트 영향 없음)

- [x] **Step 4: 커밋**

```bash
git add lib/presentation/providers/app_auth_controller.dart
git commit -m "$(cat <<'EOF'
fix: #16 - [I-1] AppAuthController catch 블록에 에러 로깅 추가

keepAlive 프로바이더이므로 에러 발생 시 앱 전체가 복구 불가 상태로
진입하는데, 기존에는 로그/스택 트레이스 없이 예외가 소멸했음.
EOF
)"
```

---

## Task 5: [I-2] `store_detail_provider.dart` — `ref.read` → `ref.watch`

**Files:**
- Modify: `lib/presentation/providers/store_detail_provider.dart`

**Interfaces:**
- Consumes: `storeUseCaseProvider`(`lib/domain/use_cases/store_use_case_provider.dart`, 기존)
- Produces: 없음(반응성만 수정, 반환 타입/시그니처 불변)

- [x] **Step 1: `store_detail_provider.dart` 수정**

`lib/presentation/providers/store_detail_provider.dart:9`:

```dart
  final result = await ref.read(storeUseCaseProvider).getStore(storeId);
```

를

```dart
  final result = await ref.watch(storeUseCaseProvider).getStore(storeId);
```

로 교체.

- [x] **Step 2: 정적 분석 확인**

Run: `dart analyze lib/presentation/providers/store_detail_provider.dart`
Expected: 에러 없음

- [x] **Step 3: 전체 테스트 확인**

Run: `flutter test`
Expected: 전체 PASS

- [x] **Step 4: 커밋**

```bash
git add lib/presentation/providers/store_detail_provider.dart
git commit -m "$(cat <<'EOF'
fix: #16 - [I-2] storeDetailProvider가 ref.watch로 의존성 그래프를 형성하도록 수정

ref.read로 use case를 조회하면 storeUseCaseProvider가 갱신되어도
storeDetailProvider가 재실행되지 않는다.
EOF
)"
```

---

## Task 6: [I-3] 4개 컨트롤러 — `StackTrace.current`를 `fold` 콜백 밖으로 호이스트

**Files:**
- Modify: `lib/presentation/providers/home_reservation_actions_controller.dart` (3곳)
- Modify: `lib/presentation/providers/reservation_ocr_controller.dart` (1곳)
- Modify: `lib/presentation/commons/store_input/controllers/store_creation_controller.dart` (1곳)
- Modify: `lib/presentation/commons/store_input/controllers/store_update_controller.dart` (1곳)

**Interfaces:**
- Consumes: 없음(신규 인터페이스 없음)
- Produces: 없음(동작 불변)

`fold` 콜백 안에서 `StackTrace.current`를 호출하면 콜백이 실행되는 시점(=`fold` 호출 시점)의 스택을 캡처한다. `await` 완료 직후, `fold` 호출 전에 `final stackTrace = StackTrace.current;`로 한 번만 캡처해 `fold` 콜백에서는 그 변수를 참조하도록 통일한다 — 컨트롤러 메서드 최상단 스코프에서 캡처하는 것이 클로저 내부에서 캡처하는 것보다 호출 지점을 명확히 가리키는 프로젝트 표준 패턴이다.

- [x] **Step 1: `home_reservation_actions_controller.dart` 수정 (3곳)**

`updateReservation`(19-30행)을 다음으로 교체:

```dart
  Future<void> updateReservation(Reservation reservation) async {
    final result = await ref
        .read(reservationUseCaseProvider)
        .updateReservation(reservation: reservation);
    final stackTrace = StackTrace.current;
    result.fold(
      (e) {
        _logger.e('예약 수정 실패', error: e);
        state = AsyncError(e, stackTrace);
      },
      (_) {},
    );
  }
```

`createReservation`(32-43행)을 다음으로 교체:

```dart
  Future<void> createReservation(Reservation reservation) async {
    final result = await ref
        .read(reservationUseCaseProvider)
        .createReservation(reservation: reservation);
    final stackTrace = StackTrace.current;
    result.fold(
      (e) {
        _logger.e('예약 생성 실패', error: e);
        state = AsyncError(e, stackTrace);
      },
      (_) {},
    );
  }
```

`deleteReservation`(57-71행)을 다음으로 교체:

```dart
  Future<void> deleteReservation(Reservation reservation) async {
    final result = await ref
        .read(reservationUseCaseProvider)
        .deleteReservation(
          storeId: reservation.storeSummary.id,
          reservationId: reservation.id,
        );
    final stackTrace = StackTrace.current;
    result.fold(
      (e) {
        _logger.e('예약 삭제 실패', error: e);
        state = AsyncError(e, stackTrace);
      },
      (_) {},
    );
  }
```

- [x] **Step 2: `reservation_ocr_controller.dart` 수정 (1곳)**

`analyzeImage`(38-61행)의 `try` 블록 내부를 다음으로 교체:

```dart
    try {
      final result = await ref
          .read(reservationOcrUseCaseProvider)
          .execute(bytes, storeSpaceMap: storeSpaceMap);
      if (_generation != myGeneration || !ref.mounted) return;
      final stackTrace = StackTrace.current;
      result.fold(
        (e) {
          _logger.e('OCR 실패', error: e);
          state = AsyncError(e, stackTrace);
        },
        (ocrResult) => state = AsyncData(ocrResult),
      );
    } catch (e, st) {
      if (_generation != myGeneration || !ref.mounted) return;
      _logger.e('OCR 분석 실패', error: e, stackTrace: st);
      state = AsyncError(OcrUnknownException(e.toString()), st);
    }
```

(바깥쪽 `catch (e, st)` 블록은 이미 실제 `st`를 캡처하므로 변경하지 않는다.)

- [x] **Step 3: `store_creation_controller.dart` 수정 (1곳)**

`submit`(63-89행)의 `try` 블록 내부를 다음으로 교체:

```dart
    try {
      final storeUseCase = ref.read(storeUseCaseProvider);

      final result = await storeUseCase.createStore(
        store: data.store,
        color: data.color,
        memo: data.memo,
      );
      final stackTrace = StackTrace.current;

      result.fold(
        (exception) =>
            state = state.copyWith(status: AsyncError(exception, stackTrace)),
        (_) {
          ref.invalidate(currentUserProvider);
          state = state.copyWith(status: const AsyncData(null));
        },
      );
    } catch (e, st) {
      state = state.copyWith(status: AsyncError(e, st));
    }
```

- [x] **Step 4: `store_update_controller.dart` 수정 (1곳)**

`submit`(74-96행)의 `try` 블록 내부를 다음으로 교체:

```dart
    try {
      final storeUseCase = ref.read(storeUseCaseProvider);
      final result = await storeUseCase.updateStore(
        store: data.store,
        color: data.color,
        memo: data.memo,
      );
      final stackTrace = StackTrace.current;
      result.fold(
        (exception) =>
            state = state.copyWith(status: AsyncError(exception, stackTrace)),
        (_) => state = state.copyWith(status: const AsyncData(null)),
      );
    } catch (e, st) {
      state = state.copyWith(status: AsyncError(e, st));
    }
```

- [x] **Step 5: 정적 분석 및 전체 테스트 확인**

Run: `dart analyze`
Expected: 에러 없음

Run: `flutter test`
Expected: 전체 PASS

- [x] **Step 6: 커밋**

```bash
git add lib/presentation/providers/home_reservation_actions_controller.dart \
  lib/presentation/providers/reservation_ocr_controller.dart \
  lib/presentation/commons/store_input/controllers/store_creation_controller.dart \
  lib/presentation/commons/store_input/controllers/store_update_controller.dart
git commit -m "$(cat <<'EOF'
fix: #16 - [I-3] fold 콜백 내부의 StackTrace.current 캡처 지점을 await 직후로 이동

fold 콜백(클로저) 안에서 StackTrace.current를 호출하면 콜백 실행 시점의
스택이 캡처되어 Crashlytics 리포트가 실제 await 호출 지점이 아닌 fold
내부를 가리킬 수 있다. await 완료 직후 컨트롤러 메서드 최상단 스코프에서
한 번만 캡처하도록 통일.
EOF
)"
```

---

## Task 7: [I-4] `three_day_calendar.dart` — `_DayHeaderCell`에 `isToday` 파라미터 전달

**Files:**
- Modify: `lib/presentation/home/widgets/three_day_calendar/three_day_calendar.dart`

**Interfaces:**
- Consumes: 부모 위젯의 `_isToday(DateTime date)` 메서드(275-280행, 기존 — `TimeGrid`에도 이미 `isToday: _isToday(date)`로 전달 중, 540행)
- Produces: `_DayHeaderCell({required DateTime date, required bool isToday})` — 생성자 시그니처 변경(private 위젯이므로 외부 영향 없음)

- [x] **Step 1: `_DayHeaderCell` 생성자에 `isToday` 파라미터 추가**

`lib/presentation/home/widgets/three_day_calendar/three_day_calendar.dart:587-600`을 다음으로 교체:

```dart
class _DayHeaderCell extends StatelessWidget {
  const _DayHeaderCell({required this.date, required this.isToday});

  final DateTime date;
  final bool isToday;

  static const _weekdayLabels = ['월', '화', '수', '목', '금', '토', '일'];
  String get _weekdayLabel => _weekdayLabels[date.weekday - 1];

  bool get _isSaturday => date.weekday == DateTime.saturday;
  bool get _isSunday => date.weekday == DateTime.sunday;
```

같은 클래스 내 `_weekdayTextColor`(625-629행 부근)와 그 아래 `_isToday`를 참조하는 다른 지점(640행 부근)에서 `_isToday`를 `isToday`로 교체한다:

```dart
  Color _weekdayTextColor(BuildContext context) {
    if (isToday) return context.label;
    if (_isSaturday) return context.systemBlue;
    if (_isSunday) return context.systemRed;
    return context.secondaryLabel;
```

`if (_isToday) {`(640행 부근, `_buildDayNumber` 내부)도 동일하게 `if (isToday) {`로 교체한다.

- [x] **Step 2: 호출부(519행)에 `isToday` 전달**

`lib/presentation/home/widgets/three_day_calendar/three_day_calendar.dart:519`:

```dart
                            child: _DayHeaderCell(date: date),
```

를

```dart
                            child: _DayHeaderCell(
                              date: date,
                              isToday: _isToday(date),
                            ),
```

로 교체. (같은 `itemBuilder` 블록 540행에서 `TimeGrid`에 이미 동일하게 `isToday: _isToday(date)`를 전달하고 있으므로 동일 값을 재사용하는 형태가 된다.)

- [x] **Step 3: 정적 분석 확인**

Run: `dart analyze lib/presentation/home/widgets/three_day_calendar/three_day_calendar.dart`
Expected: 에러 없음. `_DayHeaderCell` 내부에 남아있던 `_isToday` getter를 완전히 제거했는지 확인 — 미사용 멤버 경고가 없어야 한다.

- [x] **Step 4: 앱 실행 후 수동 검증**

Run: `flutter run --target lib/main_dev.dart`
홈 화면 3일 캘린더에서 오늘 날짜 헤더 셀의 텍스트 색상이 기존과 동일하게 강조 표시되는지 확인 (요일 라벨 색상: 오늘=`label`, 토=`systemBlue`, 일=`systemRed`).

- [x] **Step 5: 커밋**

```bash
git add lib/presentation/home/widgets/three_day_calendar/three_day_calendar.dart
git commit -m "$(cat <<'EOF'
fix: #16 - [I-4] _DayHeaderCell이 isToday를 파라미터로 전달받도록 변경

부모에 이미 존재하는 _isToday(date) 계산 결과(TimeGrid에도 동일하게
전달 중)를 재사용하도록 하여, _DayHeaderCell 내부에서 매 빌드마다
DateTime.now()를 호출하던 것을 제거.
EOF
)"
```

---

## Task 8: [I-5] `monthly_calendar.dart` — `DateTime.now()` 단일 변수화

**Files:**
- Modify: `lib/presentation/home/widgets/monthly_calendar/monthly_calendar.dart`

**Interfaces:**
- Consumes: 없음
- Produces: 없음(동작 불변)

- [x] **Step 1: `_referenceMonth` 계산 수정**

`lib/presentation/home/widgets/monthly_calendar/monthly_calendar.dart:19-20`:

```dart
  final _referenceMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
```

를

```dart
  static DateTime get _now => DateTime.now();
  final _referenceMonth = DateTime(_now.year, _now.month, 1);
```

로 교체한다. (인스턴스 필드 초기화 표현식에서는 지역 `final now = DateTime.now();`를 먼저 선언할 수 없으므로 — 초기화 표현식은 하나의 식이어야 함 — `static` getter로 감싸 단일 `DateTime.now()` 호출로 `year`/`month`가 항상 동일 시점을 참조하도록 만든다.)

- [x] **Step 2: 정적 분석 확인**

Run: `dart analyze lib/presentation/home/widgets/monthly_calendar/monthly_calendar.dart`
Expected: 에러 없음

- [x] **Step 3: 전체 테스트 확인**

Run: `flutter test`
Expected: 전체 PASS

- [x] **Step 4: 커밋**

```bash
git add lib/presentation/home/widgets/monthly_calendar/monthly_calendar.dart
git commit -m "$(cat <<'EOF'
fix: #16 - [I-5] MonthlyCalendar._referenceMonth의 DateTime.now() 중복 호출 제거

DateTime(DateTime.now().year, DateTime.now().month, 1)는 월 경계
순간에 year/month가 서로 다른 DateTime.now() 호출 결과를 참조할 수
있었음. 단일 호출 결과를 재사용하도록 수정.
EOF
)"
```

---

## Task 9: [I-6] `home_reservations_provider.dart` — `ref.read` → `ref.watch`

**Files:**
- Modify: `lib/presentation/providers/home_reservations_provider.dart`

**Interfaces:**
- Consumes: `reservationUseCaseProvider`(`lib/domain/use_cases/reservation_use_case_provider.dart`, 기존)
- Produces: 없음(반응성만 수정, 반환 타입/시그니처 불변)

- [x] **Step 1: `home_reservations_provider.dart` 수정**

`lib/presentation/providers/home_reservations_provider.dart:41`:

```dart
  final useCase = ref.read(reservationUseCaseProvider);
```

를

```dart
  final useCase = ref.watch(reservationUseCaseProvider);
```

로 교체.

- [x] **Step 2: 정적 분석 확인**

Run: `dart analyze lib/presentation/providers/home_reservations_provider.dart`
Expected: 에러 없음

- [x] **Step 3: 기존 테스트로 회귀 확인**

Run: `flutter test test/presentation/providers/home_reservations_provider_test.dart`
Expected: 전체 PASS — `reservationUseCaseProvider`를 `overrideWith`로 고정 주입하는 기존 테스트 스위트이므로 `ref.read`/`ref.watch` 차이와 무관하게 동일하게 통과해야 한다.

Run: `flutter test`
Expected: 전체 PASS

- [x] **Step 4: 커밋**

```bash
git add lib/presentation/providers/home_reservations_provider.dart
git commit -m "$(cat <<'EOF'
fix: #16 - [I-6] homeReservationsProvider가 ref.watch로 use case 의존성을 형성하도록 수정

currentUserProvider/homeStoreFilterControllerProvider는 이미 ref.watch를
사용 중이었으나 reservationUseCaseProvider만 ref.read였음. 프로젝트
관례(CLAUDE.md 성능 규칙) 통일을 위해 watch로 변경.
EOF
)"
```

---

## Task 10: [M-1] `_formatDateTime` 중복 제거 → `time_formatter.dart` extension으로 추출

**Files:**
- Modify: `lib/presentation/commons/extensions/time_formatter.dart`
- Modify: `lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart`
- Modify: `lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart`

**Interfaces:**
- Consumes: 없음
- Produces: `DateTime.formattedDateTime({bool dateOnly = false}) → String` — 신규 extension 멤버

- [x] **Step 1: `time_formatter.dart`에 `DateTime` extension 추가**

`lib/presentation/commons/extensions/time_formatter.dart` 끝(`TimeOfDayConverter` extension 뒤)에 추가:

```dart

extension DateTimeFormatter on DateTime {
  /// 날짜/시간을 "YYYY. MM. DD. (요일) [HH:mm]" 형식의 문자열로 변환.
  /// [dateOnly]가 true이면 시간 부분(HH:mm)을 생략한다.
  /// 예: 2026-07-27 14:30 -> "2026. 07. 27. (월) 14:30"
  String formattedDateTime({bool dateOnly = false}) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekdayLabel = weekdays[weekday - 1];
    final date =
        '$year. ${month.toString().padLeft(2, '0')}. ${day.toString().padLeft(2, '0')}. ($weekdayLabel)';
    if (dateOnly) return date;
    return '$date ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}
```

- [x] **Step 2: `reservation_create_modal.dart`에서 중복 헬퍼 제거 및 호출부 갱신**

파일 상단 import에 추가:

```dart
import 'package:studio_chance/presentation/commons/extensions/time_formatter.dart';
```

`_formatDateTime` 메서드 정의(371-378행)를 제거한다.

호출부 2곳을 교체한다:

`lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart:655`:
```dart
          content: _formatDateTime(_startTime, dateOnly: _isAllDay),
```
를
```dart
          content: _startTime.formattedDateTime(dateOnly: _isAllDay),
```
로 교체.

`lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart:678`:
```dart
          content: _formatDateTime(displayEndTime, dateOnly: _isAllDay),
```
를
```dart
          content: displayEndTime.formattedDateTime(dateOnly: _isAllDay),
```
로 교체.

- [x] **Step 3: `reservation_detail_modal.dart`에서 중복 헬퍼 제거 및 호출부 갱신**

파일 상단 import에 추가 (기존 import 목록 중 알파벳 순서를 고려해 `presentation/commons/extensions/store_color_extensions.dart` 근처에 추가):

```dart
import 'package:studio_chance/presentation/commons/extensions/time_formatter.dart';
```

`_formatDateTime` 메서드 정의(537-544행)를 제거한다.

호출부 4곳을 교체한다:

`lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart:1029`:
```dart
          content: _formatDateTime(_startTime, dateOnly: _isAllDay),
```
를
```dart
          content: _startTime.formattedDateTime(dateOnly: _isAllDay),
```
로 교체.

`lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart:1033`:
```dart
          content: _formatDateTime(displayEnd, dateOnly: _isAllDay),
```
를
```dart
          content: displayEnd.formattedDateTime(dateOnly: _isAllDay),
```
로 교체.

`lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart:1053`:
```dart
          content: _formatDateTime(_startTime, dateOnly: _isAllDay),
```
를
```dart
          content: _startTime.formattedDateTime(dateOnly: _isAllDay),
```
로 교체.

`lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart:1077`:
```dart
          content: _formatDateTime(displayEndTime, dateOnly: _isAllDay),
```
를
```dart
          content: displayEndTime.formattedDateTime(dateOnly: _isAllDay),
```
로 교체.

- [x] **Step 4: 정적 분석 확인**

Run: `dart analyze`
Expected: 에러 없음. 두 파일 모두에서 미사용 private 메서드 경고가 없어야 한다(둘 다 완전히 제거됨).

- [x] **Step 5: 앱 실행 후 수동 검증**

Run: `flutter run --target lib/main_dev.dart`
예약 생성 모달과 예약 상세 모달에서 시작/종료 시간 표시가 기존과 동일한 형식("YYYY. MM. DD. (요일) HH:mm" 또는 하루종일 시 날짜만)으로 나타나는지 확인.

- [x] **Step 6: 커밋**

```bash
git add lib/presentation/commons/extensions/time_formatter.dart \
  lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart \
  lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart
git commit -m "$(cat <<'EOF'
fix: #16 - [M-1] 중복된 _formatDateTime을 DateTime.formattedDateTime extension으로 추출

reservation_create_modal.dart, reservation_detail_modal.dart에 동일하게
구현되어 있던 사설 헬퍼를 time_formatter.dart의 DateTime extension으로
통합.
EOF
)"
```

---

## Task 11: [M-2] `home_screen.dart` — 더미 `User` 대신 실제 로그인 유저 정보 사용

**Files:**
- Modify: `lib/presentation/home/screens/home_screen.dart`

**Interfaces:**
- Consumes: `currentUserProvider`(`lib/presentation/providers/app_auth_controller.dart`, 기존) — `ref.read(currentUserProvider).value`
- Produces: 없음(내부 로직만 수정)

`_onAddReservation`은 `canCreateReservation`(빌드 시 `storeInfos.isNotEmpty` 필요)이 true일 때만 호출되는 FAB에서 트리거되므로, 호출 시점에 `currentUserProvider`는 이미 데이터를 보유한 상태다. 실제 로그인 유저 정보를 사용하도록 교체한다.

- [x] **Step 1: `_onAddReservation`에서 실제 유저 정보 조회**

`lib/presentation/home/screens/home_screen.dart`의 `_onAddReservation` 메서드 시작 부분(184행 부근, 메서드 시그니처 바로 다음 줄)에 다음을 추가한다:

```dart
  Future<void> _onAddReservation(
    List<UserStoreInfo> storeInfos,
    DateTime selectedStartDate,
  ) async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

```

(기존 메서드 본문 시작 부분은 그대로 유지하고 위 코드만 최상단에 삽입한다. 실제 파라미터 목록은 현재 시그니처를 그대로 따른다 — 파라미터명이 다르면 기존 것을 유지하고 본문 첫 줄에만 위 2줄을 추가한다.)

`lib/presentation/home/screens/home_screen.dart:210-223`:

```dart
    final initialReservation = Reservation(
      id: '',
      storeSummary: defaultStoreSummary,
      writer: StoreMemberInfo(
        user: const User(
          id: '',
          name: '',
          email: '',
          nickname: null,
          authProviders: [],
          storeInfos: [],
        ),
        role: defaultInfo.role,
      ),
```

를

```dart
    final initialReservation = Reservation(
      id: '',
      storeSummary: defaultStoreSummary,
      writer: StoreMemberInfo(
        user: currentUser,
        role: defaultInfo.role,
      ),
```

로 교체.

- [x] **Step 2: 미사용 import 정리**

`dart analyze` 실행 후 `User` 타입을 더 이상 직접 참조하지 않아 미사용 import 경고가 뜨면 해당 import(`import 'package:studio_chance/domain/entities/user.dart';`)를 제거한다. `Reservation`이 내부적으로 `User`를 참조하지만 이 파일에서 `User` 타입을 직접 명명하는 곳이 사라지면 해당 import는 불필요해진다.

- [x] **Step 3: 정적 분석 확인**

Run: `dart analyze lib/presentation/home/screens/home_screen.dart`
Expected: 에러 없음, 미사용 import 경고 없음

- [x] **Step 4: 앱 실행 후 수동 검증**

Run: `flutter run --target lib/main_dev.dart`
FAB(예약 추가 버튼) 탭 → 예약 생성 모달 오픈이 정상 동작하는지 확인 (writer 필드는 UI에 직접 노출되지 않으므로, 생성 완료 후 Firestore 문서의 `writer.user`가 빈 값이 아닌 실제 로그인 유저 정보로 저장되는지 확인).

- [x] **Step 5: 커밋**

```bash
git add lib/presentation/home/screens/home_screen.dart
git commit -m "$(cat <<'EOF'
fix: #16 - [M-2] 신규 예약 생성 시 writer에 더미 User 대신 실제 로그인 유저 사용

canCreateReservation 게이트로 인해 FAB 탭 시점에는 currentUserProvider가
항상 데이터를 보유하고 있으므로, 빈 값으로 채워진 인라인 User 객체 대신
실제 로그인 유저 정보를 사용하도록 수정.
EOF
)"
```

---

## Self-Review 결과

- **Spec coverage**: 이슈 체크리스트의 C-1, C-2, I-1~I-6, M-1, M-2 총 10개 항목 모두 Task 1~11에 매핑됨 (C-1이 파일 2개라 Task 1/2로 분리).
- **Placeholder scan**: 모든 Step에 실제 코드/명령어 포함, "TODO"/"적절히 처리" 등 표현 없음.
- **Type consistency**: `_DayHeaderCell(date:, isToday:)`, `DateTime.formattedDateTime({dateOnly})`, `StoreFilterModal(maxAvailableHeight:)`, `ReservationListModal(events:, maxAvailableHeight:)` 등 Task 간 참조되는 시그니처가 정의부와 호출부에서 일관됨을 확인.
