import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/utils/exception_utils.dart';
import 'package:studio_chance/data/data_sources/auth_data_source.dart';
import 'package:studio_chance/data/data_sources/notification_data_source.dart';
import 'package:studio_chance/data/data_sources/user_data_source.dart';
import 'package:studio_chance/data/models/user_model.dart';
import 'package:studio_chance/data/models/user_store_info_model.dart';
import 'package:studio_chance/domain/entities/auth_info.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/enums/store_color.dart';
import 'package:studio_chance/domain/enums/user_role.dart';
import 'package:studio_chance/domain/repository_interfaces/user_repository.dart';

part 'user_repository_impl.g.dart';

class UserRepositoryImpl implements UserRepository {
  final Logger _logger = Logger();

  final AuthDataSource _authDataSource;
  final UserDataSource _userDataSource;
  final NotificationDataSource _notificationDataSource;

  UserRepositoryImpl({
    required AuthDataSource authDataSource,
    required UserDataSource userDataSource,
    required NotificationDataSource notificationDataSource,
  }) : _authDataSource = authDataSource,
       _userDataSource = userDataSource,
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

      var userModel = await _userDataSource.getUser(authInfo.uid);
      if (userModel != null) {
        await _userDataSource.recordLogin(
          userModel.id,
          authProviders: authInfo.authProviders,
          fcmToken: fcmToken,
        );
      } else {
        // 신규 유저
        final newUserModel = UserModel(
          id: authInfo.uid,
          name: authInfo.displayName ?? '이름 없음',
          email: authInfo.email ?? '',
          nickname: null,
          authProviders: authInfo.authProviders,
          fcmTokens: fcmToken != null ? [fcmToken] : [],
          storeById: {},
        );

        await _userDataSource.createUser(newUserModel);
        userModel = newUserModel;
        _logger.i('신규 유저 DB 생성 완료: ${newUserModel.id}');
      }

      return right(userModel.toEntity());
    } catch (e) {
      _logger.e('fetchOrCreateUser 실패');
      return left(toException(e));
    }
  }

  @override
  Future<Either<Exception, User?>> getCurrentUser() async {
    try {
      final authModel = _authDataSource.getCurrentUser();
      if (authModel == null) return right(null);

      final userModel = await _userDataSource.getUser(authModel.uid);
      if (userModel == null) return right(null);

      return right(userModel.toEntity());
    } catch (e) {
      _logger.e('getCurrentUser 실패');
      return left(toException(e));
    }
  }

  @override
  Future<Either<Exception, User?>> getUser(String uid) async {
    try {
      final userModel = await _userDataSource.getUser(uid);
      if (userModel == null) return right(null);

      return right(userModel.toEntity());
    } catch (e) {
      _logger.e('getUser 실패');
      return left(toException(e));
    }
  }

  @override
  Future<Either<Exception, void>> updateUser({
    required String uid,
    String? email,
    String? nickname,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (email != null) updates['email'] = email;
      if (nickname != null) updates['nickname'] = nickname;

      if (updates.isEmpty) return right(null);

      await _userDataSource.updateUser(uid, updates);
      _logger.i('사용자 업데이트 완료:\nuid: $uid\n$updates');
      return right(null);
    } catch (e) {
      _logger.e('사용자 업데이트 실패\nuid: $uid');
      return left(toException(e));
    }
  }

  @override
  Future<Either<Exception, void>> updateStoreInfo({
    required String uid,
    required String storeId,
    String? name,
    StoreColor? color,
  }) async {
    try {
      final Map<String, dynamic> data = {};

      if (name != null) data['name'] = name;
      if (color != null) {
        // color.name은 Dart 식별자('green')를 반환하므로 toJson()으로 JSON 값('GREEN') 직렬화
        // (store_repository_impl.dart의 updateStore와 동일한 패턴)
        final colorJson = UserStoreInfoModel(
          name: '', role: UserRole.none, color: color, memo: '',
        ).toJson()['color'] as String;
        data['color'] = colorJson;
      }

      if (data.isEmpty) return right(null);

      await _userDataSource.updateStoreInfo(uid, storeId, data);

      _logger.i('사용자 점포 설정 변경 완료\nuid: $uid, storeId: $storeId\n$data');
      return right(null);
    } catch (e) {
      _logger.e('사용자 점포 설정 변경 실패');
      return left(toException(e));
    }
  }

  @override
  Future<void> removeCurrentDeviceFcmToken(String uid) async {
    try {
      final token = await _notificationDataSource.getFcmToken();

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
      // 탈퇴 실패는 호출부(UseCase)까지 예외를 전파하여 사용자에게 알림 (의도적 throw)
      throw toException(e);
    }
  }
}

@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) {
  final authDataSource = ref.watch(authDataSourceProvider);
  final userDataSource = ref.watch(userDataSourceProvider);
  final notificationDataSource = ref.watch(notificationDataSourceProvider);

  return UserRepositoryImpl(
    authDataSource: authDataSource,
    userDataSource: userDataSource,
    notificationDataSource: notificationDataSource,
  );
}
