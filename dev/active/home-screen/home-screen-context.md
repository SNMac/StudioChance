# 홈 화면 구현 - 컨텍스트

Last Updated: 2026-03-19

## 핵심 파일 경로

| 역할 | 경로 |
|------|------|
| 홈 화면 (현재 Placeholder) | `lib/presentation/home/home_screen.dart` |
| 색상 Extension | `lib/presentation/commons/extensions/context_colors.dart` |
| 폰트/테마 정의 | `lib/my_app.dart` |
| UI 상수 | `lib/constants/ui_constants.dart` |
| 데이터 상수 | `lib/constants/data_constants.dart` |
| 앱 라우터 | `lib/router/app_router.dart` |
| 라우트 경로 | `lib/router/router_path.dart` |
| 앱 상태 Provider | `lib/presentation/providers/app_auth_controller.dart` |

## 색상 시스템

`context_colors.dart`의 Extension 사용. `BuildContext` 기반으로 다크/라이트 모드 자동 대응.

```dart
context.label              // 주 텍스트
context.secondaryLabel     // 보조 텍스트
context.systemBackground   // 배경
context.separator          // 구분선 (opacity 0.5 두께선)
context.secondarySystemFill // 선택 셀 배경 (2, 3번째 선택일)
context.systemRed          // 일요일, 현재 시간선
context.systemBlue         // 토요일, 탭바 선택색
context.white              // 캡슐 텍스트, 오늘 날짜 숫자
```

## 텍스트 스타일

`Theme.of(context).textTheme.*` 사용:

```dart
bodyLarge     // 16px, w500 → 연월 버튼
bodyMedium    // 14px, w500 → 3일 헤더, 오늘 날짜
bodySmall     // 12px, w500 → (캡슐은 크기만 10으로 오버라이드)
labelLarge    // 14px, w400 → (날짜는 크기만 16으로 오버라이드)
labelMedium   // 12px, w400 → 요일 헤더
labelSmall    // 10px, w400 → 시간 레이블
```

커스텀 크기:
```dart
Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10)  // 캡슐
Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 16) // 날짜
```

## 기존 패턴 참조

### Provider 패턴 (riverpod_generator)
```dart
// 상태를 가진 Controller
@riverpod
class HomeCalendarController extends _$HomeCalendarController {
  @override
  HomeCalendarState build() => HomeCalendarState(...);
}

// Freezed 상태 클래스
@freezed
abstract class HomeCalendarState with _$HomeCalendarState {
  const factory HomeCalendarState({...}) = _HomeCalendarState;
}
```

### SharedPreferences 패턴
```dart
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) { ... }
```
기존 사용 여부 확인 후 패턴 통일.

### StatefulWidget 사용 시
`ConsumerStatefulWidget` + `ConsumerState` 사용 (ScrollController, AnimationController 등 로컬 상태 필요 시)

## 주요 결정 사항

### 확대/축소 범위
- 기본: 36px/시간
- 최소: 18px/시간 (0.5x)
- 최대: 72px/시간 (2.0x)

### 초기 스크롤 위치
현재 시간이 화면 중앙에 오도록 계산:
```
offset = (currentHour + currentMinute/60) * hourHeight - viewportHeight/2
offset = offset.clamp(0, maxScrollExtent)
```

### 3일 캘린더 스와이프
- `GestureDetector.onHorizontalDragEnd` 사용
- velocity 기반 이동량 결정 (`velocity.pixelsPerSecond.dx`)
- 최소 drag distance: 화면 너비의 1/3 이상 시 최소 1일 이동
- 항상 날짜 경계(00:00)에 스냅

### 현재 시간 업데이트
- `Timer.periodic(const Duration(minutes: 1), ...)` 사용
- `CurrentTimeIndicator` 위젯 내부에서 `mounted` 체크와 함께 관리
- `initState`에서 시작, `dispose`에서 취소

### CupertinoIcons 매핑
| 명세 | Flutter CupertinoIcon |
|------|----------------------|
| chevron.down | `CupertinoIcons.chevron_down` |
| chevron.up | `CupertinoIcons.chevron_up` |
| calendar.circle | `CupertinoIcons.calendar` (circle 버전 없으면 대체) |
| house | `CupertinoIcons.house` |
| house.fill | `CupertinoIcons.house_fill` |
| chart.line.uptrend.xyaxis | `CupertinoIcons.chart_bar` / `CupertinoIcons.chart_bar_fill` |
| person | `CupertinoIcons.person` |
| person.fill | `CupertinoIcons.person_fill` |

> `calendar_circle` 아이콘 존재 확인 완료

## 월간 캘린더 날짜 계산 로직

```dart
// 해당 월의 첫 번째 요일 (일=0, 월=1, ..., 토=6)
final firstDayOfMonth = DateTime(year, month, 1);
final startWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0

// 5행 × 7열 = 35칸
// startWeekday 이전: 이전 달 날짜 (opacity 0.3)
// 해당 월 날짜
// 35 - (startWeekday + daysInMonth) 이후: 다음 달 날짜 (opacity 0.3)
```

## 의존성

- `shared_preferences: ^2.5.4` (이미 추가됨)
- `riverpod_generator`, `freezed` (이미 추가됨)
- `flutter/cupertino.dart` (CupertinoIcons, CupertinoDatePicker)

## 코드 생성

구현 완료 후 반드시 실행:
```bash
dart run build_runner build --delete-conflicting-outputs
```
