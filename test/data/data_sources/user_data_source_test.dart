import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/data/data_sources/user_data_source.dart';
import 'package:studio_chance/data/models/user_model.dart';
import 'package:studio_chance/data/models/user_store_info_model.dart';

import '../../helpers/firestore_emulator_helper.dart';

// @Default([])와 @Default({})의 Freezed 기본값은 const []와 const {}로 생성됩니다.
// 런타임 타입이 _List<dynamic>/_Map<dynamic, dynamic>이 되어 fake_cloud_firestore가
// Map<String, dynamic>으로 캐스팅할 때 TypeError가 발생할 수 있습니다.
// 명시적으로 빈 컬렉션을 전달하여 올바른 제네릭 타입을 사용합니다.
UserModel _testUser({String? id}) => UserModel(
  id: id ?? FirestoreEmulatorHelper.generateId(),
  email: 'test@example.com',
  name: '테스트 유저',
  nickname: '닉네임',
  authProviders: <String>[],
  storeById: <String, UserStoreInfoModel>{},
);

/// `users/{uid}/private/fcm` 서브문서의 tokens를 읽는다. 문서가 없으면 null.
Future<List<dynamic>?> _readFcmTokens(
  FakeFirebaseFirestore firestore,
  String uid,
) async {
  final doc = await firestore
      .collection('users')
      .doc(uid)
      .collection('private')
      .doc('fcm')
      .get();
  return doc.data()?['tokens'] as List<dynamic>?;
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late UserFirestoreDataSource dataSource;

  setUp(() {
    fakeFirestore = FirestoreEmulatorHelper.create();
    dataSource = UserFirestoreDataSource(fakeFirestore);
  });

  // =========================================================================
  // createUser
  // =========================================================================

  group('createUser', () {
    test('사용자 문서를 생성한다', () async {
      final user = _testUser();

      await dataSource.createUser(user);

      final doc = await fakeFirestore.collection('users').doc(user.id).get();
      expect(doc.exists, true);
      expect(doc.data()?['email'], user.email);
      expect(doc.data()?['name'], user.name);
      expect(doc.data()?['nickname'], user.nickname);
    });

    test('fcmToken을 전달하면 private/fcm 서브문서에 저장된다', () async {
      final user = _testUser();

      await dataSource.createUser(user, fcmToken: 'token-abc');

      final fcmDoc = await fakeFirestore
          .collection('users')
          .doc(user.id)
          .collection('private')
          .doc('fcm')
          .get();
      expect(fcmDoc.data()?['tokens'], ['token-abc']);
    });
  });

  // =========================================================================
  // getUser
  // =========================================================================

  group('getUser', () {
    test('존재하는 사용자를 반환한다', () async {
      final user = _testUser();
      await dataSource.createUser(user);

      final result = await dataSource.getUser(user.id);

      expect(result, isNotNull);
      expect(result!.id, user.id);
      expect(result.email, user.email);
      expect(result.nickname, user.nickname);
    });

    test('존재하지 않는 UID로 조회하면 null을 반환한다', () async {
      final result = await dataSource.getUser('nonexistent-uid');

      expect(result, isNull);
    });

    test('deletedAt이 있는 사용자는 null을 반환한다 (soft delete)', () async {
      final user = _testUser();
      await fakeFirestore.collection('users').doc(user.id).set({
        'email': user.email,
        'name': user.name,
        'deletedAt': Timestamp.now(),
      });

      final result = await dataSource.getUser(user.id);
      expect(result, isNull);
    });
  });

  // =========================================================================
  // updateUser
  // =========================================================================

  group('updateUser', () {
    test('일반 필드를 업데이트한다', () async {
      final user = _testUser();
      await dataSource.createUser(user);

      await dataSource.updateUser(user.id, {'nickname': '새닉네임'});

      final updated = await dataSource.getUser(user.id);
      expect(updated?.nickname, '새닉네임');
      // update가 set(덮어쓰기)으로 바뀌면 지정하지 않은 필드가 사라진다
      expect(updated?.email, user.email);
      expect(updated?.name, user.name);
    });
  });

  // =========================================================================
  // softDeleteUser
  // =========================================================================

  group('softDeleteUser', () {
    test('softDelete 후 getUser가 null을 반환한다', () async {
      final user = _testUser();
      await dataSource.createUser(user);

      await dataSource.softDeleteUser(user.id);

      final result = await dataSource.getUser(user.id);
      expect(result, isNull);
    });

    test('softDelete 후 문서에 deletedAt 필드가 존재한다', () async {
      final user = _testUser();
      await dataSource.createUser(user);

      await dataSource.softDeleteUser(user.id);

      final doc = await fakeFirestore.collection('users').doc(user.id).get();
      // FakeFirebaseFirestore에서 serverTimestamp는 현재 시각의 Timestamp로 저장됨
      expect(doc.data()?.containsKey('deletedAt'), true);
      expect(doc.data()?['deletedAt'], isNotNull);
    });

    test('softDelete 후 private/fcm 서브문서의 tokens가 빈 배열로 초기화된다', () async {
      final user = _testUser();
      await dataSource.createUser(user, fcmToken: 'token-1');

      await dataSource.softDeleteUser(user.id);

      final fcmDoc = await fakeFirestore
          .collection('users')
          .doc(user.id)
          .collection('private')
          .doc('fcm')
          .get();
      final tokens = fcmDoc.data()?['tokens'] as List<dynamic>?;
      expect(tokens, isEmpty);
    });
  });

  // =========================================================================
  // fetchUserWithRestoration
  // =========================================================================

  group('fetchUserWithRestoration', () {
    test('정상 사용자를 그대로 반환한다', () async {
      final user = _testUser();
      await dataSource.createUser(user);

      final result = await dataSource.fetchUserWithRestoration(user.id);

      expect(result, isNotNull);
      expect(result!.id, user.id);
      expect(result.email, user.email);
    });

    test('존재하지 않는 사용자는 null을 반환한다', () async {
      final result = await dataSource.fetchUserWithRestoration(
        'nonexistent-uid',
      );

      expect(result, isNull);
    });

    test('복구된 사용자는 갱신된 문서를 재조회하여 반환한다 (deletedAt/expiresAt 없이)', () async {
      final user = _testUser();
      await fakeFirestore.collection('users').doc(user.id).set({
        'email': user.email,
        'name': user.name,
        'nickname': user.nickname,
        'authProviders': <String>[],
        'storeById': <String, dynamic>{},
        'deletedAt': Timestamp.now(),
        'expiresAt': Timestamp.now(),
      });

      final result = await dataSource.fetchUserWithRestoration(user.id);

      // 재조회 결과이므로 로컬에서 임의로 지운 필드가 아니라
      // Firestore에 실제로 반영된 상태를 기반으로 파싱된 모델이어야 한다.
      final doc = await fakeFirestore.collection('users').doc(user.id).get();
      expect(doc.data()?.containsKey('deletedAt'), false);
      expect(doc.data()?.containsKey('expiresAt'), false);
      expect(result, isNotNull);
      expect(result!.id, user.id);
    });
  });

  // =========================================================================
  // restoreUser
  // =========================================================================

  group('restoreUser', () {
    test('deletedAt과 expiresAt 필드를 삭제한다', () async {
      final user = _testUser();
      await fakeFirestore.collection('users').doc(user.id).set({
        'email': user.email,
        'name': user.name,
        'authProviders': <String>[],
        'storeById': <String, dynamic>{},
        'deletedAt': Timestamp.now(),
        'expiresAt': Timestamp.now(),
      });

      await dataSource.restoreUser(user.id);

      final doc = await fakeFirestore.collection('users').doc(user.id).get();
      expect(doc.data()?.containsKey('deletedAt'), false);
      expect(doc.data()?.containsKey('expiresAt'), false);
    });
  });

  // =========================================================================
  // recordLogin
  // =========================================================================

  group('recordLogin', () {
    test('authProviders를 갱신하고 lastLoginAt을 기록한다', () async {
      final user = _testUser();
      await fakeFirestore.collection('users').doc(user.id).set({
        'email': user.email,
        'name': user.name,
        'authProviders': <String>['google.com'],
        'storeById': <String, dynamic>{},
      });

      await dataSource.recordLogin(
        user.id,
        authProviders: ['google.com', 'apple.com'],
      );

      final doc = await fakeFirestore.collection('users').doc(user.id).get();
      expect(doc.data()?['authProviders'], ['google.com', 'apple.com']);
      expect(doc.data()?['lastLoginAt'], isNotNull);
    });

    test('fcm 서브문서가 없는 첫 로그인 기기에서도 토큰이 저장된다', () async {
      final user = _testUser();
      await dataSource.createUser(user);

      await dataSource.recordLogin(
        user.id,
        authProviders: <String>[],
        fcmToken: 'token-new',
      );

      expect(await _readFcmTokens(fakeFirestore, user.id), ['token-new']);
    });

    test('다른 기기의 기존 토큰을 유지한 채 새 토큰을 추가한다', () async {
      final user = _testUser();
      await dataSource.createUser(user, fcmToken: 'token-other-device');

      await dataSource.recordLogin(
        user.id,
        authProviders: <String>[],
        fcmToken: 'token-new',
      );

      expect(await _readFcmTokens(fakeFirestore, user.id), [
        'token-other-device',
        'token-new',
      ]);
    });

    test('fcmToken이 없으면 fcm 서브문서를 만들지 않는다', () async {
      final user = _testUser();
      await dataSource.createUser(user);

      await dataSource.recordLogin(user.id, authProviders: <String>[]);

      expect(await _readFcmTokens(fakeFirestore, user.id), isNull);
    });
  });

  // =========================================================================
  // updateStoreInfo / removeStoreInfo
  // =========================================================================

  group('updateStoreInfo', () {
    test('지정한 키만 갱신하고 같은 점포의 나머지 정보는 유지한다', () async {
      final user = _testUser();
      await fakeFirestore.collection('users').doc(user.id).set({
        'email': user.email,
        'name': user.name,
        'authProviders': <String>[],
        'storeById': <String, dynamic>{
          'store-1': <String, dynamic>{
            'name': '테스트 점포',
            'role': 'ADMIN',
            'color': 'RED',
            'memo': '',
          },
        },
      });

      await dataSource.updateStoreInfo(user.id, 'store-1', {
        'color': 'BLUE',
        'memo': '새 메모',
      });

      final doc = await fakeFirestore.collection('users').doc(user.id).get();
      final storeInfo =
          (doc.data()?['storeById'] as Map<String, dynamic>)['store-1']
              as Map<String, dynamic>;
      expect(storeInfo['color'], 'BLUE');
      expect(storeInfo['memo'], '새 메모');
      expect(storeInfo['name'], '테스트 점포');
      expect(storeInfo['role'], 'ADMIN');
    });
  });

  group('removeStoreInfo', () {
    test('해당 점포 정보만 삭제하고 다른 점포 정보는 유지한다', () async {
      final user = _testUser();
      await fakeFirestore.collection('users').doc(user.id).set({
        'email': user.email,
        'name': user.name,
        'authProviders': <String>[],
        'storeById': <String, dynamic>{
          'store-1': <String, dynamic>{
            'name': '점포 1',
            'role': 'STAFF',
            'color': 'RED',
            'memo': '',
          },
          'store-2': <String, dynamic>{
            'name': '점포 2',
            'role': 'STAFF',
            'color': 'BLUE',
            'memo': '',
          },
        },
      });

      await dataSource.removeStoreInfo(user.id, 'store-1');

      final doc = await fakeFirestore.collection('users').doc(user.id).get();
      final storeById = doc.data()?['storeById'] as Map<String, dynamic>;
      expect(storeById.containsKey('store-1'), isFalse);
      expect(storeById.containsKey('store-2'), isTrue);
    });
  });

  // =========================================================================
  // addFcmToken
  // =========================================================================

  group('addFcmToken', () {
    test('fcm 서브문서가 없으면 새로 만들어 토큰을 저장한다', () async {
      final user = _testUser();
      await dataSource.createUser(user);

      await dataSource.addFcmToken(user.id, 'token-1');

      expect(await _readFcmTokens(fakeFirestore, user.id), ['token-1']);
    });

    test('기존 토큰을 유지한 채 새 토큰을 추가한다', () async {
      final user = _testUser();
      await dataSource.createUser(user, fcmToken: 'token-1');

      await dataSource.addFcmToken(user.id, 'token-2');

      expect(await _readFcmTokens(fakeFirestore, user.id), [
        'token-1',
        'token-2',
      ]);
    });

    test('이미 저장된 토큰은 중복으로 추가하지 않는다', () async {
      final user = _testUser();
      await dataSource.createUser(user, fcmToken: 'token-1');

      await dataSource.addFcmToken(user.id, 'token-1');

      expect(await _readFcmTokens(fakeFirestore, user.id), ['token-1']);
    });
  });

  // =========================================================================
  // replaceFcmToken
  // =========================================================================

  group('replaceFcmToken', () {
    test('기존 토큰을 새 토큰으로 교체하고 다른 기기 토큰은 유지한다', () async {
      final user = _testUser();
      await dataSource.createUser(user, fcmToken: 'token-other');
      await dataSource.addFcmToken(user.id, 'token-old');

      await dataSource.replaceFcmToken(user.id, 'token-old', 'token-new');

      final tokens = await _readFcmTokens(fakeFirestore, user.id);
      expect(tokens, containsAll(['token-other', 'token-new']));
      expect(tokens, isNot(contains('token-old')));
      expect(tokens, hasLength(2));
    });

    test('기존 토큰이 저장되어 있지 않아도 새 토큰을 추가한다', () async {
      final user = _testUser();
      await dataSource.createUser(user, fcmToken: 'token-other');

      await dataSource.replaceFcmToken(user.id, 'token-old', 'token-new');

      expect(await _readFcmTokens(fakeFirestore, user.id), [
        'token-other',
        'token-new',
      ]);
    });

    test('새 토큰이 이미 있으면 중복 없이 기존 토큰만 제거한다', () async {
      final user = _testUser();
      await dataSource.createUser(user, fcmToken: 'token-old');
      await dataSource.addFcmToken(user.id, 'token-new');

      await dataSource.replaceFcmToken(user.id, 'token-old', 'token-new');

      expect(await _readFcmTokens(fakeFirestore, user.id), ['token-new']);
    });

    test('fcm 서브문서가 없으면 새 토큰으로 문서를 만든다', () async {
      final user = _testUser();
      await dataSource.createUser(user);

      await dataSource.replaceFcmToken(user.id, 'token-old', 'token-new');

      expect(await _readFcmTokens(fakeFirestore, user.id), ['token-new']);
    });
  });

  // =========================================================================
  // removeFcmToken
  // =========================================================================

  group('removeFcmToken', () {
    test('지정한 토큰만 삭제하고 다른 기기 토큰은 유지한다', () async {
      final user = _testUser();
      await dataSource.createUser(user, fcmToken: 'token-1');
      await dataSource.addFcmToken(user.id, 'token-2');

      await dataSource.removeFcmToken(user.id, 'token-1');

      expect(await _readFcmTokens(fakeFirestore, user.id), ['token-2']);
    });

    test('fcm 서브문서가 없어도 예외 없이 완료된다', () async {
      final user = _testUser();
      await dataSource.createUser(user);

      await expectLater(
        dataSource.removeFcmToken(user.id, 'token-1'),
        completes,
      );
    });
  });
}
