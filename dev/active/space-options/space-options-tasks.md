# Space Options — 작업 체크리스트

Last Updated: 2026-05-23

---

## Phase 1~5: 완료 ✅

모든 코드 변경 완료 (32파일), `dart analyze` 오류 0개, 커밋 `f0bb5e4` / `1b0f1e1`.

---

## Phase 6: StoreFormScreen UI 개선 ✅

- [x] **6-0** 각 공간 헤더 아코디언 접기/펼치기 UI 구현
  - `Set<String> _expandedSpaceIds` (공간 ID 기준)
  - `_SpaceOptionHeader` 위젯: CupertinoButton chevron + 인라인 TextField + 삭제/복사/추가 버튼
  - 접힌 상태 하단 `Divider` 표시
  - 공간별 `TextEditingController` Map으로 관리 (`_spaceNameControllers`)
  - "공간명" 별도 섹션 제거 → 헤더 인라인 직접 편집
  - `GroupedFormContainer` 제거 → 투명 배경
  - 하단 "공간 추가" TextButton → 각 헤더의 `+` 버튼으로 대체
- [x] **6-1** `isValid`에 공간명 검증 추가 (`spaceOptions.every((s) => s.name.isNotEmpty)`)

---

## 추가 작업 — 예약 모달 공간 선택 UI: 완료 ✅

- [x] **A-1** `ReservationCreateModal._buildSection1()`에 공간 선택 `TitlePopupButton<SpaceOption>` 추가
  - 공간 `isNotEmpty`일 때 표시 (1개여도 표시)
  - 선택 시 `setState(() => _spaceOptionId = s.id)` + `_recalculatePrice()`
- [x] **A-2** `ReservationDetailModal` 편집 모드에도 동일 UI 추가
  - `_buildSection1Edit()`: 팝업 추가
  - `_buildSection1ReadOnly()`: 공간 이름 표시
  - `_resetFields()`: `_spaceOptionId = r.spaceOptionId` 추가 (취소 시 복원)

---

## 추가 작업 — 안내/주의사항 분리 + 입금 마감: 완료 ✅ (커밋 24cb560)

- [x] `confirmationNotes` → `infoNotes` + `cautionNotes` 분리 (Store, StoreModel, StoreFormState 전반)
- [x] `StoreGuideInputScreen`: MemoTextField 두 개로 분리, `_cautionController` 초기화 버그 수정
- [x] `ConfirmationNoticeScreen`: `ℹ️ 안내사항` / `⚠️ 주의사항` 섹션 분리 표시
- [x] `paymentDeadlineMinutes` 선택지: 5분 단위 + 1시간 단위 24시간까지

---

## 수동 테스트 (앱 실행 필요)

- [x] **T-1** 점포 생성: 공간 아코디언 접기/펼치기 동작
- [ ] **T-2** 공간명 비우면 '완료' 비활성화, 입력하면 활성화
- [x] **T-3** 공간 추가(+)/삭제(🗑)/복사(📄) 버튼 동작
- [ ] **T-4** 저장 시 Firestore `spaceOptions` 배열 확인
- [ ] **T-5** 예약 생성: 공간 선택 → `spaceOptionId` Firestore 저장 확인
- [ ] **T-6** 점포 수정: 기존 공간 목록 불러오기 확인

---

## 참고

- 상세 구현 내용: `space-options-context.md`
- 공휴일 요금 TODO는 이 작업과 별개 (`isHoliday: false` 고정 유지)
- 하위 호환 코드(`_migrateToSpaceOptions`) 제거 완료 (커밋 `68477c3`)
