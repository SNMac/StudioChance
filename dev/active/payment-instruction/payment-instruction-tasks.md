# 입금 안내문 — 태스크 체크리스트

Last Updated: 2026-05-19

## Phase 1: 패키지 추가

- [x] **1-1** `pubspec.yaml`에 `share_plus: ^13.1.0` 추가
- [x] **1-2** `flutter pub get` 실행

## Phase 2: Store 필드 추가 (Domain + Data)

- [x] **2-1** `lib/domain/entities/store.dart` — 5개 필드 추가
  - `bankName: String?`
  - `bankAccountNumber: String?`
  - `bankAccountHolder: String?`
  - `paymentDeadlineHours: int?`
  - `confirmationNotes: String?`

- [x] **2-2** `lib/data/models/store_model.dart` — 5개 필드 추가, `toEditableJson` / `fromEntity` / `toEntity` 업데이트

- [x] **2-3** 코드 생성 완료, `dart analyze` 오류 없음

## Phase 3: Store 상세 조회 Provider

- [x] **3-1** `lib/presentation/providers/store_detail_provider.dart` 생성
- [x] **3-2** `store_detail_provider.g.dart` 생성 확인

## Phase 4: 입금 안내문 화면

- [x] **4-1** `lib/presentation/home/screens/payment_instruction_screen.dart` 생성
  - `CustomAppBar(title: '입금 안내문')` — leading 기본값만, actions 없음
  - `SafeArea` + `Stack` 레이아웃
    - `Positioned.fill` + `SingleChildScrollView` (하단 패딩 145px)
    - `Positioned(bottom: 0)` 하단 고정 버튼 그룹
  - 버튼: `GroupedFormContainer` + `TextActionButton` × 2 (복사하기 / 공유하기)
  - 자정 넘김 예약 시간 포맷 처리 (startTime.day ≠ endTime.day 분기)

## Phase 5: 라우팅 연결

- [x] **5-1** `lib/router/router_path.dart` — `paymentInstruction` 추가
- [x] **5-2** `lib/router/app_router.dart` — home 서브 라우트 추가
- [x] **5-3** `reservation_detail_modal.dart` — `context.push` 연결, TODO 제거
  - `pushChild` 미사용 (모달 context에 GoRouterState 없음 → 절대 경로 직접 push)

## 검증

- [x] **6-1** `dart analyze` 오류 없음
- [ ] **6-2** 앱 실행 → 예약 상세 모달 → '입금 안내문' 탭 → 화면 진입 확인
- [ ] **6-3** 안내문 텍스트 플레이스홀더 치환 확인
- [ ] **6-4** Store 계좌 정보 null 시 해당 항목 빈 문자열 표시 확인
- [ ] **6-5** 복사하기 → 클립보드 + SnackBar 확인
- [ ] **6-6** 공유하기 → 시스템 공유 시트 표시 확인
- [ ] **6-7** 뒤로가기 → 예약 상세 모달로 복귀 확인
