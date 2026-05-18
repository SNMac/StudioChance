# 점포 필터 — 컨텍스트

Last Updated: 2026-05-19

## 구현 상태: 완료

## 핵심 파일

| 파일 | 역할 |
|------|------|
| `lib/presentation/providers/home_store_filter_controller.dart` | 필터 상태 + SharedPreferences 영구 저장 **(신규)** |
| `lib/presentation/home/widgets/store_filter_modal.dart` | 필터 모달 UI **(신규)** |
| `lib/presentation/providers/home_reservations_provider.dart` | 필터 적용 **(수정)** |
| `lib/presentation/home/widgets/home_nav_bar.dart` | 버튼 연결, 플레이스홀더 제거 **(수정)** |

## 주요 설계 결정

### deselectedIds 저장 전략
선택된 ID 대신 **해제된 ID**를 저장.
- 새로 추가된 점포는 자동 선택 (deselected 목록에 없으므로)
- 키: `'home_store_filter_deselected_ids'` (StringList)
- allIds - deselectedIds = selectedIds (build시 계산)

### Set 조작 방식
`{...state}..remove()` 문법은 build_runner의 AST 파서가 Map 리터럴로 오인하여 코드 생성 실패.
→ `Set<String>.of(state)` 방식으로 교체.

### prefs null 처리
`sharedPreferencesProvider`가 `Future<SharedPreferences>`이므로:
- `ref.watch(...).asData?.value` — null이면 전체 선택 반환 (prefs 로드 전 안전 폴백)
- `_persistDeselected()` 내부에서도 null 체크 후 early return

## 참조 패턴

```dart
// 기존 SharedPreferences 사용 패턴 (hour_height_preference_provider.dart 참조)
final prefs = ref.watch(sharedPreferencesProvider).asData?.value;
if (prefs == null) return defaultValue;
```

## 도메인 엔티티

```dart
// UserStoreInfo (lib/domain/entities/user_store_info.dart)
UserStoreInfo({ id, name, role, color, memo })

// StoreColor.foregroundColorValue — 도트 색상
// UserRole.displayName — '관리자', '스태프', '뷰어'
```
