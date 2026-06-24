# Space Options — 핵심 파일 및 의존성

Last Updated: 2026-05-23

---

## 현재 구현 상태

**Phase 1~6 구현 완료. `dart analyze` 오류 0개.**

- 커밋: `f0bb5e4` — 전체 레이어 구현 (32파일)
- 커밋: `68477c3` — 예약 모달 공간 선택 UI, 하위 호환 코드 제거
- 커밋: `24cb560` — 확정 안내문 안내/주의사항 분리 + 입금 마감 기한 선택지 개선
- 커밋: (이후) — `store_form_screen.dart` + `store_form_state.dart` StoreFormScreen 아코디언 UI, isValid 공간명 검증

---

## 중요 결정 사항

### 1. 하위 호환 코드 제거 완료
`StoreDataSource._migrateToSpaceOptions()` 제거 완료 (커밋 `68477c3`).
앱 배포 전이므로 기존 Firestore 문서 호환 불필요.

### 2. 예약 모달 공간 선택 조건
처음에는 "공간 2개 이상일 때만 표시"였으나 → "공간이 1개여도 항상 표시"로 변경 (사용자 피드백).
`ReservationCreateModal`, `ReservationDetailModal` 모두 `isNotEmpty` 조건 사용.

### 3. StoreFormScreen 아코디언 UI (Phase 6)
각 공간 옵션을 접기/펼치기 가능한 아코디언 형태로 전환.

**구조:**
- `Set<String> _expandedSpaceIds`: 공간 ID 기준으로 펼침 상태 추적 (index 아님 — 삭제/추가에 강건)
- `Map<String, TextEditingController> _spaceNameControllers`: 공간별 이름 컨트롤러 Map 관리
- `GroupedFormContainer` 제거: 공간 헤더는 투명 배경으로 화면 배경에 직접 노출
- 접힌 상태에서만 `Divider(height: 0.5)` 하단 구분선 표시
- 펼친 상태: 헤더 아래 day group `PriceSettingInputForm` 위젯들 표시
- "공간명" 별도 TitleTextField 섹션 제거 → 헤더 TextField에서 인라인 직접 편집

**`_SpaceOptionHeader` 레이아웃 (height: 48):**
```
[CupertinoButton chevron 30×48] [SizedBox(4)] [Expanded TextField(titleMedium)]
[SizedBox(4)] [삭제 44×44?] [SizedBox(4)?] [복사 44×44] [SizedBox(4)] [추가 44×44?] [SizedBox(4)]
```
- chevron: `CupertinoButton(minimumSize: Size.zero, padding: zero)`, `Icon(size:16, color: systemBlue)`
- 삭제 조건: `showDelete = spaceOptions.length > 1`
- 추가 조건: `canAdd = spaceOptions.length < 5`
- 접힌 chevron: `CupertinoIcons.chevron_right`, 펼친: `CupertinoIcons.chevron_down`
- SafeAreaWithPadding이 이미 16px 좌측 패딩 제공 → 헤더에 별도 좌측 SizedBox 불필요

### 4. isValid 강화
`StoreFormState.isValid`에 `spaceOptions.every((s) => s.name.isNotEmpty)` 추가.
→ 공간명이 하나라도 비어있으면 '완료' 버튼 비활성화.

### 5. confirmationNotes → infoNotes + cautionNotes 분리 (커밋 24cb560)
`Store`, `StoreModel`, `StoreFormState`, `StoreFormControllerable` 전반 변경.
- `infoNotes`: 안내사항, `cautionNotes`: 주의사항
- `StoreGuideInputScreen`: `_cautionController` 초기화 누락 버그 수정 포함
- `ConfirmationNoticeScreen._buildText()`: 두 섹션 각각 `ℹ️`/`⚠️` 아이콘으로 표시

### 6. paymentDeadlineMinutes 선택지 개선 (커밋 24cb560)
`[0, 5, 10, ..., 55, 60, 120, ..., 1440]` — 5분 단위 + 1시간 단위 24시간까지.
- 0 = "설정 안함" (null로 저장)
- null이면 입금 안내문에 마감 시간 줄 미표시

---

## 변경된 파일 목록

### 전체 커밋 변경

| 커밋 | 파일 | 변경 내용 |
|------|------|----------|
| `68477c3` | `store_data_source.dart` | `_migrateToSpaceOptions()` 제거 |
| `68477c3` | `reservation_create_modal.dart` | 공간 선택 팝업 UI (isNotEmpty 조건) |
| `68477c3` | `reservation_detail_modal.dart` | 공간 선택 팝업 + ReadOnly 표시 + resetFields 버그 수정 |
| `24cb560` | `store.dart`, `store_model.dart` | `infoNotes` + `cautionNotes` 추가 |
| `24cb560` | `store_form_state.dart` | `infoNotes`, `cautionNotes` 필드 |
| `24cb560` | `store_form_controllerable.dart` | `setInfoNotes`, `setCautionNotes` 인터페이스 |
| `24cb560` | `store_guide_input_screen.dart` | `_cautionController` 초기화 버그 수정 |
| `24cb560` | `confirmation_notice_screen.dart` | 두 섹션 분리 표시 |
| `24cb560` | `payment_info_input_screen.dart` | 선택지 확장 |
| `24cb560` | `payment_instruction_screen.dart` | null 처리 |
| (이후) | `store_form_screen.dart` | `_SpaceOptionHeader` 아코디언 UI 전면 재작성 |
| (이후) | `store_form_state.dart` | `isValid`에 공간명 검증 추가 |

---

## 핵심 현재 구조

```
Store.spaceOptions: List<SpaceOption>
  └── SpaceOption { id, name, priceSetting: PriceSetting }
        └── PriceSetting { dayGroups: List<DayGroup> }
              └── DayGroup { days, headcountRule, timeSlots }

Reservation.spaceOptionId: String?    ← null = 첫 번째 공간 폴백
```

### StoreFormScreen 공간 옵션 상태 관리
```dart
// _StoreFormScreenState 필드
Set<String> _expandedSpaceIds     // 펼쳐진 공간 ID Set
Map<String, TextEditingController> _spaceNameControllers  // 공간별 이름 컨트롤러

// initState: 기존 공간들로 초기화
for (final space in initialState.spaceOptions) {
  _expandedSpaceIds.add(space.id);
  _spaceNameControllers[space.id] = TextEditingController(text: space.name);
}

// dispose: 모든 컨트롤러 해제
for (final c in _spaceNameControllers.values) { c.dispose(); }

// 추가 시
_spaceNameControllers[newSo.id] = TextEditingController(text: newSo.name);
setState(() => _expandedSpaceIds.add(newSo.id));

// 삭제 시
_spaceNameControllers.remove(so.id)?.dispose();
setState(() => _expandedSpaceIds.remove(so.id));
notifier.removeSpaceOption(si);
```

---

## 다음 작업

**Phase 6 수동 테스트** (앱 실행 후 확인):

1. 점포 생성 화면에서 공간 아코디언 접기/펼치기 동작 확인
2. 공간명 인라인 편집 → '완료' 버튼 활성화 확인 (공간명 비우면 비활성화)
3. 공간 추가/삭제/복사 동작 확인
4. 저장 시 Firestore `spaceOptions` 배열로 저장되는지 확인
5. 예약 생성 모달에서 공간 선택 → `spaceOptionId` Firestore 저장 확인

---

## 코드 생성 명령어

```bash
dart run build_runner build --delete-conflicting-outputs
```
