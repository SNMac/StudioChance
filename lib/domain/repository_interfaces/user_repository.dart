import 'package:fpdart/fpdart.dart';

import 'package:studio_chance/domain/entities/user.dart';

abstract interface class UserRepository {
  /// 현재 사용자 정보 반환
  Future<Either<Exception, User?>> getCurrentUser();

  /// 특정 사용자 정보 반환
  Future<Either<Exception, User?>> getUser(String uid);
}
