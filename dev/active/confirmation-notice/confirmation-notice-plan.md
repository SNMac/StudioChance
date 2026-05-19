# 확정 안내문 화면 — 구현 계획

Last Updated: 2026-05-19

## Executive Summary

예약 상세 모달의 '확정 안내문' 버튼을 탭하면 나타나는 전용 화면.
예약 정보와 점포 주소·안내 주의사항을 조합해 완성된 확정 안내 텍스트를 보여주고,
하단 '복사하기' / '공유하기' 버튼으로 텍스트를 공유한다.

UI 구조는 입금 안내문(`payment_instruction_screen.dart`)과 동일하며,
AppBar 우측에 '완료' 버튼이 추가된 점만 다르다.

---

## 현재 상태

| 항목 | 상태 |
|------|------|
| `Store` `confirmationNotes` 필드 | ✅ 존재 (`payment-instruction` 태스크에서 추가) |
| 확정 안내문 화면 | ✅ 구현 완료 |
| 라우트 정의 | ✅ 완료 |
| 모달 → 화면 연결 | ✅ 완료 |

---

## Store 의존 필드

| 필드명 | 타입 | 설명 |
|--------|------|------|
| `address` | `String` | 점포 주소 (required) |
| `addressDetail` | `String` | 점포 상세 주소 (required) |
| `addressGuide` | `String` | 점포 찾아오는 길 (required) |
| `confirmationNotes` | `String?` | 점포 안내·주의사항 (null 시 해당 섹션 생략) |

주소 세 필드는 빈 문자열을 필터링 후 공백으로 연결:
```dart
[store.address, store.addressDetail, store.addressGuide]
    .where((s) => s.isNotEmpty)
    .join(' ')
```

---

## 안내문 텍스트 템플릿

```
[{점포명} 예약 확정 안내]
안녕하세요, {점포명}입니다.

입금 확인이 완료되어 예약이 확정되었습니다. 예약 정보를 아래에 다시 한 번 안내드립니다.

• 예약자명: {예약자명}
• 예약자 전화번호: {예약자 전화번호}
• 예약 시간: {yyyy}년 {mm}월 {dd}일 ({요일}) {hh}시 ~ {hh}시 ({n}시간)
• 예약 인원: {예약 인원 수}인
• 이용 장소: {address} {addressDetail} {addressGuide}

📌 안내·주의사항          ← confirmationNotes null/빈값이면 이 섹션 통째로 생략
{점포 안내·주의사항}

이용해 주셔서 감사합니다! 좋은 시간 보내세요. 🙇‍♂️
```

### 플레이스홀더 매핑

| 플레이스홀더 | 소스 | 비고 |
|-------------|------|------|
| `{점포명}` | `reservation.storeSummary.name` | |
| `{예약자명}` | `reservation.customerName` | |
| `{예약자 전화번호}` | `reservation.customerPhone.formattedPhone` | 하이픈 포맷 |
| `{yyyy}년 {mm}월 {dd}일 ({요일})` | `reservation.startTime` | |
| `{hh}시 ~ {hh}시` | `startTime` ~ `endTime` | hour 포맷 |
| `{n}시간` | `endTime - startTime` duration | hours 차이 |
| `{예약 인원 수}` | `reservation.headCount` | |
| `{이용 장소}` | `store.address/Detail/Guide` | 빈값 필터 후 공백 연결 |
| `{점포 안내·주의사항}` | `store.confirmationNotes` | null/빈값 시 섹션 전체 생략 |

---

## UI 스펙

```
┌─────────────────────────────────┐
│  <      확정 안내문      완료   │  ← CustomAppBar + AppBarActionButton
├─────────────────────────────────┤
│  [{점포명} 예약 확정 안내]  ↑  │  ← bodyLarge, FontWeight.normal
│  안녕하세요, {점포명}입니다. │     좌우 패딩 16px, 상단 32px
│  ...                        S  │     (스크롤 영역)
│  ...                        C  │
│  ...                        R  │
│  ...                        O  │
│  ...                        L  │
│  ...                        L  ↓
├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┤  ← 버튼 위 gap 32px
│         복사하기                │  ← GroupedFormContainer
│─────────────────────────────── │     + TextActionButton × 2
│         공유하기                │     (하단 고정, 배경 불투명)
└─────────────────────────────────┘
```

- **AppBar**: `CustomAppBar(title: '확정 안내문', actions: [AppBarActionButton(label: '완료', onPressed: context.pop)])`
- **레이아웃**: `Stack` 구조 (입금 안내문과 동일)
  - `Positioned.fill` + `SingleChildScrollView`: 하단 패딩 145px
  - `Positioned(bottom: 0)`: 버튼 그룹 하단 고정
- **버튼**: `GroupedFormContainer` + `TextActionButton` × 2 (복사하기 / 공유하기)
- **Store 로딩 중**: `CircularProgressIndicator`
- **Store 에러 / null**: 주소 빈 문자열, `confirmationNotes` 섹션 생략

---

## 네비게이션 흐름

```
HomeScreen
  └── showReservationDetailModal (ModalBottomSheet)
        └── '확정 안내문' 버튼
              └── context.push('/home/confirmation-notice', extra: reservation)
                    └── ConfirmationNoticeScreen (전체화면)
                          └── 뒤로가기 / '완료' → 모달로 복귀
```

> 모달 context에 GoRouterState 없으므로 절대 경로 직접 push (`pushChild` 사용 불가)

---

## 제외 범위

- Store 수정 화면(`StoreFormScreen`)에 `confirmationNotes` 입력 UI 추가 — 별도 태스크
- Firestore Security Rules 업데이트 — 배포 전 별도 처리
