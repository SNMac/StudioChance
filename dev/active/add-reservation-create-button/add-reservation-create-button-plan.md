# 예약 등록 버튼 추가 계획

Last Updated: 2026-05-19

## Executive Summary

홈 캘린더 화면에 예약 등록 버튼(FAB, "+")을 추가하고, 탭 시 예약 생성 모달이 열리도록 구현한다.
기존 `ReservationDetailModal`(조회/수정 전용)을 참고하여 **생성 전용 모달** `ReservationCreateModal`을 신규 작성하며,
`HomeReservationActionsController`에 `createReservation` 액션을 추가한다.

---

## Current State

| 항목 | 현황 |
|------|------|
| 예약 조회/수정 UI | `ReservationDetailModal` 완성 (읽기↔편집 인라인 전환) |
| 예약 생성 UseCase | `ReservationUseCase.createReservation()` 구현 완료 |
| 홈 Controller | `HomeReservationActionsController.updateReservation()` 만 있음 |
| 등록 버튼 | 없음 |
| 예약 생성 모달 | 없음 |

---

## Proposed Future State

```
HomeScreen
└── Scaffold
    ├── body: ... (기존 캘린더)
    ├── floatingActionButton: _AddReservationFab  ← 신규
    └── bottomNavigationBar: HomeTabBar

탭(FAB) → showReservationCreateModal()
           └── ReservationCreateModal (신규 위젯)
               ├── AppBar: "취소" / "저장"
               └── 편집 폼 (섹션 1~4, 생성 모드)
                   └── onSaved → HomeReservationActionsController.createReservation()
```

---

## Architecture Decisions

### A1. 모달 방식: 새 위젯 vs ReservationDetailModal 모드 추가
**결정: 새 위젯 `ReservationCreateModal`**
- 이유: `ReservationDetailModal`은 기존 `Reservation`을 수신하는 구조.
  생성 폼은 id 없는 초기 객체를 받고, 완료 시 `createReservation` 호출.
  두 흐름을 하나의 위젯에 억지로 합치면 복잡도만 증가.
- 재사용: edit body의 `_buildSection*Edit()` 로직은 거의 동일 → 중복 허용 (섣부른 추상화 지양)

### A2. FAB 위치
**결정: `Scaffold.floatingActionButton`**
- 이유: Material 3 표준 FAB 패턴. 기존 NavBar/AppBar 버튼들이 이미 2개라 추가 시 과밀.
- `floatingActionButtonLocation`: `FloatingActionButtonLocation.endFloat` (기본값)

### A3. 초기값 날짜
**결정: `homeCalendarControllerProvider.selectedStartDate` 기준 당일 오전 10:00**
- 이유: 사용자가 보고 있는 날짜가 가장 자연스러운 기본값.
- endTime: startTime + 1시간

### A4. 초기 StoreSummary
**결정: `currentUserProvider`의 `storeInfos` 첫 번째 점포**
- 이유: 대부분의 사용자는 점포 1개. 다중 점포 사용자는 폼 내 팝업으로 변경 가능.
- `UserStoreInfo` → `StoreSummary` 변환: `StoreSummary(id: info.id, name: info.name, color: info.color)`

### A5. Writer 초기값
**결정: 플레이스홀더 사용 (UseCase가 덮어씀)**
- `ReservationUseCaseImpl.createReservation()`이 자동으로 `currentUser`로 writer를 세팅하므로,
  초기 `Reservation` 객체의 `writer`는 플레이스홀더 `User`를 사용.
- `User(id: '', name: '', email: '', nickname: null, authProviders: [], storeInfos: [])`

---

## Implementation Phases

### Phase 1: Controller 확장 (S)
`HomeReservationActionsController`에 `createReservation()` 추가.

### Phase 2: 예약 생성 모달 위젯 (L)
`ReservationCreateModal` 신규 작성.
- 편집 모드 전용, 완료 시 `onSaved` 콜백 호출 (HomeScreen → Controller)
- `showReservationCreateModal()` 헬퍼 함수

### Phase 3: HomeScreen FAB 추가 (S)
`HomeScreen`에 FAB 추가, 탭 시 생성 모달 호출.
- `currentUserProvider`에서 storeInfos, `homeCalendarControllerProvider`에서 selectedStartDate 읽기

---

## Risk Assessment

| 리스크 | 수준 | 대응 |
|--------|------|------|
| ReservationCreateModal이 DetailModal과 코드 중복 | 낮음 | 허용 (별도 추상화 계층 불필요) |
| writer 초기값 플레이스홀더가 UseCase에서 미처리 | 낮음 | createReservation()이 반드시 currentUser로 덮어씀 |
| storeInfos 비어 있을 때 FAB 표시 | 낮음 | user.storeInfos.isEmpty → FAB 숨기기 |
| 기존 모달(BottomSheet) 패턴 미준수 | 없음 | DetailModal과 동일한 showModalBottomSheet 패턴 사용 |
