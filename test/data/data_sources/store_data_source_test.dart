import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/constants/data_constants.dart';
import 'package:studio_chance/data/data_sources/store_data_source.dart';
import 'package:studio_chance/data/models/space_option_model.dart';
import 'package:studio_chance/data/models/store_member_info_model.dart';
import 'package:studio_chance/data/models/store_model.dart';
import 'package:studio_chance/data/models/user_store_info_model.dart';
import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/common/enums/user_role.dart';

import '../../helpers/fake_firestore_helper.dart';
import '../../helpers/mocks.dart';

// Callable(lookupInviteCode·issueInviteCode·getServerTime)은 fake_cloud_firestore로
// 검증할 수 없다. 서버 동작은 functions/의 테스트가 지키고, 여기서는 FirebaseFunctions
// 목으로 요청·응답 변환만 확인한다.
// @Default({})와 @Default([])의 Freezed 기본값은 const {}와 const []로 생성되어
// 런타임 타입이 _Map<dynamic, dynamic>/_List<dynamic>입니다.
// fake_cloud_firestore가 이를 Map<String, dynamic>으로 캐스팅하면 TypeError가 발생하므로,
// 명시적으로 빈 컬렉션을 전달하여 _LinkedHashMap<String, T>/_GrowableList<T> 타입을 사용합니다.
StoreModel _testStore() => StoreModel(
  id: FakeFirestoreHelper.generateId(),
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
  late MockFirebaseFunctions mockFunctions;
  late StoreFirestoreDataSource dataSource;

  setUp(() {
    fakeFirestore = FakeFirestoreHelper.create();
    mockFunctions = MockFirebaseFunctions();
    dataSource = StoreFirestoreDataSource(fakeFirestore, mockFunctions);
  });

  /// [name] Callable이 [data]를 응답하게 하고 그 Callable 목을 돌려준다
  MockHttpsCallable stubCallable(String name, Object? data) {
    final callable = MockHttpsCallable();
    final result = MockHttpsCallableResult();
    when(() => result.data).thenReturn(data);
    when(() => callable.call<dynamic>(any())).thenAnswer((_) async => result);
    when(() => mockFunctions.httpsCallable(name)).thenReturn(callable);
    return callable;
  }

  // =========================================================================
  // createStore
  // =========================================================================

  group('createStore', () {
    test('점포 문서를 생성하고 Firestore 생성 ID가 반영된 모델을 반환한다', () async {
      final uid = FakeFirestoreHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);

      final result = await dataSource.createStore(
        _testStore(),
        uid,
        _creatorInfo,
      );

      expect(result.id, isNotEmpty);
      expect(result.name, '테스트 점포');
    });

    test('생성 후 users 컬렉션에 storeById 정보가 저장된다', () async {
      final uid = FakeFirestoreHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);

      final created = await dataSource.createStore(
        _testStore(),
        uid,
        _creatorInfo,
      );

      final userDoc = await fakeFirestore.collection('users').doc(uid).get();
      final storeById = userDoc.data()?['storeById'] as Map<String, dynamic>?;
      expect(storeById?.containsKey(created.id), true);
    });

    test('생성된 점포 문서를 Firestore에서 직접 조회할 수 있다', () async {
      final uid = FakeFirestoreHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);

      final created = await dataSource.createStore(
        _testStore(),
        uid,
        _creatorInfo,
      );

      final doc = await fakeFirestore
          .collection('stores')
          .doc(created.id)
          .get();
      expect(doc.exists, true);
      expect(doc.data()?['name'], '테스트 점포');
    });
  });

  // =========================================================================
  // getStore
  // =========================================================================

  group('getStore', () {
    test('존재하는 점포를 반환한다', () async {
      final uid = FakeFirestoreHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);
      final created = await dataSource.createStore(
        _testStore(),
        uid,
        _creatorInfo,
      );

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
      final storeId = FakeFirestoreHelper.generateId();
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
    bool unchanged(StoreModel _) => true;

    test('지정 필드를 업데이트한다', () async {
      final uid = FakeFirestoreHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);
      final created = await dataSource.createStore(
        _testStore(),
        uid,
        _creatorInfo,
      );

      await dataSource.updateStore(created.id, {
        'name': '변경된 점포명',
      }, isUnchanged: unchanged);

      final updated = await dataSource.getStore(created.id);
      expect(updated?.name, '변경된 점포명');
      // update가 set(덮어쓰기)으로 바뀌면 지정하지 않은 필드가 사라진다
      expect(updated?.address, '서울시 강남구 테헤란로 1');
      expect(updated?.addressDetail, '101호');
    });

    test('저장 직전 문서의 멤버·대기 멤버 storeById.name 캐시가 함께 갱신된다', () async {
      final storeId = FakeFirestoreHelper.generateId();
      final staffUid = FakeFirestoreHelper.generateId();
      await _seedUserWithStore(fakeFirestore, staffUid, storeId);
      await _seedStoreWithMember(fakeFirestore, storeId, staffUid);

      // 폼을 연 뒤 가입 신청이 들어와도 그 사용자의 캐시까지 갱신해야 한다
      final waitingUid = FakeFirestoreHelper.generateId();
      await _seedUserWithStore(fakeFirestore, waitingUid, storeId);
      await fakeFirestore.collection('stores').doc(storeId).update({
        'waitingMemberById.$waitingUid': <String, dynamic>{'role': 'STAFF'},
      });

      await dataSource.updateStore(storeId, {
        'name': '변경된 점포명',
      }, isUnchanged: unchanged);

      for (final uid in [staffUid, waitingUid]) {
        final userDoc = await fakeFirestore.collection('users').doc(uid).get();
        final storeById = userDoc.data()?['storeById'] as Map<String, dynamic>?;
        expect(storeById?[storeId]['name'], '변경된 점포명', reason: uid);
      }
    });

    test('사용자 문서에 그 점포 항목이 없으면 이름 캐시를 새로 만들지 않는다', () async {
      // 점포에는 대기 멤버로 남아 있지만 사용자 문서에서는 항목이 지워진 어긋난 상태.
      // 점 경로 update는 role 없는 {name} 항목을 만들어, 그 사용자 문서를 읽는
      // 점포 조회(멤버 hydrate)를 전부 실패하게 만든다
      final storeId = FakeFirestoreHelper.generateId();
      final waitingUid = FakeFirestoreHelper.generateId();
      await _seedUserDoc(fakeFirestore, waitingUid);
      await _seedStoreWithWaitingMember(fakeFirestore, storeId, waitingUid);

      await dataSource.updateStore(storeId, {
        'name': '변경된 점포명',
      }, isUnchanged: unchanged);

      final userDoc = await fakeFirestore
          .collection('users')
          .doc(waitingUid)
          .get();
      final storeById = userDoc.data()?['storeById'] as Map<String, dynamic>?;
      expect(storeById?.containsKey(storeId), isFalse);
      expect((await dataSource.getStore(storeId))?.name, '변경된 점포명');
    });

    test('data에 name이 없으면 멤버의 storeById.name을 건드리지 않는다', () async {
      final storeId = FakeFirestoreHelper.generateId();
      final staffUid = FakeFirestoreHelper.generateId();
      await _seedUserWithStore(fakeFirestore, staffUid, storeId);
      await _seedStoreWithMember(fakeFirestore, storeId, staffUid);

      await dataSource.updateStore(storeId, {
        'address': '변경된 주소',
      }, isUnchanged: unchanged);

      final staffDoc = await fakeFirestore
          .collection('users')
          .doc(staffUid)
          .get();
      final staffStoreById =
          staffDoc.data()?['storeById'] as Map<String, dynamic>?;
      expect(staffStoreById?[storeId]['name'], '테스트 점포');
    });

    test('isUnchanged에 저장 직전 문서를 넘기고, false면 충돌 예외를 던지고 쓰지 않는다', () async {
      final storeId = FakeFirestoreHelper.generateId();
      await _seedEmptyStore(fakeFirestore, storeId);
      await fakeFirestore.collection('stores').doc(storeId).update({
        'address': '다른 관리자가 바꾼 주소',
      });

      StoreModel? seen;
      await expectLater(
        dataSource.updateStore(
          storeId,
          {'name': '내가 바꾼 점포명'},
          isUnchanged: (current) {
            seen = current;
            return false;
          },
        ),
        throwsA(isA<StoreUpdateConflictException>()),
      );

      expect(seen?.address, '다른 관리자가 바꾼 주소');
      final current = await dataSource.getStore(storeId);
      expect(current?.name, '테스트 점포');
    });

    test('삭제된 점포를 수정하면 StoreNotFoundException을 던진다', () async {
      final storeId = FakeFirestoreHelper.generateId();
      await _seedEmptyStore(fakeFirestore, storeId);
      await fakeFirestore.collection('stores').doc(storeId).update({
        'deletedAt': Timestamp.now(),
      });

      await expectLater(
        dataSource.updateStore(storeId, {
          'name': '변경된 점포명',
        }, isUnchanged: unchanged),
        throwsA(isA<StoreNotFoundException>()),
      );
    });
  });

  // =========================================================================
  // softDeleteStore
  // =========================================================================

  group('softDeleteStore', () {
    test('softDelete 후 getStore가 null을 반환한다', () async {
      final uid = FakeFirestoreHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);
      final created = await dataSource.createStore(
        _testStore(),
        uid,
        _creatorInfo,
      );

      await dataSource.softDeleteStore(created.id, []);

      final result = await dataSource.getStore(created.id);
      expect(result, isNull);
    });

    test('softDelete 후 문서에 deletedAt 필드가 존재한다', () async {
      final uid = FakeFirestoreHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);
      final created = await dataSource.createStore(
        _testStore(),
        uid,
        _creatorInfo,
      );

      await dataSource.softDeleteStore(created.id, []);

      final doc = await fakeFirestore
          .collection('stores')
          .doc(created.id)
          .get();
      expect(doc.data()?.containsKey('deletedAt'), true);
    });

    test('softDelete 후 inviteInfo가 null이 된다', () async {
      final uid = FakeFirestoreHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);
      final created = await dataSource.createStore(
        _testStore(),
        uid,
        _creatorInfo,
      );
      // 발급은 서버가 하므로 발급된 모양을 직접 넣는다
      await fakeFirestore.collection('stores').doc(created.id).update({
        'inviteInfo': {'inviteCode': 'AB3D9F', 'createdAt': Timestamp.now()},
      });

      await dataSource.softDeleteStore(created.id, []);

      // lookupInviteCode Callable이 이 불변식에 기대어 조회한다.
      final doc = await fakeFirestore
          .collection('stores')
          .doc(created.id)
          .get();
      expect(doc.data()?['inviteInfo'], isNull);
    });

    test('전달된 memberUids의 storeById.{storeId} 캐시가 모두 삭제된다', () async {
      final storeId = FakeFirestoreHelper.generateId();
      final memberUid = FakeFirestoreHelper.generateId();
      final waitingUid = FakeFirestoreHelper.generateId();
      for (final uid in [memberUid, waitingUid]) {
        await fakeFirestore.collection('users').doc(uid).set(<String, dynamic>{
          'email': 'test@example.com',
          'name': '테스트 유저',
          'authProviders': <String>[],
          'storeById': <String, dynamic>{
            storeId: <String, dynamic>{
              'name': '테스트 점포',
              'role': 'STAFF',
              'color': 'RED',
              'memo': '',
            },
          },
        });
      }
      await fakeFirestore.collection('stores').doc(storeId).set(
        <String, dynamic>{
          'name': '테스트 점포',
          'address': '서울',
          'addressDetail': '',
          'addressGuide': '',
          'memberById': <String, dynamic>{},
          'waitingMemberById': <String, dynamic>{},
          'spaceOptions': <dynamic>[],
        },
      );

      await dataSource.softDeleteStore(storeId, [memberUid, waitingUid]);

      for (final uid in [memberUid, waitingUid]) {
        final doc = await fakeFirestore.collection('users').doc(uid).get();
        final storeById = doc.data()?['storeById'] as Map<String, dynamic>?;
        expect(storeById?.containsKey(storeId), isFalse);
      }
    });

    // expiresAt이 지나면 TTL이 점포를 지우고 cascadeStoreDelete가 예약을 지운다
    Future<DateTime> expiresAtAfterSoftDelete({
      required bool expireImmediately,
    }) async {
      final uid = FakeFirestoreHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);
      final created = await dataSource.createStore(
        _testStore(),
        uid,
        _creatorInfo,
      );

      await dataSource.softDeleteStore(
        created.id,
        [],
        expireImmediately: expireImmediately,
      );

      final doc = await fakeFirestore
          .collection('stores')
          .doc(created.id)
          .get();
      return (doc.data()!['expiresAt'] as Timestamp).toDate();
    }

    test('기본으로는 복구 여유 기간 뒤에 만료된다', () async {
      final before = DateTime.now();

      final expiresAt = await expiresAtAfterSoftDelete(
        expireImmediately: false,
      );

      expect(
        expiresAt.isAfter(
          before.add(const Duration(days: storeSoftDeleteDays - 1)),
        ),
        isTrue,
      );
    });

    test('expireImmediately면 바로 만료된다', () async {
      final expiresAt = await expiresAtAfterSoftDelete(expireImmediately: true);

      expect(expiresAt.isAfter(DateTime.now()), isFalse);
    });
  });

  // =========================================================================
  // createInviteCode (Callable issueInviteCode)
  // =========================================================================

  group('createInviteCode', () {
    test('점포 ID와 재발급 여부를 보내고 응답을 모델로 옮긴다', () async {
      final createdAt = DateTime(2026, 8, 29, 9, 10);
      final callable = stubCallable('issueInviteCode', {
        'inviteCode': 'AB3D9F',
        'createdAtMillis': createdAt.millisecondsSinceEpoch,
      });

      final invite = await dataSource.createInviteCode(
        'store-1',
        forceRegenerate: true,
      );

      expect(invite.inviteCode, 'AB3D9F');
      expect(invite.createdAt, createdAt);
      verify(
        () => callable.call<dynamic>({
          'storeId': 'store-1',
          'forceRegenerate': true,
        }),
      ).called(1);
    });

    test('Android가 돌려주는 Map<Object?, Object?> 응답도 읽는다', () async {
      stubCallable('issueInviteCode', <Object?, Object?>{
        'inviteCode': 'AB3D9F',
        'createdAtMillis': 0,
      });

      final invite = await dataSource.createInviteCode('store-1');

      expect(invite.inviteCode, 'AB3D9F');
    });

    test('서버가 권한 없음으로 거절하면 StorePermissionDeniedException', () async {
      final callable = MockHttpsCallable();
      when(() => callable.call<dynamic>(any())).thenThrow(
        FirebaseException(
          plugin: 'firebase_functions',
          code: 'permission-denied',
        ),
      );
      when(() => mockFunctions.httpsCallable('issueInviteCode'))
          .thenReturn(callable);

      expect(
        () => dataSource.createInviteCode('store-1'),
        throwsA(isA<StorePermissionDeniedException>()),
      );
    });
  });

  // =========================================================================
  // approveMember
  // =========================================================================

  group('approveMember', () {
    test('승인 후 waitingMemberById에서 uid가 제거된다', () async {
      final storeId = FakeFirestoreHelper.generateId();
      final uid = FakeFirestoreHelper.generateId();
      await _seedStoreWithWaitingMember(fakeFirestore, storeId, uid);
      await fakeFirestore.collection('users').doc(uid).set(<String, dynamic>{
        'email': 'test@example.com',
        'name': '테스트 유저',
        'authProviders': <String>[],
        'storeById': <String, dynamic>{
          storeId: <String, dynamic>{
            'name': '테스트 점포',
            'role': 'VIEWER',
            'color': 'RED',
            'memo': '',
          },
        },
      });
      final memberInfo = StoreMemberInfoModel(role: UserRole.staff);

      await dataSource.approveMember(storeId, uid, memberInfo);

      final doc = await fakeFirestore.collection('stores').doc(storeId).get();
      final waiting = doc.data()?['waitingMemberById'] as Map<String, dynamic>?;
      expect(waiting?.containsKey(uid), isFalse);
    });

    test('승인 후 memberById에 정확한 역할로 멤버가 추가된다', () async {
      final storeId = FakeFirestoreHelper.generateId();
      final uid = FakeFirestoreHelper.generateId();
      await _seedStoreWithWaitingMember(fakeFirestore, storeId, uid);
      await fakeFirestore.collection('users').doc(uid).set(<String, dynamic>{
        'email': 'test@example.com',
        'name': '테스트 유저',
        'authProviders': <String>[],
        'storeById': <String, dynamic>{
          storeId: <String, dynamic>{
            'name': '테스트 점포',
            'role': 'VIEWER',
            'color': 'RED',
            'memo': '',
          },
        },
      });
      final memberInfo = StoreMemberInfoModel(role: UserRole.staff);

      await dataSource.approveMember(storeId, uid, memberInfo);

      final doc = await fakeFirestore.collection('stores').doc(storeId).get();
      final members = doc.data()?['memberById'] as Map<String, dynamic>?;
      expect(members?.containsKey(uid), isTrue);
      expect(members?[uid]['role'], 'STAFF');
    });

    test('승인 후 users 컬렉션의 storeById.{storeId}.role도 동기화된다', () async {
      final storeId = FakeFirestoreHelper.generateId();
      final uid = FakeFirestoreHelper.generateId();
      await _seedStoreWithWaitingMember(fakeFirestore, storeId, uid);
      await fakeFirestore.collection('users').doc(uid).set(<String, dynamic>{
        'email': 'test@example.com',
        'name': '테스트 유저',
        'authProviders': <String>[],
        'storeById': <String, dynamic>{
          storeId: <String, dynamic>{
            'name': '테스트 점포',
            'role': 'VIEWER',
            'color': 'RED',
            'memo': '',
          },
        },
      });
      final memberInfo = StoreMemberInfoModel(role: UserRole.staff);

      await dataSource.approveMember(storeId, uid, memberInfo);

      final userDoc = await fakeFirestore.collection('users').doc(uid).get();
      final storeById = userDoc.data()?['storeById'] as Map<String, dynamic>?;
      expect(storeById?[storeId]['role'], 'STAFF');
    });
  });

  // =========================================================================
  // updateMemberRole
  // =========================================================================

  group('updateMemberRole', () {
    test(r'store의 memberById.$uid.role이 변경된다', () async {
      final storeId = FakeFirestoreHelper.generateId();
      final uid = FakeFirestoreHelper.generateId();
      await _seedStoreWithMember(fakeFirestore, storeId, uid);
      await _seedUserWithStore(fakeFirestore, uid, storeId);

      await dataSource.updateMemberRole(storeId, uid, 'ADMIN');

      final doc = await fakeFirestore.collection('stores').doc(storeId).get();
      final members = doc.data()?['memberById'] as Map<String, dynamic>?;
      expect(members?[uid]['role'], 'ADMIN');
    });

    test(r'user의 storeById.$storeId.role이 변경된다', () async {
      final storeId = FakeFirestoreHelper.generateId();
      final uid = FakeFirestoreHelper.generateId();
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
      final storeId = FakeFirestoreHelper.generateId();
      final uid = FakeFirestoreHelper.generateId();
      await _seedStoreWithMember(fakeFirestore, storeId, uid);
      await _seedUserWithStore(fakeFirestore, uid, storeId);

      await dataSource.removeMember(storeId, uid);

      final doc = await fakeFirestore.collection('stores').doc(storeId).get();
      final members = doc.data()?['memberById'] as Map<String, dynamic>?;
      expect(members?.containsKey(uid), isFalse);
    });

    test('store의 waitingMemberById에서 uid가 제거된다', () async {
      final storeId = FakeFirestoreHelper.generateId();
      final uid = FakeFirestoreHelper.generateId();
      await _seedStoreWithMember(fakeFirestore, storeId, uid);
      await _seedUserWithStore(fakeFirestore, uid, storeId);

      await dataSource.removeMember(storeId, uid);

      final doc = await fakeFirestore.collection('stores').doc(storeId).get();
      final waiting = doc.data()?['waitingMemberById'] as Map<String, dynamic>?;
      expect(waiting?.containsKey(uid), isFalse);
    });

    test('user의 storeById에서 storeId가 제거된다', () async {
      final storeId = FakeFirestoreHelper.generateId();
      final uid = FakeFirestoreHelper.generateId();
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
      final storeId = FakeFirestoreHelper.generateId();
      final uid = FakeFirestoreHelper.generateId();
      await _seedEmptyStore(fakeFirestore, storeId);
      await _seedUserDoc(fakeFirestore, uid);
      final memberInfo = StoreMemberInfoModel(role: UserRole.staff);
      const userStoreInfo = UserStoreInfoModel(
        name: '테스트 점포',
        role: UserRole.staff,
        color: StoreColor.red,
        memo: '',
      );

      await dataSource.requestJoinWithBatch(
        storeId,
        uid,
        memberInfo,
        userStoreInfo,
      );

      final doc = await fakeFirestore.collection('stores').doc(storeId).get();
      final waiting = doc.data()?['waitingMemberById'] as Map<String, dynamic>?;
      expect(waiting?.containsKey(uid), isTrue);
      expect(waiting?[uid]['role'], 'STAFF');
    });

    test('user의 storeById에 점포 정보가 저장된다', () async {
      final storeId = FakeFirestoreHelper.generateId();
      final uid = FakeFirestoreHelper.generateId();
      await _seedEmptyStore(fakeFirestore, storeId);
      await _seedUserDoc(fakeFirestore, uid);
      final memberInfo = StoreMemberInfoModel(role: UserRole.staff);
      const userStoreInfo = UserStoreInfoModel(
        name: '테스트 점포',
        role: UserRole.staff,
        color: StoreColor.red,
        memo: '',
      );

      await dataSource.requestJoinWithBatch(
        storeId,
        uid,
        memberInfo,
        userStoreInfo,
      );

      final userDoc = await fakeFirestore.collection('users').doc(uid).get();
      final stores = userDoc.data()?['storeById'] as Map<String, dynamic>?;
      expect(stores?.containsKey(storeId), isTrue);
      expect(stores?[storeId]['role'], 'STAFF');
    });
  });

  // =========================================================================
  // getServerTime (Callable getServerTime)
  // =========================================================================

  group('getServerTime', () {
    test('서버가 돌려준 시각을 DateTime으로 옮긴다', () async {
      final serverNow = DateTime(2026, 8, 29, 9, 10);
      stubCallable('getServerTime', <Object?, Object?>{
        'nowMillis': serverNow.millisecondsSinceEpoch,
      });

      expect(await dataSource.getServerTime(), serverNow);
    });
  });
}
