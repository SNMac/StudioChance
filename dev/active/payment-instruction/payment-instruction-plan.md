# 입금 안내문 화면 — 구현 계획

Last Updated: 2026-05-19

## Executive Summary

예약 상세 모달의 '입금 안내문' 버튼을 탭하면 나타나는 전용 화면.
예약 정보와 점포 계좌 정보를 조합해 완성된 입금 안내 텍스트를 보여주고,
하단 '복사하기' / '공유하기' 버튼으로 텍스트를 공유한다.

추가로 점포 생성/수정 폼에 입금 정보 입력 화면을 연동해,
관리자가 점포 계좌 정보를 직접 입력할 수 있도록 한다.
입금 안내문 미리보기는 실제 예약 없이도 확인 가능하다.

---

## 현재 상태 (구현 완료)

| 항목 | 상태 |
|------|------|
| `Store` entity/model 계좌·마감·주의사항 필드 | ✅ 완료 |
| 입금 안내문 화면 (`PaymentInstructionScreen`) | ✅ 완료 |
| 라우트 정의 | ✅ 완료 |
| 모달 → 화면 연결 | ✅ 완료 |
| `share_plus` 패키지 | ✅ 완료 |
| 입금 정보 입력 폼 (`PaymentInfoInputScreen`) | ✅ 완료 |
| 점포 폼 → 입금 정보 네비게이션 | ✅ 완료 |
| 미리보기 모드 (실제 폼 값 반영) | ✅ 완료 |

---

## Store 추가 필드 (5개)

| 필드명 | 타입 | 설명 |
|--------|------|------|
| `bankName` | `String?` | 점포 계좌 은행 (예: "국민은행") |
| `bankAccountNumber` | `String?` | 점포 계좌번호 |
| `bankAccountHolder` | `String?` | 점포 계좌 예금주 |
| `paymentDeadlineMinutes` | `int?` | 입금 마감 시간 (분 단위, 15~180) |
| `confirmationNotes` | `String?` | 확정 안내문 주의사항 (추후 확정 안내문 작업용) |

> ⚠️ `paymentDeadlineMinutes`는 분 단위. 초기 설계 `paymentDeadlineHours`에서 변경됨.

---

## 안내문 텍스트 템플릿

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

---

## 화면 구조

### PaymentInstructionScreen

```
┌─────────────────────────────────┐
│  <        입금 안내문           │  ← CustomAppBar
├─────────────────────────────────┤
│  [텍스트 내용]              ↑  │  ← bodyLarge, FontWeight.normal
│  (실제 예약값 or placeholder)   │     좌우 패딩 16px, 상단 32px
│                             S  │
│                             C  │
│                             R  │
│                             O  │
│                             L  │
│                             L  ↓
├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┤
│         복사하기                │  ← GroupedFormContainer
│─────────────────────────────── │     + TextActionButton × 2
│         공유하기                │
└─────────────────────────────────┘
```

**두 가지 진입 모드:**
- `reservation != null` → 실제 예약 기반 텍스트 (Store는 Firestore에서 로딩)
- `reservation == null` → 미리보기 (StoreFormState에서 bank info 읽음, 예약 필드는 placeholder)

### PaymentInfoInputScreen

```
┌─────────────────────────────────┐
│  <        입금 정보       완료  │  ← CustomAppBar
├─────────────────────────────────┤
│ ┌─────────────────────────────┐ │
│ │ 은행        [___________]  │ │  ← TitleTextField
│ ├─────────────────────────────┤ │
│ │ 계좌번호    [___________]  │ │  ← TitleTextField (숫자 전용)
│ ├─────────────────────────────┤ │
│ │ 예금주      [___________]  │ │  ← TitleTextField
│ ├─────────────────────────────┤ │
│ │ 입금 마감 기한  [1시간 ▾]  │ │  ← 인라인 CupertinoPicker
│ │ ┌─────────────────────────┐ │ │    (접힘/펼침 AnimatedContainer)
│ │ │   15분                 │ │ │
│ │ │ ▶ 30분 ◀              │ │ │
│ │ │   45분                 │ │ │
│ │ └─────────────────────────┘ │ │
│ └─────────────────────────────┘ │
│  예약 등록 시간 기준              │  ← footer 캡션
│                                  │
│ ┌─────────────────────────────┐ │
│ │         입금 안내문          │ │  ← TextActionButton
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

---

## 네비게이션 흐름

```
[StoreFormScreen] 점포 생성/수정
  └── "입금 정보" TitleNavigationButton
        └── PaymentInfoInputScreen (/store-creation/payment-info)
              ├── "완료" → 폼 저장 + pop
              └── "입금 안내문" → 폼 임시 저장 → 미리보기
                    └── PaymentInstructionScreen (reservation=null, previewStoreToEdit)

[HomeScreen] 예약 관리
  └── ReservationDetailModal
        └── "입금 안내문" 버튼
              └── context.push('/home/payment-instruction', extra: reservation)
                    └── PaymentInstructionScreen (reservation=Reservation)
```

---

## 설계 결정 사항

### D1: paymentDeadlineMinutes (분 단위)
초기 설계 `paymentDeadlineHours`(시간)에서 **분 단위**로 변경.
- 15분 단위 picker 지원 (15분, 30분, 45분, 1시간, ..., 3시간)
- 표시 형식: `_formatDuration(int minutes)` — 60분 미만은 `"n분"`, 이상은 `"n시간"` / `"n시간 m분"`
- Firestore JSON key: `paymentDeadlineMinutes`

### D2: 미리보기 모드에서 폼 컨트롤러 직접 참조
`PaymentInstructionScreen`이 미리보기 모드에서 `storeCreationControllerProvider` / `storeUpdateControllerProvider`를 `ref.watch`.
- Presentation 레이어 내부 참조이므로 아키텍처 위반 아님
- "입금 안내문" 버튼 탭 시 폼 값을 먼저 컨트롤러에 임시 저장 → 화면 전환

### D3: 두 개의 paymentInstruction 라우트
- `/home/payment-instruction`: `Reservation?` extra → 예약 기반
- `/store-creation/payment-info/payment-instruction`: `Store?` extra (`previewStoreToEdit`) → 미리보기

---

## 제외 범위

- '확정 안내문' 화면 — 별도 태스크 (`confirmationNotes` 필드는 이번에 추가)
- Firestore Security Rules 업데이트 — 배포 전 별도 처리
