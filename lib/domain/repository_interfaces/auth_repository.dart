import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:studio_chance/common/errors/failures.dart';
import 'package:studio_chance/domain/entities/user.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> signInWithGoogle();
  Future<Either<Failure, User>> signInWithApple();
  Future<void> signOut();
  Future<Either<Failure, void>> delete();
  Future<void> syncFcmToken();
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('Data 계층에서 override 필요');
});