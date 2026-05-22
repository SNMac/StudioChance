# Phase 17-E Android 스크롤 보존 — Option A 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Android에서 `DraggableScrollableSheet`를 제거하고 고정 높이 `showModalBottomSheet`로 대체하여 모드 전환 간 스크롤 위치 보존 문제를 해결한다.

**Architecture:** 현재 코드(17-D 상태)는 이미 `ReservationDetailModal` 내부에서 iOS와 동일한 Stack+Offstage 구조를 사용하고 있다. `DraggableScrollableSheet`가 제거되면 내부 ScrollController와 충돌이 사라져 스크롤 보존이 정상 작동한다.

**Tech Stack:** Flutter, Dart, `showModalBottomSheet`, `MediaQuery`

---

## 현재 상태 (17-D 잔류)

`showReservationDetailModal`의 Android 경로:
```dart
builder: (_) => DraggableScrollableSheet(
  initialChildSize: 0.6,
  snap: true,
  snapSizes: const [0.6, 1.0],
  builder: (_, _) => ReservationDetailModal(...),  // 컨트롤러 미연결 → 60% 고정
),
```
`ReservationDetailModal`은 이미 `scrollController` 파라미터 없음, Stack+Offstage 사용.

---

## 수정 파일

- Modify: `lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart` (showReservationDetailModal 함수 Android 경로)

---

### Task 1: DraggableScrollableSheet 제거 및 고정 높이 적용

**Files:**
- Modify: `lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart:742-769`

- [ ] **Step 1: Android 경로 수정**

`showReservationDetailModal` 함수 하단의 Android `showModalBottomSheet` 호출을 아래로 교체한다.

```dart
// 변경 전 (17-D 상태 — DraggableScrollableSheet가 남아있지만 컨트롤러 미연결)
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    barrierColor: modalBarrierColor,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(modalTopCornerRadius),
      ),
    ),
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 1.0,
      expand: false,
      snap: true,
      snapSizes: const [0.6, 1.0],
      builder: (_, _) => ReservationDetailModal(
        reservation: reservation,
        availableStores: availableStores,
        onSaved: onSaved,
      ),
    ),
  );
}

// 변경 후 (17-E Option A — DraggableScrollableSheet 제거, 고정 90% 높이)
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    barrierColor: modalBarrierColor,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(modalTopCornerRadius),
      ),
    ),
    builder: (ctx) => SizedBox(
      height: MediaQuery.of(ctx).size.height * 0.9,
      child: ReservationDetailModal(
        reservation: reservation,
        availableStores: availableStores,
        onSaved: onSaved,
      ),
    ),
  );
}
```

- [ ] **Step 2: dart analyze 실행**

```bash
dart analyze lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart
```

기대 결과: `No issues found!` (또는 firebase_options.dart 관련 기존 경고만)

- [ ] **Step 3: Android에서 시각적 검증**

Android 에뮬레이터/디바이스에서 확인:

| 항목 | 기대 동작 |
|------|----------|
| 모달 열림 | 화면 90% 높이로 열림, 스와이프 다운으로 닫힘 |
| 편집 전환 | 스크롤 위치 유지 |
| 읽기 전용 복귀 | 스크롤 위치 유지 |
| 취소 | 스크롤 위치 유지 + 편집 내용 폐기 |

- [ ] **Step 4: dev docs 업데이트**

`dev/active/reservation-detail-modal/reservation-detail-modal-tasks.md` — 17-E 섹션 추가:
```
### ✅ 17-E: Android — DraggableScrollableSheet 제거 (2026-04-22 완료)
- [ ] showReservationDetailModal Android 경로: DraggableScrollableSheet → SizedBox(height: 90%)
- [ ] dart analyze 통과
- [ ] Android 시각적 검증 완료
```

- [ ] **Step 5: 커밋**

```bash
git add lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart
git commit -m "fix: #5 - Android 모달 DraggableScrollableSheet 제거 → 스크롤 보존 해결 (17-E)"
```
