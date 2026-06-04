# 멤버 관리 DataSource 테스트 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `StoreFirestoreDataSource`의 멤버 관리 4개 메서드(`approveMember`, `updateMemberRole`, `removeMember`, `requestJoinWithBatch`)에 대한 단위 테스트를 추가하여 DataSource 테스트 커버리지를 완성한다.

**Architecture:** 기존 `fake_cloud_firestore` 기반 테스트 패턴을 그대로 활용하여 `store_data_source_test.dart`에 헬퍼 함수와 테스트 그룹을 추가한다. 구현 코드는 이미 완성되어 있으므로 모든 테스트가 즉시 통과되어야 한다.

**Tech Stack:** fake_cloud_firestore 4.1.1, flutter_test, Dart

---

## 파일 구조

| 파일 | 작업 |
|------|------|
| `test/data/data_sources/store_data_source_test.dart` | 헬퍼 3개 추가 + 테스트 그룹 4개(9개 테스트) 추가 |

기존 파일에만 수정이 발생한다. production 파일 변경 없음.

---

## 핵심 컨텍스트

### Freezed @Default 타입 주의사항
`{}` 대신 반드시 `<String, dynamic>{}` 형태로 명시적 타입 파라미터를 사용할 것.  
이유: `const {}`의 런타임 타입이 `_Map<dynamic, dynamic>`이라 fake_cloud_firestore 내부 캐스팅 시 TypeError 발생.

### enum JSON 값
- `UserRole.admin` → `'ADMIN'`, `UserRole.staff` → `'STAFF'`
- `StoreColor.red` → `'RED'`, `StoreColor.blue` → `'BLUE'`

### 테스트 메서드 동작
- `approveMember(storeId, uid, memberInfo)`: `waitingMemberById.$uid` 삭제 + `memberById.$uid` = memberInfo
- `updateMemberRole(storeId, uid, role)`: batch — store `memberById.$uid.role` + user `storeById.$storeId.role`
- `removeMember(storeId, uid)`: batch — store `memberById.$uid` 삭제 + `waitingMemberById.$uid` 삭제 + user `storeById.$storeId` 삭제
- `requestJoinWithBatch(storeId, uid, memberInfo, userStoreInfo)`: batch — store `waitingMemberById.$uid` + user `storeById.$storeId`

---

## Task 1: 테스트 헬퍼 함수 추가

**Files:**
- Modify: `test/data/data_sources/store_data_source_test.dart` (기존 `_seedUserDoc` 함수 아래에 추가)

- [ ] **Step 1: 헬퍼 함수 3개 작성**

  기존 `_seedUserDoc` 함수 아래에 다음 헬퍼 3개를 추가한다:

  ```dart
  /// store에 대기 중인 멤버(uid)를 포함한 store 문서를 생성합니다.
  Future<void> _seedStoreWithWaitingMember(
    FakeFirebaseFirestore firestore,
    String storeId,
    String uid,
  ) async {
    await firestore.collection('stores').doc(storeId).set(<String, dynamic>{
      'name': '테스트 점포',
      'address': '서울시 강남구',
      'addressDetail': '101호',
      'addressGuide': '안내',
      'memberById': <String, dynamic>{},
      'waitingMemberById': <String, dynamic>{
        uid: <String, dynamic>{'role': 'STAFF'},
      },
      'spaceOptions': <dynamic>[],
    });
  }

  /// store에 활성 멤버와 대기 멤버 모두 uid로 포함한 store 문서를 생성합니다.
  Future<void> _seedStoreWithMember(
    FakeFirebaseFirestore firestore,
    String storeId,
    String uid,
  ) async {
    await firestore.collection('stores').doc(storeId).set(<String, dynamic>{
      'name': '테스트 점포',
      'address': '서울시 강남구',
      'addressDetail': '101호',
      'addressGuide': '안내',
      'memberById': <String, dynamic>{
        uid: <String, dynamic>{'role': 'STAFF'},
      },
      'waitingMemberById': <String, dynamic>{
        uid: <String, dynamic>{'role': 'STAFF'},
      },
      'spaceOptions': <dynamic>[],
    });
  }

  /// 빈 멤버 목록의 store 문서를 생성합니다.
  Future<void> _seedEmptyStore(
    FakeFirebaseFirestore firestore,
    String storeId,
  ) async {
    await firestore.collection('stores').doc(storeId).set(<String, dynamic>{
      'name': '테스트 점포',
      'address': '서울시 강남구',
      'addressDetail': '101호',
      'addressGuide': '안내',
      'memberById': <String, dynamic>{},
      'waitingMemberById': <String, dynamic>{},
      'spaceOptions': <dynamic>[],
    });
  }

  /// user에 storeById 항목을 포함한 user 문서를 생성합니다.
  Future<void> _seedUserWithStore(
    FakeFirebaseFirestore firestore,
    String uid,
    String storeId,
  ) async {
    await firestore.collection('users').doc(uid).set(<String, dynamic>{
      'storeById': <String, dynamic>{
        storeId: <String, dynamic>{
          'name': '테스트 점포',
          'role': 'STAFF',
          'color': 'RED',
          'memo': '',
        },
      },
      'authProviders': <String>[],
    });
  }
  ```

- [ ] **Step 2: 컴파일 확인**

  ```bash
  dart analyze test/data/data_sources/store_data_source_test.dart
  ```
  Expected: No issues found.

---

## Task 2: approveMember 테스트 추가

**Files:**
- Modify: `test/data/data_sources/store_data_source_test.dart` (파일 끝 `}` 바로 앞에 추가)

- [ ] **Step 1: approveMember 테스트 그룹 작성**

  파일의 마지막 `}` 직전에 추가한다:

  ```dart
  // =========================================================================
  // approveMember
  // =========================================================================

  group('approveMember', () {
    test('승인 후 waitingMemberById에서 uid가 제거된다', () async {
      final storeId = FirestoreEmulatorHelper.generateId();
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedStoreWithWaitingMember(fakeFirestore, storeId, uid);
      final memberInfo = StoreMemberInfoModel(role: UserRole.staff);

      await dataSource.approveMember(storeId, uid, memberInfo);

      final doc = await fakeFirestore.collection('stores').doc(storeId).get();
      final waiting = doc.data()?['waitingMemberById'] as Map<String, dynamic>?;
      expect(waiting?.containsKey(uid), isFalse);
    });

    test('승인 후 memberById에 정확한 역할로 멤버가 추가된다', () async {
      final storeId = FirestoreEmulatorHelper.generateId();
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedStoreWithWaitingMember(fakeFirestore, storeId, uid);
      final memberInfo = StoreMemberInfoModel(role: UserRole.staff);

      await dataSource.approveMember(storeId, uid, memberInfo);

      final doc = await fakeFirestore.collection('stores').doc(storeId).get();
      final members = doc.data()?['memberById'] as Map<String, dynamic>?;
      expect(members?.containsKey(uid), isTrue);
      expect(members?[uid]['role'], 'STAFF');
    });
  });
  ```

- [ ] **Step 2: approveMember 테스트 실행**

  ```bash
  flutter test test/data/data_sources/store_data_source_test.dart --name "approveMember"
  ```
  Expected: 2/2 tests passed.

---

## Task 3: updateMemberRole 테스트 추가

**Files:**
- Modify: `test/data/data_sources/store_data_source_test.dart`

- [ ] **Step 1: updateMemberRole 테스트 그룹 작성**

  approveMember 그룹 아래에 추가한다:

  ```dart
  // =========================================================================
  // updateMemberRole
  // =========================================================================

  group('updateMemberRole', () {
    test('store의 memberById.$uid.role이 변경된다', () async {
      final storeId = FirestoreEmulatorHelper.generateId();
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedStoreWithMember(fakeFirestore, storeId, uid);
      await _seedUserWithStore(fakeFirestore, uid, storeId);

      await dataSource.updateMemberRole(storeId, uid, 'ADMIN');

      final doc = await fakeFirestore.collection('stores').doc(storeId).get();
      final members = doc.data()?['memberById'] as Map<String, dynamic>?;
      expect(members?[uid]['role'], 'ADMIN');
    });

    test('user의 storeById.$storeId.role이 변경된다', () async {
      final storeId = FirestoreEmulatorHelper.generateId();
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedStoreWithMember(fakeFirestore, storeId, uid);
      await _seedUserWithStore(fakeFirestore, uid, storeId);

      await dataSource.updateMemberRole(storeId, uid, 'ADMIN');

      final userDoc = await fakeFirestore.collection('users').doc(uid).get();
      final stores = userDoc.data()?['storeById'] as Map<String, dynamic>?;
      expect(stores?[storeId]['role'], 'ADMIN');
    });
  });
  ```

- [ ] **Step 2: updateMemberRole 테스트 실행**

  ```bash
  flutter test test/data/data_sources/store_data_source_test.dart --name "updateMemberRole"
  ```
  Expected: 2/2 tests passed.

---

## Task 4: removeMember 테스트 추가

**Files:**
- Modify: `test/data/data_sources/store_data_source_test.dart`

- [ ] **Step 1: removeMember 테스트 그룹 작성**

  updateMemberRole 그룹 아래에 추가한다:

  ```dart
  // =========================================================================
  // removeMember
  // =========================================================================

  group('removeMember', () {
    test('store의 memberById에서 uid가 제거된다', () async {
      final storeId = FirestoreEmulatorHelper.generateId();
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedStoreWithMember(fakeFirestore, storeId, uid);
      await _seedUserWithStore(fakeFirestore, uid, storeId);

      await dataSource.removeMember(storeId, uid);

      final doc = await fakeFirestore.collection('stores').doc(storeId).get();
      final members = doc.data()?['memberById'] as Map<String, dynamic>?;
      expect(members?.containsKey(uid), isFalse);
    });

    test('store의 waitingMemberById에서 uid가 제거된다', () async {
      final storeId = FirestoreEmulatorHelper.generateId();
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedStoreWithMember(fakeFirestore, storeId, uid);
      await _seedUserWithStore(fakeFirestore, uid, storeId);

      await dataSource.removeMember(storeId, uid);

      final doc = await fakeFirestore.collection('stores').doc(storeId).get();
      final waiting = doc.data()?['waitingMemberById'] as Map<String, dynamic>?;
      expect(waiting?.containsKey(uid), isFalse);
    });

    test('user의 storeById에서 storeId가 제거된다', () async {
      final storeId = FirestoreEmulatorHelper.generateId();
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedStoreWithMember(fakeFirestore, storeId, uid);
      await _seedUserWithStore(fakeFirestore, uid, storeId);

      await dataSource.removeMember(storeId, uid);

      final userDoc = await fakeFirestore.collection('users').doc(uid).get();
      final stores = userDoc.data()?['storeById'] as Map<String, dynamic>?;
      expect(stores?.containsKey(storeId), isFalse);
    });
  });
  ```

- [ ] **Step 2: removeMember 테스트 실행**

  ```bash
  flutter test test/data/data_sources/store_data_source_test.dart --name "removeMember"
  ```
  Expected: 3/3 tests passed.

---

## Task 5: requestJoinWithBatch 테스트 추가

**Files:**
- Modify: `test/data/data_sources/store_data_source_test.dart`

- [ ] **Step 1: requestJoinWithBatch 테스트 그룹 작성**

  removeMember 그룹 아래에 추가한다:

  ```dart
  // =========================================================================
  // requestJoinWithBatch
  // =========================================================================

  group('requestJoinWithBatch', () {
    test('store의 waitingMemberById에 신청자 정보가 저장된다', () async {
      final storeId = FirestoreEmulatorHelper.generateId();
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedEmptyStore(fakeFirestore, storeId);
      await _seedUserDoc(fakeFirestore, uid);
      final memberInfo = StoreMemberInfoModel(role: UserRole.staff);
      const userStoreInfo = UserStoreInfoModel(
        name: '테스트 점포',
        role: UserRole.staff,
        color: StoreColor.red,
        memo: '',
      );

      await dataSource.requestJoinWithBatch(storeId, uid, memberInfo, userStoreInfo);

      final doc = await fakeFirestore.collection('stores').doc(storeId).get();
      final waiting = doc.data()?['waitingMemberById'] as Map<String, dynamic>?;
      expect(waiting?.containsKey(uid), isTrue);
      expect(waiting?[uid]['role'], 'STAFF');
    });

    test('user의 storeById에 점포 정보가 저장된다', () async {
      final storeId = FirestoreEmulatorHelper.generateId();
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedEmptyStore(fakeFirestore, storeId);
      await _seedUserDoc(fakeFirestore, uid);
      final memberInfo = StoreMemberInfoModel(role: UserRole.staff);
      const userStoreInfo = UserStoreInfoModel(
        name: '테스트 점포',
        role: UserRole.staff,
        color: StoreColor.red,
        memo: '',
      );

      await dataSource.requestJoinWithBatch(storeId, uid, memberInfo, userStoreInfo);

      final userDoc = await fakeFirestore.collection('users').doc(uid).get();
      final stores = userDoc.data()?['storeById'] as Map<String, dynamic>?;
      expect(stores?.containsKey(storeId), isTrue);
      expect(stores?[storeId]['role'], 'STAFF');
    });
  });
  ```

- [ ] **Step 2: requestJoinWithBatch 테스트 실행**

  ```bash
  flutter test test/data/data_sources/store_data_source_test.dart --name "requestJoinWithBatch"
  ```
  Expected: 2/2 tests passed.

---

## Task 6: 전체 검증 및 커밋

**Files:**
- 변경 없음 (검증 단계)

- [ ] **Step 1: store_data_source 전체 테스트 실행**

  ```bash
  flutter test test/data/data_sources/store_data_source_test.dart
  ```
  Expected: 25/25 tests passed (기존 16 + 신규 9).

- [ ] **Step 2: 전체 테스트 회귀 확인**

  ```bash
  flutter test
  ```
  Expected: 164/164 tests passed (기존 155 + 신규 9). 회귀 없음.

- [ ] **Step 3: tasks.md 업데이트**

  `dev/active/firestore-emulator-tests/firestore-emulator-tests-tasks.md`의 **단기** 항목 4개를 체크 완료로 표시:

  ```markdown
  ### 단기 (선택)
  - [x] 멤버 관리 DataSource 테스트 추가
    - [x] `approveMember`: waitingMemberById → memberById 이동
    - [x] `updateMemberRole`: batch write (store + user)
    - [x] `removeMember`: batch delete (store + user)
    - [x] `requestJoinWithBatch`: 가입 신청 batch write
  ```

- [ ] **Step 4: 커밋**

  ```bash
  git add test/data/data_sources/store_data_source_test.dart \
          dev/active/firestore-emulator-tests/firestore-emulator-tests-tasks.md
  git commit -m "test: #<이슈번호> - 멤버 관리 DataSource 테스트 추가 (approveMember, updateMemberRole, removeMember, requestJoinWithBatch)"
  ```

---

## Self-Review

**Spec coverage 확인:**
- [x] approveMember: waiting → member 이동 검증 ✓
- [x] updateMemberRole: store + user 양쪽 role 업데이트 검증 ✓
- [x] removeMember: memberById, waitingMemberById, user.storeById 삭제 3가지 검증 ✓
- [x] requestJoinWithBatch: store.waitingMemberById + user.storeById 추가 검증 ✓

**Placeholder scan:** 없음. 모든 단계에 실제 코드 포함.

**Type consistency:**
- `StoreMemberInfoModel(role: UserRole.staff)` — Task 2~5 전부 일치
- `UserStoreInfoModel(name:, role:, color:, color:)` — Task 5 일치
- `fakeFirestore`, `dataSource` — setUp에서 초기화, 전 Task 일치
- `FirestoreEmulatorHelper.generateId()` — 전 Task 일치

**예상 결과**: 신규 9개 테스트, 전체 164개, 통과율 100%, production 코드 변경 없음.
