# Repository Review — 핵심 파일 & 결정 사항

> Last Updated: 2026-04-20

## 핵심 파일

| 파일 | 관련 이슈 |
|------|----------|
| `lib/data/repositories/reservation_repository_impl.dart` | BUG-1, FIRESTORE-1, PERF-1, MAINT-2 |
| `lib/data/repositories/store_repository_impl.dart` | MAINT-1, PERF-2 |
| `lib/data/repositories/user_repository_impl.dart` | FIRESTORE-2, PERF-3, MAINT-3 |
| `lib/data/data_sources/user_data_source.dart` | FIRESTORE-2 (updateUser 시그니처 영향) |
| `lib/data/data_sources/store_data_source.dart` | MAINT-1 참고 |

## 주요 결정 사항

### StoreColor 폴백 (BUG-1)
- CLAUDE.md 명시: 폴백 = `StoreColor.red`
- `_buildReservationEntity`(line 244)는 올바름, `getReservationsByDateRange`(line 107)만 수정 필요

### `fetchOrCreateUser` write 최적화 (FIRESTORE-2)
- `UserDataSource.updateUser`는 `Map<String, dynamic>` 받아서 그대로 Firestore update에 전달
- `FieldValue.arrayUnion([token])`을 map 값으로 넣어도 Firestore SDK가 정상 처리함
- 따라서 `addFcmToken` 호출 제거 후 `updateUser` 1회 호출로 통합 가능
- 단, `UserDataSource.addFcmToken`의 `updatedAt` 자동 갱신이 `updateUser`에서도 동작하므로 OK

### `updateReservation` 전체 JSON (FIRESTORE-1)
- 현재 `toJson()`에는 `createdAt`, `updatedAt`이 Timestamp 직렬화로 포함됨
- `updatedAt`은 DataSource에서 `FieldValue.serverTimestamp()`로 덮어쓰므로 실질적 문제 없음
- `createdAt`도 update payload에 포함되어 기존 서버 타임스탬프를 클라이언트 값으로 덮어씀 — 이게 실제 문제
- 해결: `ReservationModel`에 `toUpdateJson()` 추가 또는 Repository에서 불변 필드 제외

### `softDeleteUser` 시그니처 (MAINT-3)
- Domain의 `UserRepository` 인터페이스도 `Future<void>`로 선언되어 있음
- 인터페이스 변경이 필요하므로 Either 통일은 별도 이슈로 관리 권장
- 현재는 주석으로 "예외 전파 의도적" 명시하는 것으로 충분

## 아키텍처 제약사항

- Repository는 DataSource의 throw를 catch → `left()` 반환 (절대 예외 전파 금지)
- 단, `Future<void>` 시그니처 메서드는 예외 전파 방식 혼용 중 (softDeleteUser, removeCurrentDeviceFcmToken)
- Either 패턴은 Use Case 레벨에서 소비됨 (`result.fold(...)`)

## 의존성

```
ReservationRepository
  ├── ReservationDataSource (stores/{storeId}/reservations)
  ├── StoreDataSource (stores/{storeId})
  └── UserDataSource (users/{uid})

StoreRepository
  ├── StoreDataSource
  └── UserDataSource

UserRepository
  ├── AuthDataSource (Firebase Auth)
  ├── UserDataSource
  └── NotificationDataSource (FCM)
```
