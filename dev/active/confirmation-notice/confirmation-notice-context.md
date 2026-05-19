# 확정 안내문 — 핵심 파일 및 의존성

Last Updated: 2026-05-19

## 수정 대상 파일

| 파일 | 변경 내용 |
|------|----------|
| `lib/router/router_path.dart` | `confirmationNotice` case 추가 (`'confirmation-notice'`) |
| `lib/router/app_router.dart` | home 서브 라우트로 `ConfirmationNoticeScreen` 추가 |
| `lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart:940` | `확정 안내문` onPressed 연결, TODO 제거 |

## 신규 생성 파일

| 파일 | 역할 |
|------|------|
| `lib/presentation/home/screens/confirmation_notice_screen.dart` | 확정 안내문 화면 |

## 재사용 Provider

`lib/presentation/providers/store_detail_provider.dart` — `payment-instruction` 태스크에서 생성.
`Store` 전체를 로드해야 `address/Detail/Guide` 및 `confirmationNotes`를 참조할 수 있음.

## Store 의존 필드 상세

```dart
// domain/entities/store.dart (기존 required 필드)
String address;        // 점포 주소
String addressDetail;  // 점포 상세 주소
String addressGuide;   // 점포 찾아오는 길

// domain/entities/store.dart (payment-instruction에서 추가된 nullable 필드)
String? confirmationNotes;  // 확정 안내문 주의사항
```

## 안내문 텍스트 빌드 로직 (핵심)

```dart
// 이용 장소: 빈 문자열 필터 후 공백 연결
final addressParts = store != null
    ? [store.address, store.addressDetail, store.addressGuide]
        .where((s) => s.isNotEmpty)
        .join(' ')
    : '';

// 안내·주의사항 섹션: null/빈값 시 통째로 생략
final notesSection = (store?.confirmationNotes?.isNotEmpty == true)
    ? '\n📌 안내·주의사항\n${store!.confirmationNotes}\n'
    : '';
```

## UI 스펙

| 항목 | 값 |
|------|-----|
| 본문 폰트 | `textTheme.bodyLarge` + `FontWeight.normal` |
| AppBar ↔ 본문 상단 | 32px |
| 본문 하단 ↔ 하단버튼 상단 | 32px |
| 좌우 패딩 | 16px |
| AppBar leading | `AppBarNaviBackButton` (기본값) |
| AppBar trailing | 없음 |
| 하단버튼 1 | 복사하기 |
| 하단버튼 2 | 공유하기 |

## 네비게이션 패턴

```dart
// reservation_detail_modal.dart
context.push(
  '${SCRoute.home.fullPath}/${SCRoute.confirmationNotice.path}',
  extra: widget.reservation,
);
```

`pushChild` 미사용 이유: 모달 context에 GoRouterState 없음 → 절대 경로 직접 push 사용.
(입금 안내문과 동일한 이유, `payment-instruction-context.md` 참고)

## 관련 문서
- `dev/active/payment-instruction/` — 동일 UI 구조의 입금 안내문 컨텍스트
