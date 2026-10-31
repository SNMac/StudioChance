import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/data/data_sources/store_data_source.dart';
import 'package:studio_chance/data/data_sources/user_data_source.dart';
import 'package:studio_chance/data/repositories/store_repository_impl.dart';
import 'package:studio_chance/domain/entities/space_option.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/entities/store_member_info.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';

import '../../helpers/fake_firestore_helper.dart';
import '../../helpers/either_expectations.dart';
import '../../helpers/mocks.dart';

// 초대 코드 Callable(lookupInviteCode·issueInviteCode)은 fake_cloud_firestore로
// 검증할 수 없다. 이 파일의 테스트는 이를 호출하지 않으므로 목은 생성자
// 파라미터를 채우는 용도로만 쓰인다.
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
    fakeFirestore = FakeFirestoreHelper.create();
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
    test('getStore memberInfos가 users 컬렉션에서 hydrate된다', () async {
      final uid = FakeFirestoreHelper.generateId();
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
      final storeId = expectRight(created).id;

      final fetched = await repository.getStore(storeId);

      final store = expectRight(fetched)!;
      expect(store.name, '통합 테스트 점포');
      expect(store.memberInfos.length, 1);
      expect(store.memberInfos.first.user.id, uid);
      expect(store.memberInfos.first.role, UserRole.admin);
    });
  });

  group('멤버 사용자 문서가 깨진 점포 조회', () {
    test('한 멤버의 사용자 문서를 읽지 못해도 점포는 조회되고 그 멤버만 빠진다', () async {
      final ownerUid = FakeFirestoreHelper.generateId();
      final brokenUid = FakeFirestoreHelper.generateId();
      await _seedUserDoc(fakeFirestore, ownerUid);
      final adminUser = User(
        id: ownerUid,
        name: '테스트 유저',
        email: 'test@example.com',
        nickname: null,
        authProviders: [],
        storeInfos: [],
      );
      final storeId = expectRight(
        await repository.createStore(
          store: _testStoreEntity(ownerUid, adminUser),
          color: StoreColor.blue,
          memo: '',
        ),
      ).id;

      // 점포에는 대기 멤버로 있지만 사용자 문서의 점포 항목에 role이 없어 파싱에 실패한다
      await fakeFirestore.collection('users').doc(brokenUid).set(
        <String, dynamic>{
          'email': 'broken@example.com',
          'name': '깨진 유저',
          'authProviders': <String>[],
          'storeById': <String, dynamic>{
            storeId: <String, dynamic>{'name': '통합 테스트 점포'},
          },
        },
      );
      await fakeFirestore.collection('stores').doc(storeId).update({
        'waitingMemberById.$brokenUid': <String, dynamic>{'role': 'STAFF'},
      });

      final store = expectRight(await repository.getStore(storeId))!;

      expect(store.memberInfos.map((m) => m.user.id), [ownerUid]);
      expect(store.waitingMemberInfos, isEmpty);
    });
  });

  // =========================================================================
  // legacy fallback (spaceOptions 없는 구버전 점포)
  // =========================================================================

  group('legacy spaceOptions fallback', () {
    test('spaceOptions가 없는 점포를 조회하면 legacy_default 공간 하나로 채워진다', () async {
      final uid = FakeFirestoreHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);
      // spaceOptions 필드 자체가 없던 구버전 문서를 직접 시뮬레이션
      final storeId = FakeFirestoreHelper.generateId();
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

      final store = expectRight(fetched)!;
      expect(store.spaceOptions.length, 1);
      expect(store.spaceOptions.first.id, 'legacy_default');
      expect(store.spaceOptions.first.name, '기본 공간');
    });
  });

  // =========================================================================
  // updateStore
  // =========================================================================

  group('updateStore', () {
    test('점포명 변경 시 다른 멤버(staff)의 storeById.name 캐시도 함께 갱신된다', () async {
      final ownerUid = FakeFirestoreHelper.generateId();
      final staffUid = FakeFirestoreHelper.generateId();
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
      final createdStore = expectRight(created);

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
      final storeWithStaff = expectRight(fetched)!;

      await repository.updateStore(
        original: storeWithStaff,
        store: storeWithStaff.copyWith(name: '변경된 점포명'),
      );

      final staffDoc = await fakeFirestore
          .collection('users')
          .doc(staffUid)
          .get();
      final staffStoreById =
          staffDoc.data()?['storeById'] as Map<String, dynamic>?;
      expect(staffStoreById?[createdStore.id]['name'], '변경된 점포명');
    });

    group('동시 수정 감지 (D13)', () {
      late String ownerUid;
      late Store opened;

      setUp(() async {
        ownerUid = FakeFirestoreHelper.generateId();
        await _seedUserDoc(fakeFirestore, ownerUid);
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
        final storeId = expectRight(created).id;
        opened = expectRight(await repository.getStore(storeId))!;
      });

      Future<Store> saved() async =>
          expectRight(await repository.getStore(opened.id))!;

      test('폼을 연 뒤 아무도 바꾸지 않았으면 저장된다', () async {
        final result = await repository.updateStore(
          original: opened,
          store: opened.copyWith(name: '변경된 점포명'),
        );

        expectRight(result);
        expect((await saved()).name, '변경된 점포명');
      });

      test('다른 관리자가 편집 필드를 먼저 바꿨으면 충돌로 실패하고 덮어쓰지 않는다', () async {
        await fakeFirestore.collection('stores').doc(opened.id).update({
          'address': '다른 관리자가 바꾼 주소',
        });

        final result = await repository.updateStore(
          original: opened,
          store: opened.copyWith(name: '내가 바꾼 점포명'),
        );

        expect(expectLeft(result), isA<StoreUpdateConflictException>());
        final current = await saved();
        expect(current.name, '통합 테스트 점포');
        expect(current.address, '다른 관리자가 바꾼 주소');
      });

      test('폼을 연 뒤 가입 신청·승인만 있었으면 충돌로 보지 않는다', () async {
        final staffUid = FakeFirestoreHelper.generateId();
        await _seedUserDoc(fakeFirestore, staffUid);
        await repository.requestJoinStore(
          storeId: opened.id,
          uid: staffUid,
          role: UserRole.staff,
          color: StoreColor.red,
          storeAlias: '통합 테스트 점포',
          memo: '',
        );
        await repository.approveMember(
          storeId: opened.id,
          uid: staffUid,
          role: UserRole.staff,
        );

        final result = await repository.updateStore(
          original: opened,
          store: opened.copyWith(name: '변경된 점포명'),
        );

        expectRight(result);
        expect((await saved()).name, '변경된 점포명');
      });

      test('spaceOptions가 빈 구버전 점포도 충돌 없이 저장된다', () async {
        // getStore가 legacy_default 공간을 채워 돌려주므로 문서와 폼의 공간 목록이 다르다
        await fakeFirestore.collection('stores').doc(opened.id).update({
          'spaceOptions': <dynamic>[],
        });
        final legacy = await saved();

        final result = await repository.updateStore(
          original: legacy,
          store: legacy.copyWith(name: '변경된 점포명'),
        );

        expectRight(result);
        expect((await saved()).name, '변경된 점포명');
      });
    });
  });

  // =========================================================================
  // softDeleteStore
  // =========================================================================

  group('softDeleteStore', () {
    test('softDeleteStore 후 멤버의 storeById 항목은 남고 삭제 예정으로 표시된다', () async {
      final ownerUid = FakeFirestoreHelper.generateId();
      final staffUid = FakeFirestoreHelper.generateId();
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
      final storeId = expectRight(created).id;

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
      // 남은 기간을 보여주고, 복구할 때 점포 색상·메모가 돌아오도록 남긴다 (ADR-0007)
      expect(ownerStoreById?[storeId]?['deletedAt'], isNotNull);
      expect(staffStoreById?[storeId]?['deletedAt'], isNotNull);
      expect(staffStoreById?[storeId]?['color'], 'RED');
    });

    test('점포 복구 후 멤버 정보에서 삭제 예정 표시가 사라진다', () async {
      final ownerUid = FakeFirestoreHelper.generateId();
      await _seedUserDoc(fakeFirestore, ownerUid);
      final adminUser = User(
        id: ownerUid,
        name: '테스트 유저',
        email: 'test@example.com',
        nickname: null,
        authProviders: [],
        storeInfos: [],
      );
      final storeId = expectRight(
        await repository.createStore(
          store: _testStoreEntity(ownerUid, adminUser),
          color: StoreColor.blue,
          memo: '',
        ),
      ).id;
      expectRight(await repository.softDeleteStore(storeId));

      expectRight(await repository.restoreStore(storeId));

      final store = expectRight(await repository.getStore(storeId));
      expect(store?.isScheduledForDeletion, isFalse);
      final ownerDoc = await fakeFirestore
          .collection('users')
          .doc(ownerUid)
          .get();
      final entry =
          (ownerDoc.data()?['storeById'] as Map<String, dynamic>)[storeId]
              as Map<String, dynamic>;
      expect(entry.containsKey('deletedAt'), isFalse);
    });
  });

  // issueInviteCode: 유효한 코드 재사용 판정은 같은 이름의 Callable
  // (functions/src/invite/)로 옮겨간 서버 책임이다 (ADR-0006).
  // functions/의 invite_code.test.ts·queries/issue_invite_code.test.ts가 지킨다.

  // getStoreByInviteCode: lookupInviteCode Callable(functions/src/invite/)로
  // 옮겨간 서버 책임이라 fake_cloud_firestore로는 더 이상 검증할 수 없다.
  // (store_data_source_test.dart와 동일한 원칙 — Task 8)

  // =========================================================================
  // requestJoinStore + approveMember
  // =========================================================================

  group('requestJoinStore + approveMember', () {
    test('approveMember 후 getStore memberInfos에 승인된 멤버가 포함된다', () async {
      final ownerUid = FakeFirestoreHelper.generateId();
      final memberUid = FakeFirestoreHelper.generateId();
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
      final storeId = expectRight(created).id;

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
      final store = expectRight(fetched)!;
      final memberIds = store.memberInfos.map((m) => m.user.id).toList();
      expect(memberIds.contains(memberUid), isTrue);
    });

    // 신청자는 아직 멤버가 아니라 Rules가 그 점포의 예약 읽기를 거부한다.
    // 사용자 문서만 보고도 승인 전인지 알 수 있어야 홈이 구독하지 않는다.
    test('가입 신청한 점포는 승인 전까지 승인 대기로 읽힌다', () async {
      final ownerUid = FakeFirestoreHelper.generateId();
      final memberUid = FakeFirestoreHelper.generateId();
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
      final storeId = expectRight(created).id;

      Future<bool?> isPendingFor(String uid) async {
        final user = (await userDataSource.getUser(uid))!.toEntity();
        return user.storeInfoOf(storeId)?.isPending;
      }

      expect(await isPendingFor(ownerUid), isFalse, reason: '생성자는 바로 멤버다');

      await repository.requestJoinStore(
        storeId: storeId,
        uid: memberUid,
        role: UserRole.staff,
        color: StoreColor.red,
        storeAlias: '통합 테스트 점포',
        memo: '',
      );
      expect(await isPendingFor(memberUid), isTrue);

      await repository.approveMember(
        storeId: storeId,
        uid: memberUid,
        role: UserRole.staff,
      );
      expect(await isPendingFor(memberUid), isFalse);
    });
  });

  // =========================================================================
  // updateMemberRole
  // =========================================================================

  group('updateMemberRole', () {
    test('store와 user의 role이 올바른 JSON 값으로 업데이트된다', () async {
      final ownerUid = FakeFirestoreHelper.generateId();
      final memberUid = FakeFirestoreHelper.generateId();
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
      final storeId = expectRight(created).id;

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

      // getStore 호출 시 역직렬화가 성공해야 함 — updateMemberRole 후 실패하면 role 직렬화 버그다
      final fetched = expectRight(await repository.getStore(storeId));
      final updatedMember = fetched!.memberInfos
          .where((m) => m.user.id == memberUid)
          .firstOrNull;
      expect(updatedMember?.role, UserRole.admin);
    });
  });

  // =========================================================================
  // getMembership (관리자 판정·멤버 수용, ADR-0004)
  // =========================================================================

  group('getMembership', () {
    test('사용자 문서를 읽지 못해 memberInfos에서 빠진 멤버도 멤버 구성에는 포함된다', () async {
      final ownerUid = FakeFirestoreHelper.generateId();
      final brokenUid = FakeFirestoreHelper.generateId();
      await _seedUserDoc(fakeFirestore, ownerUid);
      final adminUser = User(
        id: ownerUid,
        name: '테스트 유저',
        email: 'test@example.com',
        nickname: null,
        authProviders: [],
        storeInfos: [],
      );
      final storeId = expectRight(
        await repository.createStore(
          store: _testStoreEntity(ownerUid, adminUser),
          color: StoreColor.blue,
          memo: '',
        ),
      ).id;
      // 멤버로 등록됐지만 사용자 문서가 없어 hydrate에서 빠지는 멤버
      await fakeFirestore.collection('stores').doc(storeId).update({
        'memberById.$brokenUid': <String, dynamic>{'role': 'STAFF'},
      });

      final store = expectRight(await repository.getStore(storeId))!;
      final membership = expectRight(await repository.getMembership(storeId))!;

      expect(store.memberInfos.map((m) => m.user.id), [ownerUid]);
      expect(membership.roleByUid, {
        ownerUid: UserRole.admin,
        brokenUid: UserRole.staff,
      });
      expect(membership.hasMembersOtherThan(ownerUid), isTrue);
    });

    test('삭제된 점포는 null이다', () async {
      final ownerUid = FakeFirestoreHelper.generateId();
      await _seedUserDoc(fakeFirestore, ownerUid);
      final adminUser = User(
        id: ownerUid,
        name: '테스트 유저',
        email: 'test@example.com',
        nickname: null,
        authProviders: [],
        storeInfos: [],
      );
      final storeId = expectRight(
        await repository.createStore(
          store: _testStoreEntity(ownerUid, adminUser),
          color: StoreColor.blue,
          memo: '',
        ),
      ).id;
      expectRight(await repository.softDeleteStore(storeId));

      expect(expectRight(await repository.getMembership(storeId)), isNull);
    });
  });

  // =========================================================================
  // delegateAdmin
  // =========================================================================

  group('delegateAdmin', () {
    late String ownerUid;
    late String memberUid;
    late String storeId;

    setUp(() async {
      ownerUid = FakeFirestoreHelper.generateId();
      memberUid = FakeFirestoreHelper.generateId();
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
      storeId = expectRight(
        await repository.createStore(
          store: _testStoreEntity(ownerUid, adminUser),
          color: StoreColor.blue,
          memo: '',
        ),
      ).id;
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
    });

    test('점포와 두 사용자 문서의 역할이 한 번에 바뀐다', () async {
      expectRight(
        await repository.delegateAdmin(
          storeId: storeId,
          fromUid: ownerUid,
          toUid: memberUid,
          previousAdminRole: UserRole.viewer,
        ),
      );

      final membership = expectRight(await repository.getMembership(storeId))!;
      expect(membership.roleByUid, {
        ownerUid: UserRole.viewer,
        memberUid: UserRole.admin,
      });

      Future<Object?> cachedRole(String uid) async {
        final doc = await fakeFirestore.collection('users').doc(uid).get();
        return (doc.data()?['storeById'] as Map)[storeId]['role'];
      }

      expect(await cachedRole(ownerUid), 'VIEWER');
      expect(await cachedRole(memberUid), 'ADMIN');
    });

    test(
      '대상이 점포 멤버가 아니면 StoreDelegationTargetInvalidException으로 실패하고 쓰지 않는다',
      () async {
        final result = await repository.delegateAdmin(
          storeId: storeId,
          fromUid: ownerUid,
          toUid: 'outsider',
          previousAdminRole: UserRole.staff,
        );

        expect(
          expectLeft(result),
          isA<StoreDelegationTargetInvalidException>(),
        );
        final membership = expectRight(
          await repository.getMembership(storeId),
        )!;
        expect(membership.roleOf(ownerUid), UserRole.admin);
      },
    );

    test('위임하는 사람이 관리자가 아니면 StorePermissionDeniedException으로 실패한다', () async {
      final result = await repository.delegateAdmin(
        storeId: storeId,
        fromUid: memberUid,
        toUid: ownerUid,
        previousAdminRole: UserRole.staff,
      );

      expect(expectLeft(result), isA<StorePermissionDeniedException>());
    });
  });
}
