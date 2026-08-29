import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/data/data_sources/store_data_source.dart';
import 'package:studio_chance/data/data_sources/user_data_source.dart';
import 'package:studio_chance/data/repositories/store_repository_impl.dart';
import 'package:studio_chance/domain/entities/space_option.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/entities/store_member_info.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/common/enums/user_role.dart';

import '../../helpers/firestore_emulator_helper.dart';

// lookupInviteCode는 Callable(FirebaseFunctions)이라 fake_cloud_firestore로
// 검증할 수 없다. 이 파일의 테스트는 이를 호출하지 않으므로 목은 생성자
// 파라미터를 채우는 용도로만 쓰인다.
class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

Store _testStoreEntity(String uid, User adminUser) => Store(
  id: '',
  name: '통합 테스트 점포',
  address: '서울시 강남구',
  addressDetail: '101호',
  addressGuide: '안내',
  memberInfos: [StoreMemberInfo(user: adminUser, role: UserRole.admin)],
  waitingMemberInfos: [],
  spaceOptions: [SpaceOption.empty()],
  inviteInfo: null,
);

Future<void> _seedUserDoc(FakeFirebaseFirestore firestore, String uid) async {
  await firestore.collection('users').doc(uid).set(<String, dynamic>{
    'email': 'test@example.com',
    'name': '테스트 유저',
    'storeById': <String, dynamic>{},
    'authProviders': <String>[],
  });
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late StoreRepositoryImpl repository;
  late StoreFirestoreDataSource storeDataSource;
  late UserFirestoreDataSource userDataSource;

  setUp(() {
    fakeFirestore = FirestoreEmulatorHelper.create();
    storeDataSource = StoreFirestoreDataSource(
      fakeFirestore,
      MockFirebaseFunctions(),
    );
    userDataSource = UserFirestoreDataSource(fakeFirestore);
    repository = StoreRepositoryImpl(
      storeDataSource: storeDataSource,
      userDataSource: userDataSource,
    );
  });

  // =========================================================================
  // createStore + getStore
  // =========================================================================

  group('createStore + getStore', () {
    test('createStore 후 getStore가 점포를 반환한다', () async {
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);
      final adminUser = User(
        id: uid,
        name: '테스트 유저',
        email: 'test@example.com',
        nickname: null,
        authProviders: [],
        storeInfos: [],
      );
      final storeEntity = _testStoreEntity(uid, adminUser);

      final created = await repository.createStore(
        store: storeEntity,
        color: StoreColor.blue,
        memo: '관리자 메모',
      );

      expect(created.isRight(), true);
      final storeId = created.getRight().toNullable()!.id;

      final fetched = await repository.getStore(storeId);

      expect(fetched.isRight(), true);
      expect(fetched.getRight().toNullable(), isNotNull);
      expect(fetched.getRight().toNullable()!.name, '통합 테스트 점포');
    });

    test('getStore memberInfos가 users 컬렉션에서 hydrate된다', () async {
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);
      final adminUser = User(
        id: uid,
        name: '테스트 유저',
        email: 'test@example.com',
        nickname: null,
        authProviders: [],
        storeInfos: [],
      );

      final created = await repository.createStore(
        store: _testStoreEntity(uid, adminUser),
        color: StoreColor.blue,
        memo: '',
      );
      final storeId = created.getRight().toNullable()!.id;

      final fetched = await repository.getStore(storeId);

      final store = fetched.getRight().toNullable()!;
      expect(store.memberInfos.length, 1);
      expect(store.memberInfos.first.user.id, uid);
      expect(store.memberInfos.first.role, UserRole.admin);
    });
  });

  // =========================================================================
  // legacy fallback (spaceOptions 없는 구버전 점포)
  // =========================================================================

  group('legacy spaceOptions fallback', () {
    test('spaceOptions가 없는 점포를 조회하면 legacy_default 공간 하나로 채워진다', () async {
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);
      // spaceOptions 필드 자체가 없던 구버전 문서를 직접 시뮬레이션
      final storeId = FirestoreEmulatorHelper.generateId();
      await fakeFirestore.collection('stores').doc(storeId).set(
        <String, dynamic>{
          'name': '레거시 점포',
          'address': '서울',
          'addressDetail': '',
          'addressGuide': '',
          'memberById': <String, dynamic>{
            uid: <String, dynamic>{'role': 'ADMIN'},
          },
          'waitingMemberById': <String, dynamic>{},
          'spaceOptions': <dynamic>[],
        },
      );

      final fetched = await repository.getStore(storeId);

      final store = fetched.getRight().toNullable()!;
      expect(store.spaceOptions.length, 1);
      expect(store.spaceOptions.first.id, 'legacy_default');
      expect(store.spaceOptions.first.name, '기본 공간');
    });
  });

  // =========================================================================
  // updateStore
  // =========================================================================

  group('updateStore', () {
    test('updateStore 후 점포 이름이 변경된다', () async {
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);
      final adminUser = User(
        id: uid,
        name: '테스트 유저',
        email: 'test@example.com',
        nickname: null,
        authProviders: [],
        storeInfos: [],
      );

      final created = await repository.createStore(
        store: _testStoreEntity(uid, adminUser),
        color: StoreColor.blue,
        memo: '',
      );
      final createdStore = created.getRight().toNullable()!;

      await repository.updateStore(
        store: createdStore.copyWith(name: '변경된 점포명'),
        uid: uid,
        color: StoreColor.green,
        memo: '새 메모',
      );

      final fetched = await repository.getStore(createdStore.id);
      expect(fetched.getRight().toNullable()!.name, '변경된 점포명');
    });

    test('점포명 변경 시 다른 멤버(staff)의 storeById.name 캐시도 함께 갱신된다', () async {
      final ownerUid = FirestoreEmulatorHelper.generateId();
      final staffUid = FirestoreEmulatorHelper.generateId();
      await _seedUserDoc(fakeFirestore, ownerUid);
      await _seedUserDoc(fakeFirestore, staffUid);
      final adminUser = User(
        id: ownerUid,
        name: '테스트 유저',
        email: 'test@example.com',
        nickname: null,
        authProviders: [],
        storeInfos: [],
      );

      final created = await repository.createStore(
        store: _testStoreEntity(ownerUid, adminUser),
        color: StoreColor.blue,
        memo: '',
      );
      final createdStore = created.getRight().toNullable()!;

      await repository.requestJoinStore(
        storeId: createdStore.id,
        uid: staffUid,
        role: UserRole.staff,
        color: StoreColor.red,
        storeAlias: '통합 테스트 점포',
        memo: '',
      );
      await repository.approveMember(
        storeId: createdStore.id,
        uid: staffUid,
        role: UserRole.staff,
      );

      final fetched = await repository.getStore(createdStore.id);
      final storeWithStaff = fetched.getRight().toNullable()!;

      await repository.updateStore(
        store: storeWithStaff.copyWith(name: '변경된 점포명'),
        uid: ownerUid,
        color: StoreColor.green,
        memo: '',
      );

      final staffDoc = await fakeFirestore
          .collection('users')
          .doc(staffUid)
          .get();
      final staffStoreById =
          staffDoc.data()?['storeById'] as Map<String, dynamic>?;
      expect(staffStoreById?[createdStore.id]['name'], '변경된 점포명');
    });

    test('updateStore 후 users 컬렉션의 storeById에 color, memo가 반영된다', () async {
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);
      final adminUser = User(
        id: uid,
        name: '테스트 유저',
        email: 'test@example.com',
        nickname: null,
        authProviders: [],
        storeInfos: [],
      );

      final created = await repository.createStore(
        store: _testStoreEntity(uid, adminUser),
        color: StoreColor.blue,
        memo: '',
      );
      final createdStore = created.getRight().toNullable()!;

      await repository.updateStore(
        store: createdStore,
        uid: uid,
        color: StoreColor.red,
        memo: '변경된 메모',
      );

      final userDoc = await fakeFirestore.collection('users').doc(uid).get();
      final storeById = userDoc.data()?['storeById'] as Map<String, dynamic>?;
      expect(storeById?[createdStore.id]['color'], 'RED');
      expect(storeById?[createdStore.id]['memo'], '변경된 메모');
    });
  });

  // =========================================================================
  // softDeleteStore
  // =========================================================================

  group('softDeleteStore', () {
    test('softDeleteStore 후 getStore가 null을 반환한다', () async {
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);
      final adminUser = User(
        id: uid,
        name: '테스트 유저',
        email: 'test@example.com',
        nickname: null,
        authProviders: [],
        storeInfos: [],
      );

      final created = await repository.createStore(
        store: _testStoreEntity(uid, adminUser),
        color: StoreColor.blue,
        memo: '',
      );
      final storeId = created.getRight().toNullable()!.id;

      await repository.softDeleteStore(storeId);

      final fetched = await repository.getStore(storeId);
      expect(fetched.isRight(), true);
      expect(fetched.getRight().toNullable(), isNull);
    });

    test('softDeleteStore 후 멤버(staff)의 storeById 캐시도 제거된다', () async {
      final ownerUid = FirestoreEmulatorHelper.generateId();
      final staffUid = FirestoreEmulatorHelper.generateId();
      await _seedUserDoc(fakeFirestore, ownerUid);
      await _seedUserDoc(fakeFirestore, staffUid);
      final adminUser = User(
        id: ownerUid,
        name: '테스트 유저',
        email: 'test@example.com',
        nickname: null,
        authProviders: [],
        storeInfos: [],
      );
      final created = await repository.createStore(
        store: _testStoreEntity(ownerUid, adminUser),
        color: StoreColor.blue,
        memo: '',
      );
      final storeId = created.getRight().toNullable()!.id;

      await repository.requestJoinStore(
        storeId: storeId,
        uid: staffUid,
        role: UserRole.staff,
        color: StoreColor.red,
        storeAlias: '통합 테스트 점포',
        memo: '',
      );
      await repository.approveMember(
        storeId: storeId,
        uid: staffUid,
        role: UserRole.staff,
      );

      await repository.softDeleteStore(storeId);

      final ownerDoc = await fakeFirestore
          .collection('users')
          .doc(ownerUid)
          .get();
      final staffDoc = await fakeFirestore
          .collection('users')
          .doc(staffUid)
          .get();
      final ownerStoreById =
          ownerDoc.data()?['storeById'] as Map<String, dynamic>?;
      final staffStoreById =
          staffDoc.data()?['storeById'] as Map<String, dynamic>?;
      expect(ownerStoreById?.containsKey(storeId), isFalse);
      expect(staffStoreById?.containsKey(storeId), isFalse);
    });
  });

  // =========================================================================
  // createInviteCode
  // =========================================================================

  group('createInviteCode', () {
    test('초대 코드를 생성하고 6자리 코드를 반환한다', () async {
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);
      final adminUser = User(
        id: uid,
        name: '테스트 유저',
        email: 'test@example.com',
        nickname: null,
        authProviders: [],
        storeInfos: [],
      );
      final created = await repository.createStore(
        store: _testStoreEntity(uid, adminUser),
        color: StoreColor.blue,
        memo: '',
      );
      final storeId = created.getRight().toNullable()!.id;

      final result = await repository.createInviteCode(storeId);

      expect(result.isRight(), true);
      expect(result.getRight().toNullable()!.inviteCode.length, 6);
    });

    test('유효 시간 내 재호출 시 동일한 코드를 재사용한다', () async {
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);
      final adminUser = User(
        id: uid,
        name: '테스트 유저',
        email: 'test@example.com',
        nickname: null,
        authProviders: [],
        storeInfos: [],
      );
      final created = await repository.createStore(
        store: _testStoreEntity(uid, adminUser),
        color: StoreColor.blue,
        memo: '',
      );
      final storeId = created.getRight().toNullable()!.id;

      final first = await repository.createInviteCode(storeId);
      final second = await repository.createInviteCode(storeId);

      expect(
        first.getRight().toNullable()!.inviteCode,
        second.getRight().toNullable()!.inviteCode,
      );
    });
  });

  // getStoreByInviteCode: lookupInviteCode Callable(functions/src/invite/)로
  // 옮겨간 서버 책임이라 fake_cloud_firestore로는 더 이상 검증할 수 없다.
  // (store_data_source_test.dart와 동일한 원칙 — Task 8)

  // =========================================================================
  // requestJoinStore + approveMember
  // =========================================================================

  group('requestJoinStore + approveMember', () {
    test('requestJoinStore 후 waitingMemberInfos에 신청자가 추가된다', () async {
      final ownerUid = FirestoreEmulatorHelper.generateId();
      final memberUid = FirestoreEmulatorHelper.generateId();
      await _seedUserDoc(fakeFirestore, ownerUid);
      await _seedUserDoc(fakeFirestore, memberUid);
      final adminUser = User(
        id: ownerUid,
        name: '테스트 유저',
        email: 'test@example.com',
        nickname: null,
        authProviders: [],
        storeInfos: [],
      );
      final created = await repository.createStore(
        store: _testStoreEntity(ownerUid, adminUser),
        color: StoreColor.blue,
        memo: '',
      );
      final storeId = created.getRight().toNullable()!.id;

      await repository.requestJoinStore(
        storeId: storeId,
        uid: memberUid,
        role: UserRole.staff,
        color: StoreColor.red,
        storeAlias: '통합 테스트 점포',
        memo: '',
      );

      final doc = await fakeFirestore.collection('stores').doc(storeId).get();
      final waiting = doc.data()?['waitingMemberById'] as Map<String, dynamic>?;
      expect(waiting?.containsKey(memberUid), isTrue);
    });

    test('approveMember 후 getStore memberInfos에 승인된 멤버가 포함된다', () async {
      final ownerUid = FirestoreEmulatorHelper.generateId();
      final memberUid = FirestoreEmulatorHelper.generateId();
      await _seedUserDoc(fakeFirestore, ownerUid);
      await _seedUserDoc(fakeFirestore, memberUid);
      final adminUser = User(
        id: ownerUid,
        name: '테스트 유저',
        email: 'test@example.com',
        nickname: null,
        authProviders: [],
        storeInfos: [],
      );
      final created = await repository.createStore(
        store: _testStoreEntity(ownerUid, adminUser),
        color: StoreColor.blue,
        memo: '',
      );
      final storeId = created.getRight().toNullable()!.id;

      await repository.requestJoinStore(
        storeId: storeId,
        uid: memberUid,
        role: UserRole.staff,
        color: StoreColor.red,
        storeAlias: '통합 테스트 점포',
        memo: '',
      );
      await repository.approveMember(
        storeId: storeId,
        uid: memberUid,
        role: UserRole.staff,
      );

      final fetched = await repository.getStore(storeId);
      final store = fetched.getRight().toNullable()!;
      final memberIds = store.memberInfos.map((m) => m.user.id).toList();
      expect(memberIds.contains(memberUid), isTrue);

      final memberUserDoc = await fakeFirestore
          .collection('users')
          .doc(memberUid)
          .get();
      final memberStoreById =
          memberUserDoc.data()?['storeById'] as Map<String, dynamic>?;
      expect(memberStoreById?[storeId]['role'], 'STAFF');
    });
  });

  // =========================================================================
  // updateMemberRole
  // =========================================================================

  group('updateMemberRole', () {
    test('store와 user의 role이 올바른 JSON 값으로 업데이트된다', () async {
      final ownerUid = FirestoreEmulatorHelper.generateId();
      final memberUid = FirestoreEmulatorHelper.generateId();
      await _seedUserDoc(fakeFirestore, ownerUid);
      await _seedUserDoc(fakeFirestore, memberUid);
      final adminUser = User(
        id: ownerUid,
        name: '테스트 유저',
        email: 'test@example.com',
        nickname: null,
        authProviders: [],
        storeInfos: [],
      );
      final created = await repository.createStore(
        store: _testStoreEntity(ownerUid, adminUser),
        color: StoreColor.blue,
        memo: '',
      );
      final storeId = created.getRight().toNullable()!.id;

      // 멤버 추가: requestJoin → approve
      await repository.requestJoinStore(
        storeId: storeId,
        uid: memberUid,
        role: UserRole.staff,
        color: StoreColor.red,
        storeAlias: '통합 테스트 점포',
        memo: '',
      );
      await repository.approveMember(
        storeId: storeId,
        uid: memberUid,
        role: UserRole.staff,
      );

      await repository.updateMemberRole(
        storeId: storeId,
        uid: memberUid,
        newRole: UserRole.admin,
      );

      // Firestore에 저장된 값이 JSON 직렬화 형식('ADMIN')인지 확인
      final doc = await fakeFirestore.collection('stores').doc(storeId).get();
      final members = doc.data()?['memberById'] as Map<String, dynamic>?;
      expect(members?[memberUid]['role'], 'ADMIN');

      // getStore 호출 시 역직렬화가 성공해야 함
      final fetched = await repository.getStore(storeId);
      expect(
        fetched.isRight(),
        true,
        reason: 'updateMemberRole 후 getStore가 실패하면 role 직렬화 버그임',
      );
      final updatedMember = fetched
          .getRight()
          .toNullable()!
          .memberInfos
          .where((m) => m.user.id == memberUid)
          .firstOrNull;
      expect(updatedMember?.role, UserRole.admin);
    });
  });
}
