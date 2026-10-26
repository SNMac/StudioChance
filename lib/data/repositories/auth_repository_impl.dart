import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/exceptions/auth_exceptions.dart';
import 'package:studio_chance/common/utils/exception_utils.dart';
import 'package:studio_chance/data/data_sources/auth_data_source.dart';
import 'package:studio_chance/domain/entities/auth_info.dart';
import 'package:studio_chance/domain/repository_interfaces/auth_repository.dart';

part 'auth_repository_impl.g.dart';

/// 앱을 멈추지 않는 오류를 Crashlytics에 남긴다 (테스트에서 바꿔 끼우기 위해 주입)
typedef NonFatalErrorRecorder = Future<void> Function(
  Object error,
  StackTrace stackTrace,
  String reason,
);

class AuthRepositoryImpl implements AuthRepository {
  final Logger _logger = Logger();

  final AuthDataSource _authDataSource;
  final NonFatalErrorRecorder _recordNonFatalError;

  AuthRepositoryImpl({
    required this._authDataSource,
    required this._recordNonFatalError,
  });

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
      return left(toException(e));
    }
  }

  @override
  Future<Either<Exception, AuthInfo>> signInWithApple() async {
    try {
      final authModel = await _authDataSource.signInWithApple();
      return right(authModel.toEntity());
    } catch (e) {
      _logger.e('Apple 로그인 실패');
      return left(toException(e));
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
  Future<Either<Exception, void>> prepareDeletion() async {
    final AppleRevokeToken? appleRevokeToken;
    try {
      appleRevokeToken = await _authDataSource.reauthenticate();
    } catch (e) {
      _logger.e('계정 삭제 전 재인증 실패');
      return left(toException(e));
    }
    if (appleRevokeToken == null) return right(null);

    try {
      await _authDataSource.revokeAppleToken(appleRevokeToken);
      return right(null);
    } catch (e, stackTrace) {
      final exception = toException(e);
      if (exception is AuthCancelledException ||
          exception is AuthNetworkException) {
        _logger.e('Apple revoke 중단 — 계정 삭제를 멈춘다');
        return left(exception);
      }

      _logger.e('Apple revoke 실패 — 기록하고 계정 삭제를 계속한다');
      await _recordNonFatalError(e, stackTrace, 'Apple revoke 실패 (계정 삭제는 계속)');
      return right(null);
    }
  }

  @override
  Future<Either<Exception, void>> delete() async {
    try {
      await _authDataSource.deleteAuth();
      return right(null);
    } catch (e) {
      _logger.e('Auth 계정 삭제 실패');
      return left(toException(e));
    }
  }

  @override
  Future<Either<Exception, void>> reauthenticate() async {
    try {
      await _authDataSource.reauthenticate();
      return right(null);
    } catch (e) {
      _logger.e('재인증 수행 실패');
      return left(toException(e));
    }
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final authDataSource = ref.watch(authDataSourceProvider);

  return AuthRepositoryImpl(
    authDataSource: authDataSource,
    recordNonFatalError: (error, stackTrace, reason) => FirebaseCrashlytics
        .instance
        .recordError(error, stackTrace, reason: reason),
  );
}
