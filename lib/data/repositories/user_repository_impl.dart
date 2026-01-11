import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/data/data_sources/auth_data_source.dart';
import 'package:studio_chance/data/data_sources/notification_data_source.dart';
import 'package:studio_chance/data/data_sources/store_data_source.dart';
import 'package:studio_chance/data/data_sources/user_data_source.dart';
import 'package:studio_chance/data/models/user_model.dart';
import 'package:studio_chance/domain/entities/auth_info.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/enums/user_role.dart';
import 'package:studio_chance/domain/repository_interfaces/user_repository.dart';

part 'user_repository_impl.g.dart';

class UserRepositoryImpl implements UserRepository {
  final Logger _logger = Logger();

  final AuthDataSource _authDataSource;
  final UserDataSource _userDataSource;
  final StoreDataSource _storeDataSource;
  final NotificationDataSource _notificationDataSource;

  UserRepositoryImpl({
    required AuthDataSource authDataSource,
    required UserDataSource userDataSource,
    required StoreDataSource storeDataSource,
    required NotificationDataSource notificationDataSource,
  }) : _authDataSource = authDataSource,
       _userDataSource = userDataSource,
       _storeDataSource = storeDataSource,
       _notificationDataSource = notificationDataSource;

  @override
  Future<Either<Exception, User>> fetchOrCreateUser(AuthInfo authInfo) async {
    try {
      String? fcmToken;
      try {
        fcmToken = await _notificationDataSource.getFcmToken();
      } catch (e) {
        _logger.w('FCM 토큰 획득 실패 (무시)', error: e);
      }

      // 2. DB 조회
      var userModel = await _userDataSource.getUser(authInfo.uid);

      if (userModel != null) {
        // 기존 유저
        // 탈퇴 복구
        if (userModel.deletedAt != null) {
          await _userDataSource.restoreUser(userModel.id);
          _logger.i('탈퇴 계정 복구 완료: ${userModel.id}');
        }

        if (fcmToken != null) {
          await _userDataSource.addFcmToken(userModel.id, fcmToken);
        }
        await _userDataSource.updateUser(userModel.id, {
          'authProviders': authInfo.authProviders,
          'lastLoginAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        });
      } else {
        // 신규 유저
        // DB 생성
        final newUserModel = UserModel(
          id: authInfo.uid,
          name: authInfo.displayName ?? '이름 없음',
          email: authInfo.email ?? '',
          nickname: null,
          authProviders: authInfo.authProviders,
          fcmTokens: fcmToken != null ? [fcmToken] : [],
          role: UserRole.none,
          storeIds: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await _userDataSource.createUser(newUserModel);
        userModel = newUserModel;
        _logger.i('신규 유저 DB 생성 완료: ${newUserModel.id}');
      }

      final stores = await _fetchStores(userModel.storeIds);

      return right(userModel.toEntity(stores: stores));
    } catch (e) {
      _logger.e('fetchOrCreateUser 실패');
      return left(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, User?>> getCurrentUser() async {
    try {
      final authModel = _authDataSource.getCurrentUser();
      if (authModel == null) return right(null);

      final userModel = await _userDataSource.getUser(authModel.uid);
      if (userModel == null) return right(null);

      final stores = await _fetchStores(userModel.storeIds);

      return right(userModel.toEntity(stores: stores));
    } catch (e) {
      _logger.e('getCurrentUser 실패');
      return left(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, User?>> getUser(String uid) async {
    try {
      final userModel = await _userDataSource.getUser(uid);
      if (userModel == null) return right(null);

      final stores = await _fetchStores(userModel.storeIds);

      return right(userModel.toEntity(stores: stores));
    } catch (e) {
      _logger.e('getUser 실패');
      return left(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, void>> updateUser({
    required String uid,
    String? email,
    String? nickname,
    UserRole? role,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (email != null) updates['email'] = email;
      if (nickname != null) updates['nickname'] = nickname;
      if (role != null) updates['role'] = role.name;

      if (updates.isEmpty) return right(null);

      await _userDataSource.updateUser(uid, updates);
      _logger.i('사용자 업데이트 완료:\nuid: $uid\n$updates');
      return right(null);
    } catch (e) {
      _logger.e('사용자 업데이트 실패\nuid: $uid');
      return left(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<void> removeCurrentDeviceFcmToken(String uid) async {
    try {
      final token = await _notificationDataSource.getFcmToken();

      if (token == null) {
        _logger.w('삭제할 FCM 토큰 없음');
        return;
      }

      await _userDataSource.removeFcmToken(uid, token);

      _logger.i('기기 FCM 토큰 삭제 완료 (로그아웃)\nuid: $uid\ntoken: $token');
    } catch (e) {
      _logger.e('FCM 토큰 삭제 실패');
    }
  }

  @override
  Future<void> softDeleteUser(String uid) async {
    try {
      await _userDataSource.softDeleteUser(uid);

      _logger.i('사용자 Soft Delete 완료 (회원 탈퇴)\nuid: $uid');
    } catch (e) {
      _logger.e('사용자 Soft Delete 실패');
      throw e is Exception ? e : Exception(e.toString());
    }
  }

  // ===========================================================================
  // Private Helpers
  // ===========================================================================

  /// Store ID 목록을 받아 Store Entity 목록으로 변환
  Future<List<Store>> _fetchStores(List<String> storeIds) async {
    if (storeIds.isEmpty) return [];

    final futures = storeIds.map((id) async {
      try {
        return await _storeDataSource.getStore(id);
      } catch (e) {
        _logger.w('특정 점포 조회 실패 (ID: $id)');
        return null;
      }
    });
    final storeModels = await Future.wait(futures);

    return storeModels
        .where((model) => model != null)
        .map((model) => model!.toEntity(members: [], waitingMembers: []))
        .toList();
  }
}

@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) {
  final authDataSource = ref.watch(authDataSourceProvider);
  final userDataSource = ref.watch(userDataSourceProvider);
  final storeDataSource = ref.watch(storeDataSourceProvider);
  final notificationDataSource = ref.watch(notificationDataSourceProvider);

  return UserRepositoryImpl(
    authDataSource: authDataSource,
    userDataSource: userDataSource,
    storeDataSource: storeDataSource,
    notificationDataSource: notificationDataSource,
  );
}
