# 예약 등록 버튼 — 컨텍스트

Last Updated: 2026-05-19

## 구현 완료 상태

커밋 `ec9d359` (브랜치 `feat/#5-home`)에 전체 구현 포함.

## 변경된 파일

| 파일 | 변경 내용 |
|------|----------|
| `lib/presentation/providers/home_reservation_actions_controller.dart` | `createReservation(Reservation) → Future<bool>` 추가 |
| `lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart` | **신규** — 예약 생성 모달 전체 |
| `lib/presentation/home/screens/home_screen.dart` | FAB 추가, 역할 조건, `_AddReservationFab` 위젯 |

## 핵심 파일

| 파일 | 역할 |
|------|------|
| `lib/presentation/home/screens/home_screen.dart` | FAB 포함 홈 화면 |
| `lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart` | 예약 생성 모달 |
| `lib/presentation/providers/home_reservation_actions_controller.dart` | create/update 액션 |
| `lib/presentation/providers/home_reservations_provider.dart` | 생성 후 invalidate 대상 |
| `lib/presentation/providers/home_calendar_controller.dart` | selectedStartDate 소스 |
| `lib/presentation/providers/app_auth_controller.dart` | currentUserProvider (storeInfos) |

## 구현 결정 사항

### D1. `StatefulWidget` (Riverpod 없음)
`ReservationCreateModal`은 `StatefulWidget`. UseCase 호출은 `onSaved` 콜백으로 위임하므로 `ConsumerStatefulWidget` 불필요.

### D2. FAB 위치: `Scaffold.floatingActionButton` + `endFloat`
`Scaffold`가 `HomeTabBar`(커스텀 `bottomNavigationBar`) 높이를 측정하여 FAB를 그 위 16px에 자동 배치. 스크롤·월간 캘린더 상태와 무관하게 고정됨.

### D3. 역할 기반 가시성
`viewer` 역할은 예약 생성 불가 → FAB 숨김.
`admin`/`staff`가 하나라도 있으면 FAB 표시. 점포 선택 팝업도 `admin`/`staff` 점포만 포함.

### D4. `Riverpod 3.x` — `valueOrNull` 없음
`AsyncValue<T>` 값 접근: `asData?.value` (not `valueOrNull`).
```dart
currentUserProvider.select((u) => u.asData?.value?.storeInfos ?? [])
```

### D5. 초기 Reservation 객체의 writer
`Reservation.writer`(StoreMemberInfo)는 UseCase에서 currentUser로 덮어쓰므로 플레이스홀더 사용:
```dart
writer: StoreMemberInfo(
  user: const User(id: '', name: '', email: '', nickname: null, authProviders: [], storeInfos: []),
  role: defaultInfo.role,
)
```

## 데이터 흐름

```
HomeScreen(FAB 탭)
  → canCreateReservation: storeInfos.any(role == admin || staff)
  → selectedDate = homeCalendarControllerProvider.selectedStartDate
  → creatableInfos = storeInfos.where(role == admin || staff)
  → StoreSummary = UserStoreInfo.{ id, name, color }
  → initialReservation(id:'', startTime: selectedDate+10:00, endTime+1h)
  → showReservationCreateModal()
      → ReservationCreateModal.onSaved(newReservation)
          → HomeReservationActionsController.createReservation()
              → reservationUseCaseProvider.createReservation()
                  (UseCase: writer.user = currentUser 자동 세팅)
              → ref.invalidate(homeReservationsProvider)  // family 전체 무효화
```

## StoreSummary 변환 패턴

```dart
// UserStoreInfo → StoreSummary (별도 Provider 없이 직접 변환)
StoreSummary(id: info.id, name: info.name, color: info.color)
```

## 미완료 후속 작업

1. **생성 실패 피드백 UI**: 현재는 로그만 출력, 모달은 즉시 닫힘. 실패 시 에러 다이얼로그 표시 고려.
2. **availableStores 실제 연동**: 현재 `UserStoreInfo`를 `StoreSummary`로 변환. 추후 Store 도메인에서 전체 정보를 가져올 때 교체 필요.
3. **생성 후 캘린더 스크롤**: 예약 저장 성공 후 해당 날짜/시간으로 스크롤 이동하면 UX 향상.
