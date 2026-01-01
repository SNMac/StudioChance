import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/data/datasources/auth_data_source.dart';
import 'package:studio_chance/data/datasources/user_data_source.dart';
import 'package:studio_chance/data/exceptions/auth_exceptions.dart';
import 'package:studio_chance/data/models/auth_model.dart';

import 'package:studio_chance/domain/repository_interfaces/auth_repository.dart';
import 'package:studio_chance/common/errors/failures.dart';
import 'package:studio_chance/common/errors/special_failures.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/data/models/user_model.dart';
import 'package:studio_chance/common/enums/user_role.dart';

part 'auth_repository_impl.g.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Logger _logger = Logger();

  final AuthDataSource _authDataSource;
  final FirebaseMessaging _messaging;
  final UserDataSource _userDataSource;

  AuthRepositoryImpl({
    required AuthDataSource authDataSource,
    required UserDataSource userDataSource,
    required FirebaseMessaging messaging,
  }) : _authDataSource = authDataSource,
       _userDataSource = userDataSource,
       _messaging = messaging;

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final authModel = await _authDataSource.signInWithGoogle();

      return _authenticate(authModel);
    } catch (e) {
      return left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithApple() async {
    try {
      final authModel = await _authDataSource.signInWithApple();
      return _authenticate(authModel);
    } catch (e) {
      return left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      final authModel = _authDataSource.getCurrentUser();
      if (authModel != null) {
        final fcmToken = await _messaging.getToken();
        if (fcmToken != null) {
          await _userDataSource.removeFcmToken(authModel.uid, fcmToken);
        }
      }
    } catch (e) {
      _logger.w('로그아웃 중 토큰 삭제 실패 (무시 가능)', error: e);
    }

    try {
      await _authDataSource.signOut();
    } catch (e) {
      // 로그아웃에 실패하더라도 앱에선 로그아웃 상태로 간주
      _logger.e('로그아웃 수행 실패', error: e);
    }
  }

  @override
  Future<Either<Failure, void>> delete() async {
    try {
      final authModel = _authDataSource.getCurrentUser();
      if (authModel == null) return left(const AuthFailure('로그인 정보가 없습니다.'));

      await _userDataSource.softDeleteUser(authModel.uid);

      await _authDataSource.deleteAuth();

      return right(null);
    } catch (e) {
      return left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<void> registerFcmToken() async {
    final authModel = _authDataSource.getCurrentUser();
    if (authModel == null) return;

    try {
      final fcmToken = await _messaging.getToken();
      if (fcmToken == null) return;

      await _userDataSource.addFcmToken(authModel.uid, fcmToken);
      _logger.d('FCM 토큰 등록 완료');
    } catch (e) {
      _logger.w('FCM 토큰 등록 실패', error: e);
    }
  }

  @override
  Future<void> replaceFcmToken({
    required String oldToken,
    required String newToken,
  }) async {
    final authModel = _authDataSource.getCurrentUser();
    if (authModel == null) return;

    try {
      await _userDataSource.replaceFcmToken(authModel.uid, oldToken, newToken);
      _logger.d('FCM 토큰 교체 완료');
    } catch (e) {
      _logger.e('FCM 토큰 교체 실패', error: e);
    }
  }

  @override
  Future<Either<Failure, void>> reauthenticate() async {
    try {
      await _authDataSource.reauthenticate();
      return right(null);
    } catch (e) {
      return left(_mapExceptionToFailure(e));
    }
  }

  // ===========================================================================
  // Private Helper Methods
  // ===========================================================================

  /// 공통 인증 처리 로직
  /// AuthModel(인증 정보)을 받아 DB와 동기화하고 User Entity를 반환합니다.
  Future<Either<Failure, User>> _authenticate(AuthModel authModel) async {
    try {
      // 1. FCM 토큰 획득 (실패해도 로그인은 계속 진행)
      String? fcmToken;
      try {
        fcmToken = await _messaging.getToken();
      } catch (e) {
        _logger.w('FCM 토큰 획득 실패', error: e);
      }

      // 2. DB에서 유저 조회
      UserModel? userModel = await _userDataSource.getUser(authModel.uid);

      if (userModel != null) {
        // [기존 유저] 로그인 시간 갱신
        final Map<String, dynamic> updates = {
          'lastLoginAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        };

        if (fcmToken != null) {
          await _userDataSource.addFcmToken(userModel.id, fcmToken);
        }

        await _userDataSource.updateUser(userModel.id, updates);
      } else {
        // [신규 유저] DB 생성
        userModel = UserModel(
          id: authModel.uid,
          name: authModel.displayName ?? '이름 없음',
          fcmTokens: fcmToken != null ? [fcmToken] : [],
          role: UserRole.none,
          storeIds: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await _userDataSource.createUser(userModel);
      }

      return right(userModel.toEntity());
    } catch (e) {
      return left(_mapExceptionToFailure(e));
    }
  }

  /// Exception Mapper
  /// DataSource Layer의 Exception -> Domain Layer의 Failure
  /// 개발자 친화적인 메시지는 로그로 남기고, UI에는 적절한 메시지를 전달합니다.
  Failure _mapExceptionToFailure(Object e) {
    // 1. 사용자가 취소한 경우 (UI 표시 불필요)
    if (e is AuthCancelledException) {
      return const IgnoreableFailure();
    }

    // 2. 재로그인이 필요한 경우
    if (e is AuthRequiresRecentLoginException) {
      return const RequiresRecentLoginFailure();
    }

    // 3. 구체적인 인증 에러 매핑
    if (e is AuthInvalidCredentialException) {
      return const AuthFailure('인증 정보가 올바르지 않습니다.');
    }
    if (e is AuthUserDisabledException) {
      return const AuthFailure('사용할 수 없는 계정입니다.\n관리자에게 문의하세요.');
    }
    if (e is AuthUserNotFoundException) {
      return const AuthFailure('가입 정보를 찾을 수 없습니다.');
    }
    if (e is AuthOperationNotAllowedException) {
      return const AuthFailure('일시적인 서버 설정 오류입니다.');
    }
    if (e is AuthNetworkException) {
      return const AuthFailure('네트워크 연결 상태를 확인해주세요.');
    }
    if (e is AuthTooManyRequestsException) {
      return const AuthFailure('잠시 후 다시 시도해주세요.');
    }
    if (e is AuthMethodNotSupportedException) {
      return const AuthFailure('지원하지 않는 로그인 방식입니다.');
    }

    // 4. 알 수 없는 에러
    // AuthUnknownException의 메시지는 개발자가 이해하기 쉬운 상세 메시지이므로,
    // 필요하다면 Failure에 그대로 담아 디버깅을 도울 수도 있습니다.
    if (e is AuthUnknownException) {
      _logger.e('Unknown Auth Error: ${e.message}', error: e);
      return AuthFailure('오류가 발생했습니다.\n(${e.message})');
    }

    _logger.e('Unmapped Error', error: e);
    return AuthFailure('알 수 없는 오류가 발생했습니다. ($e)');
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepositoryImpl(Ref ref) {
  final authDataSource = ref.watch(authDataSourceProvider);
  final userDataSource = ref.watch(userDataSourceProvider);

  return AuthRepositoryImpl(
    authDataSource: authDataSource,
    userDataSource: userDataSource,
    messaging: FirebaseMessaging.instance,
  );
}
