import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/data/data_sources/auth_data_source.dart';
import 'package:studio_chance/data/data_sources/user_data_source.dart';
import 'package:studio_chance/data/models/user_model.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/enums/user_role.dart';
import 'package:studio_chance/domain/repository_interfaces/user_repository.dart';

part 'user_repository_impl.g.dart';

class UserRepositoryImpl implements UserRepository {
  final Logger _logger = Logger();

  final AuthDataSource _authDataSource;
  final UserDataSource _userDataSource;

  UserRepositoryImpl({
    required AuthDataSource authDataSource,
    required UserDataSource userDataSource,
  }) : _authDataSource = authDataSource,
       _userDataSource = userDataSource;

  @override
  Future<Either<Exception, User?>> getCurrentUser() async {
    try {
      final authModel = _authDataSource.getCurrentUser();

      if (authModel == null) {
        return right(null);
      }

      final userModel = await _userDataSource.getUser(authModel.uid);

      return right(userModel?.toEntity());
    } catch (e) {
      _logger.e('getCurrentUser 실패', error: e);
      return left(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, User?>> getUser(String uid) async {
    try {
      final userModel = await _userDataSource.getUser(uid);
      return right(userModel?.toEntity());
    } catch (e) {
      _logger.e('getUser 실패', error: e);
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

      if (email != null) {
        updates['email'] = email;
      }

      if (nickname != null) {
        updates['nickname'] = nickname;
      }

      if (role != null) {
        updates['role'] = role.name;
      }

      if (updates.isEmpty) {
        return right(null);
      }

      await _userDataSource.updateUser(uid, updates);
      _logger.i('사용자 업데이트 완료:\nuid: $uid\n$updates');
      return right(null);
    } catch (e) {
      _logger.e('사용자 업데이트 실패\nuid: $uid', error: e);
      return left(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, void>> addStoreId({
    required String uid,
    required String storeId,
  }) async {
    try {
      await _userDataSource.addStoreId(uid, storeId);
      _logger.i('점포 ID 추가 완료\nid: $storeId)');
      return right(null);
    } catch (e) {
      _logger.e('점포 ID 추가 실패', error: e);
      return left(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, void>> removeStoreId({
    required String uid,
    required String storeId,
  }) async {
    try {
      await _userDataSource.removeStoreId(uid, storeId);
      _logger.i('점포 ID 제거 완료\nid: $storeId)');
      return right(null);
    } catch (e) {
      _logger.e('점포 ID 제거 실패', error: e);
      return left(e is Exception ? e : Exception(e.toString()));
    }
  }
}

@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) {
  final authDataSource = ref.watch(authDataSourceProvider);
  final userDataSource = ref.watch(userDataSourceProvider);

  return UserRepositoryImpl(
    authDataSource: authDataSource,
    userDataSource: userDataSource,
  );
}
