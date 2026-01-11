import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/data/data_sources/auth_data_source.dart';
import 'package:studio_chance/domain/entities/auth_info.dart';
import 'package:studio_chance/domain/repository_interfaces/auth_repository.dart';

part 'auth_repository_impl.g.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Logger _logger = Logger();

  final AuthDataSource _authDataSource;

  AuthRepositoryImpl({required AuthDataSource authDataSource})
    : _authDataSource = authDataSource;

  @override
  Stream<AuthInfo?> authStateChanges() {
    return _authDataSource.authStateChanges().map((model) => model?.toEntity());
  }

  @override
  Future<Either<Exception, AuthInfo>> signInWithGoogle() async {
    try {
      final authModel = await _authDataSource.signInWithGoogle();
      return right(authModel.toEntity());
    } catch (e) {
      _logger.e('Google 로그인 실패');
      return left(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, AuthInfo>> signInWithApple() async {
    try {
      final authModel = await _authDataSource.signInWithApple();
      return right(authModel.toEntity());
    } catch (e) {
      _logger.e('Apple 로그인 실패');
      return left(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _authDataSource.signOut();
    } catch (e) {
      // 로그아웃에 실패하더라도 앱에선 로그아웃 상태로 간주
      _logger.e('로그아웃 수행 실패');
    }
  }

  @override
  Future<Either<Exception, void>> delete() async {
    try {
      await _authDataSource.deleteAuth();
      return right(null);
    } catch (e) {
      _logger.e('탈퇴 수행 실패');
      return left(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, void>> reauthenticate() async {
    try {
      await _authDataSource.reauthenticate();
      return right(null);
    } catch (e) {
      _logger.e('재인증 수행 실패');
      return left(e is Exception ? e : Exception(e.toString()));
    }
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final authDataSource = ref.watch(authDataSourceProvider);

  return AuthRepositoryImpl(authDataSource: authDataSource);
}
