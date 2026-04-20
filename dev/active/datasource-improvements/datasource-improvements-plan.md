# DataSource 개선 계획

Last Updated: 2026-04-20

## Executive Summary

5개 DataSource 파일(`auth`, `user`, `store`, `reservation`, `notification`)에서 발견된 버그 가능성, 타입 불일치, 성능/유지보수 문제를 수정합니다.
핵심 이슈는 `replaceFcmToken`의 배치 안정성 문제(데이터 유실 위험)와 `getFcmToken`의 반환 타입 불일치입니다.

## 현재 상태 분석

### 높은 우선순위 (버그 가능성)
1. **`user_data_source.dart` - `replaceFcmToken`**: 같은 Firestore 문서에 동일 필드(`fcmTokens`)로 두 번 `batch.update` 호출 → 두 번째 update가 첫 번째를 덮어써 `arrayRemove` 결과 유실 위험
2. **`notification_data_source.dart` - `getFcmToken`**: token null 시 throw하므로 실제 null 반환 없음. 인터페이스/구현체 모두 `Future<String?>` → `Future<String>` 수정 필요

### 중간 우선순위 (코드 정확성)
3. **`auth_data_source.dart` - `_getGoogleCredential`**: null 체크 완료된 `idToken` 변수 대신 `googleAuth.idToken` 재참조 (line 201)
4. **`user_data_source.dart` - `softDeleteUser`**: `deletedAt`은 서버 타임스탬프, `expiresAt`은 클라이언트 `DateTime.now()` 기준 → 클럭 불일치 위험

### 낮은 우선순위 (유지보수성)
5. **`store_data_source.dart`**: `_generateRandomCode` 호출 시마다 `Random()` 새 인스턴스 생성
6. **`store_data_source.dart`**: 만료 코드에 `StoreNotFoundException` 사용 → 의미 불일치
7. **컬렉션 참조 중복**: `reservation`(4회), `user`, `store` 각각 반복 경로 → private helper 추출

## 구현 계획

### Phase 1: 버그 수정 (높은 우선순위)
- `replaceFcmToken` → Transaction으로 변경
- `getFcmToken` 반환 타입 `Future<String>`으로 수정 (인터페이스 + 구현체)

### Phase 2: 코드 정확성 개선
- `_getGoogleCredential`에서 `idToken` 변수 활용
- `softDeleteUser`의 `expiresAt` 처리 방식 명확화 주석 추가

### Phase 3: 유지보수성 개선
- `Random` 클래스 필드로 추출
- `_reservationsRef`, `_userDocRef`, `_storeDocRef` helper 추출
- 만료 초대코드 예외 타입 개선

## 위험 평가

| 위험 | 영향 | 완화 방안 |
|------|------|----------|
| `replaceFcmToken` Transaction 변경 | FCM 토큰 교체 로직 동작 변경 | 테스트 케이스 확인 |
| `getFcmToken` 타입 변경 | 상위 Repository 코드 영향 | 호출부 null 처리 제거 확인 |

## 성공 기준
- 모든 DataSource 컴파일 오류 없음
- `replaceFcmToken`이 Transaction으로 원자적 실행
- `getFcmToken` 반환 타입 `Future<String>` 통일
- 코드 중복 제거
