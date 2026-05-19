# 확정 안내문 — 태스크 체크리스트

Last Updated: 2026-05-19

## Phase 1: Store 필드

- [x] **1-1** `confirmationNotes: String?` — `payment-instruction` 태스크에서 이미 추가됨

## Phase 2: 확정 안내문 화면

- [x] **2-1** `lib/presentation/home/screens/confirmation_notice_screen.dart` 생성
  - `CustomAppBar(title: '확정 안내문', actions: [AppBarActionButton(label: '완료', onPressed: context.pop)])`
  - `SafeArea` + `Stack` 레이아웃 (입금 안내문과 동일)
    - `Positioned.fill` + `SingleChildScrollView` (하단 패딩 145px)
    - `Positioned(bottom: 0)` 하단 고정 버튼 그룹
  - 버튼: `GroupedFormContainer` + `TextActionButton` × 2 (복사하기 / 공유하기)
  - 이용 장소: `address/Detail/Guide` 빈값 필터 후 공백 연결
  - `confirmationNotes` null/빈값 시 📌 섹션 생략
  - 자정 넘김·종일 예약 시간 포맷 처리 (입금 안내문과 동일 로직)

## Phase 3: 라우팅 연결

- [x] **3-1** `lib/router/router_path.dart` — `confirmationNotice` 추가
- [x] **3-2** `lib/router/app_router.dart` — home 서브 라우트 추가
- [x] **3-3** `reservation_detail_modal.dart` — `context.push` 연결, TODO 제거

## 검증

- [x] **4-1** `dart analyze` 오류 없음
- [ ] **4-2** 앱 실행 → 예약 상세 모달 → '확정 안내문' 탭 → 화면 진입 확인
- [ ] **4-3** 안내문 텍스트 플레이스홀더 치환 확인
- [ ] **4-4** 이용 장소: `address`, `addressDetail`, `addressGuide` 공백 연결 확인
- [ ] **4-5** `confirmationNotes` 있을 때 📌 섹션 표시 확인
- [ ] **4-6** `confirmationNotes` null 시 📌 섹션 생략 확인
- [ ] **4-7** 복사하기 → 클립보드 + SnackBar 확인
- [ ] **4-8** 공유하기 → 시스템 공유 시트 표시 확인
- [ ] **4-9** 뒤로가기 / 완료 → 예약 상세 모달로 복귀 확인
