# 캘린더 실제 데이터 연결 설계

**날짜**: 2026-05-18  
**범위**: Presentation 레이어 ↔ Domain 레이어 연결, 목업 데이터 제거

---

## 배경

캘린더 화면(`ThreeDayCalendar`)이 하드코딩된 목업 데이터를 사용 중이다.  
Domain + Data 레이어는 완전히 구현되어 있으나 Presentation 레이어와 연결되지 않았다.  
`onSaved` 콜백 4곳도 모두 빈 TODO 상태다.

---

## 목표

1. 목업 데이터 제거 → Firestore 실제 데이터 표시
2. 예약 저장(수정) 로직 연결
3. 순수 함수 추출 → 단위 테스트 작성

---

## 접근 방식

`homeReservationsProvider(DateTime month)` family provider 신규 생성.  
`onSaved` 콜백은 `void` 타입 유지, 내부에서 fire-and-forget async.  
저장 성공 시 `ref.invalidate(homeReservationsProvider)` → 캘린더 자동 새로고침.

---

## 데이터 흐름

```
currentUserProvider (storeInfos)
        ↓
homeReservationsProvider(month)   ← homeCalendarController.displayedMonth
        ↓ List<Reservation>
ThreeDayCalendar
  └─ buildEventsFromReservations() → (List<ReservationDisplayData>, Map<String, Reservation>)
  └─ eventsForDate()               → 날짜별 필터링 + 자정분할
        ↓
AllDayCell / TimeGrid
  └─ showReservationDetailModal(availableStores, onSaved)
       onSaved: updateReservation → ref.invalidate → 새로고침
```

---

## 파일별 설계

### 신규: `lib/presentation/home/utils/calendar_events_utils.dart`

순수 Dart 유틸리티 함수. Flutter/Firebase 의존 없음.

```dart
/// Reservation 목록 → 화면 표시용 데이터 구조 변환
(List<ReservationDisplayData>, Map<String, Reservation>) buildEventsFromReservations(
    List<Reservation> reservations)

/// 특정 날짜의 이벤트 필터링 + 자정 넘김 분할
List<ReservationDisplayData> eventsForDate(
    List<ReservationDisplayData> allEvents,
    DateTime date, {
    required bool allDay,
})
```

`eventsForDate` 로직:
- `allDay=true`: startTime이 해당 날짜인 이벤트만 반환
- `allDay=false`: 해당 날짜에 시작하는 이벤트 + 이전 날에서 이어지는 이벤트
- 자정 넘김: 시작일에 `continuesNextDay=true` + endTime=자정, 익일에 `isContinuation=true` + startTime=자정

### 신규: `lib/presentation/providers/home_reservations_provider.dart`

```dart
@riverpod
Future<List<Reservation>> homeReservations(Ref ref, DateTime month)
```

- `currentUserProvider`에서 storeInfos 획득
- `month` 기준: `DateTime(year, month, 1)` ~ `DateTime(year, month+1, 1)`
- 모든 storeId 병렬 쿼리 (`Future.wait`)
- 실패 점포는 빈 리스트로 처리 (부분 성공 허용)
- 반환: 모든 점포 예약 병합 목록

### 수정: `three_day_calendar.dart`

제거:
- `_mockData`, `_mockEvents`, `_mockReservations` 정적 필드 및 `_buildMockData()` 전체
- `_eventsForDate` 정적 메서드 (→ `calendar_events_utils.dart`로 이전)
- 목업용 임포트 (`User`, `StoreMemberInfo`, `PaymentMethod` 등)

추가:
- `homeReservationsProvider(displayedMonth)` watch
- `AsyncValue.when` → loading/error 시 빈 이벤트
- `availableStores` 계산: `currentUser.storeInfos` → `List<StoreSummary>`
- `AllDayCell`, `TimeGrid`에 `availableStores` 전달

### 수정: `all_day_row.dart`

```dart
class AllDayCell extends ConsumerStatefulWidget {
  // 추가 파라미터:
  final List<StoreSummary>? availableStores;
}
```

`onSaved` 구현:
```dart
onSaved: (updated) {
  ref.read(reservationUseCaseProvider)
     .updateReservation(reservation: updated)
     .then((r) => r.fold(
       (e) => _logger.e('예약 수정 실패', error: e),
       (_) => ref.invalidate(homeReservationsProvider),
     ));
},
```

`showReservationDetailModal`에 `availableStores: widget.availableStores` 전달.

### 수정: `time_grid.dart`

`AllDayCell`과 동일 패턴. `onSaved` 3곳 모두 동일 구현.

---

## 테스트 설계

### `test/presentation/home/utils/calendar_events_utils_test.dart`

순수 단위 테스트 (의존 없음):

| 케이스 | 검증 내용 |
|--------|----------|
| 오늘 이벤트 | 오늘 날짜에만 반환 |
| 자정 넘김 (시작일) | `continuesNextDay=true`, `endTime`=자정으로 클립 |
| 자정 넘김 (익일) | `isContinuation=true`, `startTime`=자정으로 클립 |
| 이전 날 이벤트 | 다른 날 날짜에 반환 안 됨 |
| 종일 필터 | `allDay: false`에서 종일 이벤트 걸러짐 |
| 빈 목록 | 빈 결과 반환 |

### `test/presentation/providers/home_reservations_provider_test.dart`

ProviderContainer + mock 사용:

| 케이스 | 검증 내용 |
|--------|----------|
| storeInfos 없음 | 빈 목록 반환 |
| 복수 점포 | 결과 병합, 정렬 |
| 한 점포 실패 | 성공 점포 결과만 포함 |
| currentUser null | 빈 목록 반환 |

---

## 명시적으로 제외 (스코프 외)

- `reservation_detail_modal.dart:763` n번째 예약 계산
- `reservation_detail_modal.dart:783, 789` 입금/확정 안내문 화면
- `all_day_row.dart:49` 다중 이벤트 겹침 처리
- 점포 필터 버튼 UI 구현
