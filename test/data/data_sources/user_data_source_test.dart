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

    test('fcmTokens가 Firestore 문서에 저장된다', () async {
      final user = _testUser().copyWith(fcmTokens: ['token-abc']);

      await dataSource.createUser(user);

      final doc = await fakeFirestore.collection('users').doc(user.id).get();
      expect(doc.data()?['fcmTokens'], ['token-abc']);
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
    });

    test('업데이트 후 기존 필드는 변경되지 않는다', () async {
      final user = _testUser();
      await dataSource.createUser(user);

      await dataSource.updateUser(user.id, {'nickname': '새닉네임'});

      final updated = await dataSource.getUser(user.id);
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

    test('softDelete 후 fcmTokens가 빈 배열로 초기화된다', () async {
      final user = _testUser();
      await dataSource.createUser(user);
      // fcmTokens는 @JsonKey(includeToJson: false)이므로 createUser에서 저장되지 않음
      // 직접 추가 후 softDelete 테스트
      await fakeFirestore.collection('users').doc(user.id).update({
        'fcmTokens': ['token-1', 'token-2'],
      });

      await dataSource.softDeleteUser(user.id);

      final doc = await fakeFirestore.collection('users').doc(user.id).get();
      final fcmTokens = doc.data()?['fcmTokens'] as List<dynamic>?;
      expect(fcmTokens, isEmpty);
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

    test('deletedAt이 있는 사용자를 복구 후 반환한다', () async {
      final user = _testUser();
      await fakeFirestore.collection('users').doc(user.id).set({
        'email': user.email,
        'name': user.name,
        'nickname': user.nickname,
        'authProviders': <String>[],
        'storeById': <String, dynamic>{},
        'deletedAt': Timestamp.now(),
      });

      final result = await dataSource.fetchUserWithRestoration(user.id);

      expect(result, isNotNull);
      expect(result!.id, user.id);
    });

    test('복구 후 deletedAt 필드가 삭제된다', () async {
      final user = _testUser();
      await fakeFirestore.collection('users').doc(user.id).set({
        'email': user.email,
        'name': user.name,
        'nickname': user.nickname,
        'authProviders': <String>[],
        'storeById': <String, dynamic>{},
        'deletedAt': Timestamp.now(),
      });

      await dataSource.fetchUserWithRestoration(user.id);

      final doc = await fakeFirestore.collection('users').doc(user.id).get();
      expect(doc.data()?.containsKey('deletedAt'), false);
    });

    test('존재하지 않는 사용자는 null을 반환한다', () async {
      final result = await dataSource.fetchUserWithRestoration('nonexistent-uid');

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

    test('복구 후 getUser가 사용자를 반환한다', () async {
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

      await dataSource.restoreUser(user.id);
      final result = await dataSource.getUser(user.id);

      expect(result, isNotNull);
      expect(result!.id, user.id);
    });
  });
}
