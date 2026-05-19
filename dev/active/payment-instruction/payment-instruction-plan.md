# 입금 안내문 화면 — 구현 계획

Last Updated: 2026-05-19

## Executive Summary

예약 상세 모달의 '입금 안내문' 버튼을 탭하면 나타나는 전용 화면.
예약 정보와 점포 계좌 정보를 조합해 완성된 입금 안내 텍스트를 보여주고,
하단 '복사하기' / '공유하기' 버튼으로 텍스트를 공유한다.

추후 확정 안내문 작업을 대비해 `confirmationNotes`도 이번에 Store에 함께 추가.

---

## 현재 상태

| 항목 | 상태 |
|------|------|
| `Store` entity/model 계좌·마감·주의사항 필드 | ❌ 없음 |
| 입금 안내문 화면 | ❌ 없음 |
| 라우트 정의 | ❌ 없음 |
| 모달 → 화면 연결 | ❌ TODO 주석만 있음 (`reservation_detail_modal.dart:932`) |
| `share_plus` 패키지 | ❌ pubspec에 없음 |

---

## Store 추가 필드 (5개)

| 필드명 | 타입 | 설명 |
|--------|------|------|
| `bankName` | `String?` | 점포 계좌 은행 (예: "국민은행") |
| `bankAccountNumber` | `String?` | 점포 계좌번호 |
| `bankAccountHolder` | `String?` | 점포 계좌 예금주 |
| `paymentDeadlineHours` | `int?` | 입금 마감 시간 (n시간 이내) |
| `confirmationNotes` | `String?` | 확정 안내문 주의사항 (추후 확정 안내문 작업용) |

기존 Firestore 문서에 해당 필드 없으면 `null` 역직렬화.
`toEditableJson()`에 포함 → 점포 수정 시 저장 가능.

---

## 안내문 텍스트 템플릿 (이미지 확인)

```
[{점포명} 예약 입금 안내]
안녕하세요, {점포명}입니다.

아래 내용으로 예약이 진행되었으며, 입금을 완료해 주시면 예약이 확정됩니다.

• 예약자명: {예약자명}
• 예약자 전화번호: {예약자 전화번호}
• 예약 시간: {yyyy}년 {mm}월 {dd}일 ({요일}) {hh}시 ~ {hh}시 ({n}시간)
• 예약 인원: {예약 인원 수}인
• 요금 안내: {요금}원

✔ 입금 계좌: {점포 계좌 은행} {점포 계좌번호} ({점포 계좌 예금주})
✔ 입금 마감 시간: 앱에 예약 등록한 시간 기준 {n}시간 이내

예약자와 실제 이용자의 이름 및 전화번호가 다를 경우 미리 알려주세요.
입금 확인 후 예약 확정 안내를 드리겠습니다.

감사합니다.
```

### 플레이스홀더 매핑

| 플레이스홀더 | 소스 | 비고 |
|-------------|------|------|
| `{점포명}` | `reservation.storeSummary.name` | |
| `{예약자명}` | `reservation.customerName` | |
| `{예약자 전화번호}` | `reservation.customerPhone.formattedPhone` | 하이픈 포맷 |
| `{yyyy}년 {mm}월 {dd}일 ({요일})` | `reservation.startTime` | `intl` DateFormat |
| `{hh}시 ~ {hh}시` | `startTime` ~ `endTime` | hour 포맷 |
| `{n}시간` | `endTime - startTime` duration | hours 차이 |
| `{예약 인원 수}` | `reservation.headCount` | |
| `{요금}` | `reservation.totalPrice` | `formattedPrice` |
| `{점포 계좌 은행}` | `store.bankName ?? ''` | |
| `{점포 계좌번호}` | `store.bankAccountNumber ?? ''` | |
| `{점포 계좌 예금주}` | `store.bankAccountHolder ?? ''` | |
| `{입금 마감 n}시간 이내` | `store.paymentDeadlineHours` | null 시 해당 줄 생략 또는 빈값 |

---

## UI 스펙

```
┌─────────────────────────────────┐
│  <        입금 안내문           │  ← CustomAppBar (actions 없음)
├─────────────────────────────────┤
│  [{점포명} 예약 입금 안내]  ↑  │  ← bodyLarge, FontWeight.normal
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

- **AppBar**: `CustomAppBar(title: '입금 안내문')` — leading 기본값(`AppBarNaviBackButton`)만 사용, actions 없음
- **레이아웃**: `Stack` 구조
  - `Positioned.fill` + `SingleChildScrollView`: 전체 영역 스크롤, 하단 패딩 145px(버튼 영역 높이)으로 마지막 내용 보호
  - `Positioned(bottom: 0)`: 버튼 그룹 하단 고정
- **버튼**: `GroupedFormContainer` + `TextActionButton` × 2 (복사하기 / 공유하기)
- **복사하기**: `Clipboard.setData` → `ScaffoldMessenger.showSnackBar("복사됐습니다.")`
- **공유하기**: `share_plus` 패키지 `SharePlus.instance.share(ShareParams(text: text))`
- **Store 로딩 중**: `CircularProgressIndicator`
- **Store 에러 / 계좌 null**: 해당 플레이스홀더 빈 문자열로 대체

---

## 네비게이션 흐름

```
HomeScreen
  └── showReservationDetailModal (ModalBottomSheet)
        └── '입금 안내문' 버튼
              └── context.push('/home/payment-instruction', extra: reservation)
                    └── PaymentInstructionScreen (전체화면)
                          └── 뒤로가기 / '완료' → 모달로 복귀
```

---

## 패키지 추가

`share_plus: ^11.0.0` (or latest stable) → `pubspec.yaml` 추가 후 `flutter pub get`

---

## 제외 범위

- Store 수정 화면(StoreFormScreen)에 계좌 정보 입력 UI 추가 — 별도 태스크
- '확정 안내문' 화면 — 별도 태스크 (Store 필드는 이번에 추가)
- Firestore Security Rules 업데이트 — 배포 전 별도 처리
