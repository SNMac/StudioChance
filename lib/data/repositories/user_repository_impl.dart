import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/data/data_sources/auth_data_source.dart';
import 'package:studio_chance/data/data_sources/user_data_source.dart';
import 'package:studio_chance/data/models/user_model.dart';
import 'package:studio_chance/domain/entities/user.dart';
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
