# Space Options — 작업 체크리스트

Last Updated: 2026-05-23

---

## Phase 1~5: 완료 ✅

모든 코드 변경 완료 (32파일), `dart analyze` 오류 0개, 커밋 `f0bb5e4` / `1b0f1e1`.

---

## Phase 6: 수동 테스트

- [ ] **6-1** 점포 생성 — 공간 추가/이름 입력/요금 설정 저장 확인
- [ ] **6-2** 점포 수정 — 기존 점포 공간 목록 불러오기 확인
- [ ] **6-3** 예약 생성 — `spaceOptionId` Firestore 저장 확인
- [ ] **6-4** Firestore 구버전 문서 (`priceSettingsModel`) 읽기 확인 (불필요할 수 있음 — 배포 전)

---

## 추가 작업 — 예약 모달 공간 선택 UI (미구현)

공간이 2개 이상인 경우 예약 생성/수정 시 공간을 선택할 수 없는 상태.
현재는 항상 첫 번째 공간 또는 기존 `reservation.spaceOptionId` 유지.

- [x] **A-1** `ReservationCreateModal._buildSection1()`에 공간 선택 `TitlePopupButton<SpaceOption>` 추가
  - `_spaceOptions?.length > 1` 일 때만 표시
  - 선택 시 `setState(() => _spaceOptionId = s.id)` + `_recalculatePrice()`
  - `itemLabelBuilder: (s) => s.name`
- [x] **A-2** `ReservationDetailModal` 편집 모드에도 동일 UI 추가
  - `_buildSection1Edit()`에 삽입
  - `_buildSection1ReadOnly()`에도 공간 이름 표시 (공간 2개 이상일 때)
  - `_resetFields()`에 `_spaceOptionId = r.spaceOptionId` 추가 (취소 시 복원)

---

## 참고

- 상세 구현 내용: `space-options-context.md`
- 하위 호환 코드(`_migrateToSpaceOptions`) 존재하지만, 배포 전이므로 실질적으로 필요 없음
- 공휴일 요금 TODO는 이 작업과 별개 (`isHoliday: false` 고정 유지)
