import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/data/data_sources/store_data_source.dart';
import 'package:studio_chance/data/data_sources/user_data_source.dart';
import 'package:studio_chance/data/models/space_option_model.dart';
import 'package:studio_chance/data/models/store_member_info_model.dart';
import 'package:studio_chance/data/models/store_model.dart';
import 'package:studio_chance/data/repositories/store_repository_impl.dart';
import 'package:studio_chance/domain/entities/space_option.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/entities/store_member_info.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/enums/store_color.dart';
import 'package:studio_chance/domain/enums/user_role.dart';

import '../../helpers/firestore_emulator_helper.dart';

// Freezed @Default 타입 문제 회피: 명시적 타입 파라미터 사용
StoreModel _testStoreModel(String uid) => StoreModel(
      id: FirestoreEmulatorHelper.generateId(),
      name: '통합 테스트 점포',
      address: '서울시 강남구',
      addressDetail: '101호',
      addressGuide: '안내',
      memberById: <String, StoreMemberInfoModel>{
        uid: StoreMemberInfoModel(role: UserRole.admin),
      },
      waitingMemberById: <String, StoreMemberInfoModel>{},
      spaceOptions: <SpaceOptionModel>[],
    );

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

Future<void> _seedUserDoc(
  FakeFirebaseFirestore firestore,
  String uid,
) async {
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
    storeDataSource = StoreFirestoreDataSource(fakeFirestore);
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
      final storeById =
          userDoc.data()?['storeById'] as Map<String, dynamic>?;
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

      expect(first.getRight().toNullable()!.inviteCode,
          second.getRight().toNullable()!.inviteCode);
    });
  });

  // =========================================================================
  // getStoreByInviteCode
  // =========================================================================

  group('getStoreByInviteCode', () {
    test('유효한 초대 코드로 점포를 조회한다', () async {
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
      final invite = await repository.createInviteCode(storeId);
      final code = invite.getRight().toNullable()!.inviteCode;

      final result = await repository.getStoreByInviteCode(code);

      expect(result.isRight(), true);
      expect(result.getRight().toNullable()!.name, '통합 테스트 점포');
    });

    test('존재하지 않는 초대 코드는 right(null)을 반환한다', () async {
      final result = await repository.getStoreByInviteCode('XXXXXX');

      expect(result.isRight(), true);
      expect(result.getRight().toNullable(), isNull);
    });
  });

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
      final waiting =
          doc.data()?['waitingMemberById'] as Map<String, dynamic>?;
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
      final members =
          doc.data()?['memberById'] as Map<String, dynamic>?;
      expect(members?[memberUid]['role'], 'ADMIN');

      // getStore 호출 시 역직렬화가 성공해야 함
      final fetched = await repository.getStore(storeId);
      expect(fetched.isRight(), true,
          reason: 'updateMemberRole 후 getStore가 실패하면 role 직렬화 버그임');
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
