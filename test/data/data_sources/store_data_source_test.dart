import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/data/data_sources/store_data_source.dart';
import 'package:studio_chance/data/models/space_option_model.dart';
import 'package:studio_chance/data/models/store_member_info_model.dart';
import 'package:studio_chance/data/models/store_model.dart';
import 'package:studio_chance/data/models/user_store_info_model.dart';
import 'package:studio_chance/domain/enums/store_color.dart';
import 'package:studio_chance/domain/enums/user_role.dart';

import '../../helpers/firestore_emulator_helper.dart';

// @Default({})와 @Default([])의 Freezed 기본값은 const {}와 const []로 생성되어
// 런타임 타입이 _Map<dynamic, dynamic>/_List<dynamic>입니다.
// fake_cloud_firestore가 이를 Map<String, dynamic>으로 캐스팅하면 TypeError가 발생하므로,
// 명시적으로 빈 컬렉션을 전달하여 _LinkedHashMap<String, T>/_GrowableList<T> 타입을 사용합니다.
StoreModel _testStore() => StoreModel(
      id: FirestoreEmulatorHelper.generateId(),
      name: '테스트 점포',
      address: '서울시 강남구 테헤란로 1',
      addressDetail: '101호',
      addressGuide: '정문으로 오세요',
      memberById: <String, StoreMemberInfoModel>{},
      waitingMemberById: <String, StoreMemberInfoModel>{},
      spaceOptions: <SpaceOptionModel>[],
    );

const _creatorInfo = UserStoreInfoModel(
  name: '테스트 점포',
  role: UserRole.admin,
  color: StoreColor.blue,
  memo: '메모',
);

/// createStore는 batch.update(userRef)로 users 컬렉션을 참조하므로,
/// 사용자 문서를 먼저 생성해야 합니다.
///
/// fake_cloud_firestore는 map literal `{}`을 `_Map<dynamic, dynamic>`으로 처리하여
/// `Map<String, dynamic>` 캐스팅 시 TypeError가 발생합니다.
/// 명시적 타입 파라미터를 사용합니다.
Future<void> _seedUserDoc(FakeFirebaseFirestore firestore, String uid) async {
  await firestore.collection('users').doc(uid).set(<String, dynamic>{
    'email': 'test@example.com',
    'name': '테스트 유저',
    'storeById': <String, dynamic>{},
    'authProviders': <String>[],
  });
}

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

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late StoreFirestoreDataSource dataSource;

  setUp(() {
    fakeFirestore = FirestoreEmulatorHelper.create();
    dataSource = StoreFirestoreDataSource(fakeFirestore);
  });

  // =========================================================================
  // createStore
  // =========================================================================

  group('createStore', () {
    test('점포 문서를 생성하고 Firestore 생성 ID가 반영된 모델을 반환한다', () async {
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);

      final result = await dataSource.createStore(_testStore(), uid, _creatorInfo);

      expect(result.id, isNotEmpty);
      expect(result.name, '테스트 점포');
    });

    test('생성 후 users 컬렉션에 storeById 정보가 저장된다', () async {
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);

      final created = await dataSource.createStore(_testStore(), uid, _creatorInfo);

      final userDoc = await fakeFirestore.collection('users').doc(uid).get();
      final storeById = userDoc.data()?['storeById'] as Map<String, dynamic>?;
      expect(storeById?.containsKey(created.id), true);
    });

    test('생성된 점포 문서를 Firestore에서 직접 조회할 수 있다', () async {
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);

      final created = await dataSource.createStore(_testStore(), uid, _creatorInfo);

      final doc = await fakeFirestore.collection('stores').doc(created.id).get();
      expect(doc.exists, true);
      expect(doc.data()?['name'], '테스트 점포');
    });
  });

  // =========================================================================
  // getStore
  // =========================================================================

  group('getStore', () {
    test('존재하는 점포를 반환한다', () async {
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);
      final created = await dataSource.createStore(_testStore(), uid, _creatorInfo);

      final result = await dataSource.getStore(created.id);

      expect(result, isNotNull);
      expect(result!.name, '테스트 점포');
      expect(result.address, '서울시 강남구 테헤란로 1');
    });

    test('존재하지 않는 ID로 조회하면 null을 반환한다', () async {
      final result = await dataSource.getStore('nonexistent-store-id');

      expect(result, isNull);
    });

    test('deletedAt이 있는 점포는 null을 반환한다 (soft delete)', () async {
      final storeId = FirestoreEmulatorHelper.generateId();
      await fakeFirestore.collection('stores').doc(storeId).set({
        'name': '삭제된 점포',
        'address': '주소',
        'addressDetail': '상세',
        'addressGuide': '안내',
        'memberById': {},
        'deletedAt': Timestamp.now(),
      });

      final result = await dataSource.getStore(storeId);
      expect(result, isNull);
    });
  });

  // =========================================================================
  // updateStore
  // =========================================================================

  group('updateStore', () {
    test('지정 필드를 업데이트한다', () async {
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);
      final created = await dataSource.createStore(_testStore(), uid, _creatorInfo);

      await dataSource.updateStore(created.id, {'name': '변경된 점포명'}, []);

      final updated = await dataSource.getStore(created.id);
      expect(updated?.name, '변경된 점포명');
    });

    test('업데이트 후 기존 필드는 변경되지 않는다', () async {
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);
      final created = await dataSource.createStore(_testStore(), uid, _creatorInfo);

      await dataSource.updateStore(created.id, {'name': '변경된 점포명'}, []);

      final updated = await dataSource.getStore(created.id);
      expect(updated?.address, '서울시 강남구 테헤란로 1');
      expect(updated?.addressDetail, '101호');
    });

    test('memberUids로 전달된 유저들의 storeById.name 캐시가 함께 갱신된다', () async {
      final storeId = FirestoreEmulatorHelper.generateId();
      final adminUid = FirestoreEmulatorHelper.generateId();
      final staffUid = FirestoreEmulatorHelper.generateId();
      await _seedUserWithStore(fakeFirestore, adminUid, storeId);
      await _seedUserWithStore(fakeFirestore, staffUid, storeId);
      await _seedStoreWithMember(fakeFirestore, storeId, staffUid);

      await dataSource.updateStore(
        storeId,
        {'name': '변경된 점포명'},
        [adminUid, staffUid],
      );

      final adminDoc = await fakeFirestore.collection('users').doc(adminUid).get();
      final staffDoc = await fakeFirestore.collection('users').doc(staffUid).get();
      final adminStoreById = adminDoc.data()?['storeById'] as Map<String, dynamic>?;
      final staffStoreById = staffDoc.data()?['storeById'] as Map<String, dynamic>?;
      expect(adminStoreById?[storeId]['name'], '변경된 점포명');
      expect(staffStoreById?[storeId]['name'], '변경된 점포명');
    });

    test('data에 name이 없으면 memberUids의 storeById.name을 건드리지 않는다', () async {
      final storeId = FirestoreEmulatorHelper.generateId();
      final staffUid = FirestoreEmulatorHelper.generateId();
      await _seedUserWithStore(fakeFirestore, staffUid, storeId);
      await _seedStoreWithMember(fakeFirestore, storeId, staffUid);

      await dataSource.updateStore(
        storeId,
        {'address': '변경된 주소'},
        [staffUid],
      );

      final staffDoc = await fakeFirestore.collection('users').doc(staffUid).get();
      final staffStoreById = staffDoc.data()?['storeById'] as Map<String, dynamic>?;
      expect(staffStoreById?[storeId]['name'], '테스트 점포');
    });
  });

  // =========================================================================
  // softDeleteStore
  // =========================================================================

  group('softDeleteStore', () {
    test('softDelete 후 getStore가 null을 반환한다', () async {
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);
      final created = await dataSource.createStore(_testStore(), uid, _creatorInfo);

      await dataSource.softDeleteStore(created.id);

      final result = await dataSource.getStore(created.id);
      expect(result, isNull);
    });

    test('softDelete 후 문서에 deletedAt 필드가 존재한다', () async {
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);
      final created = await dataSource.createStore(_testStore(), uid, _creatorInfo);

      await dataSource.softDeleteStore(created.id);

      final doc = await fakeFirestore.collection('stores').doc(created.id).get();
      expect(doc.data()?.containsKey('deletedAt'), true);
    });
  });

  // =========================================================================
  // createInviteCode & getInviteInfo
  // =========================================================================

  group('createInviteCode / getInviteInfo', () {
    test('초대 코드를 생성하고 6자리 코드를 반환한다', () async {
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);
      final created = await dataSource.createStore(_testStore(), uid, _creatorInfo);

      final inviteInfo = await dataSource.createInviteCode(created.id);

      expect(inviteInfo.inviteCode, isNotEmpty);
      expect(inviteInfo.inviteCode.length, 6);
    });

    test('getInviteInfo는 저장된 초대 코드를 반환한다', () async {
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);
      final created = await dataSource.createStore(_testStore(), uid, _creatorInfo);
      final createdInvite = await dataSource.createInviteCode(created.id);

      final fetched = await dataSource.getInviteInfo(created.id);

      expect(fetched, isNotNull);
      expect(fetched!.inviteCode, createdInvite.inviteCode);
    });

    test('초대 코드가 없으면 null을 반환한다', () async {
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);
      final created = await dataSource.createStore(_testStore(), uid, _creatorInfo);

      final result = await dataSource.getInviteInfo(created.id);
      expect(result, isNull);
    });
  });

  // =========================================================================
  // getStoreByInviteCode
  // =========================================================================

  group('getStoreByInviteCode', () {
    test('초대 코드로 점포를 조회한다', () async {
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);
      final created = await dataSource.createStore(_testStore(), uid, _creatorInfo);
      final invite = await dataSource.createInviteCode(created.id);

      final result = await dataSource.getStoreByInviteCode(invite.inviteCode);

      expect(result, isNotNull);
      expect(result!.name, '테스트 점포');
    });

    test('존재하지 않는 초대 코드로 조회하면 null을 반환한다', () async {
      final result = await dataSource.getStoreByInviteCode('NOTFND');

      expect(result, isNull);
    });

    test('soft delete된 점포는 초대 코드 조회에서 제외된다', () async {
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);
      final created = await dataSource.createStore(_testStore(), uid, _creatorInfo);
      final invite = await dataSource.createInviteCode(created.id);
      await dataSource.softDeleteStore(created.id);

      final result = await dataSource.getStoreByInviteCode(invite.inviteCode);

      // softDeleteStore는 inviteInfo를 null로 초기화하므로,
      // 코드가 삭제되어 조회 불가
      expect(result, isNull);
    });
  });

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

  // =========================================================================
  // updateMemberRole
  // =========================================================================

  group('updateMemberRole', () {
    test(r'store의 memberById.$uid.role이 변경된다', () async {
      final storeId = FirestoreEmulatorHelper.generateId();
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedStoreWithMember(fakeFirestore, storeId, uid);
      await _seedUserWithStore(fakeFirestore, uid, storeId);

      await dataSource.updateMemberRole(storeId, uid, 'ADMIN');

      final doc = await fakeFirestore.collection('stores').doc(storeId).get();
      final members = doc.data()?['memberById'] as Map<String, dynamic>?;
      expect(members?[uid]['role'], 'ADMIN');
    });

    test(r'user의 storeById.$storeId.role이 변경된다', () async {
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
}
