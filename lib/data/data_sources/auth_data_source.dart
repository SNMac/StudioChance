import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/exceptions/auth_exceptions.dart';
import 'package:studio_chance/data/models/auth_model.dart';

part 'auth_data_source.g.dart';

/// Apple 토큰 revoke에 쓸 값. 플랫폼마다 Firebase가 받는 값이 다르다
/// - Android의 `revokeTokenWithAuthorizationCode`는 아무것도 하지 않고 성공을 돌려주므로
///   Android는 반드시 access token으로 revoke한다
sealed class AppleRevokeToken {
  const AppleRevokeToken();
}

/// iOS: `revokeTokenWithAuthorizationCode`에 쓴다. 몇 분 안에만 유효한 일회용 값이다
final class AppleAuthorizationCode extends AppleRevokeToken {
  final String? code;
  const AppleAuthorizationCode(this.code);
}

/// Android: `revokeAccessToken`에 쓴다
final class AppleAccessToken extends AppleRevokeToken {
  final String? token;
  const AppleAccessToken(this.token);
}

/// 재인증할 제공자. Apple이 연동되어 있으면 Google이 함께 있어도 Apple로 한다
/// - 계정 삭제 때 Apple revoke에 필요한 값을 재인증 한 번으로 얻기 위해서다
String? reauthProviderIdOf(Iterable<String> providerIds) {
  if (providerIds.contains('apple.com')) return 'apple.com';
  if (providerIds.contains('google.com')) return 'google.com';
  return null;
}

abstract interface class AuthDataSource {
  /// 현재 로그인된 유저 정보 가져오기
  AuthModel? getCurrentUser();

  /// 로그인 상태 변경 `Stream`
  Stream<AuthModel?> authStateChanges();

  /// Google 로그인
  Future<AuthModel> signInWithGoogle();

  /// Apple 로그인
  Future<AuthModel> signInWithApple();

  /// 로그아웃
  Future<void> signOut();

  /// 계정 삭제: Google 연결 해제(실패 무시) 후 Firebase Auth 계정을 지우고 로그아웃한다
  /// - Apple revoke는 이보다 먼저 [revokeAppleToken]으로 한다
  Future<void> deleteAuth();

  /// 재인증 (제공자는 [reauthProviderIdOf])
  /// - Apple로 재인증했으면 revoke에 쓸 값을 돌려주고, Google이면 null
  Future<AppleRevokeToken?> reauthenticate();

  /// Apple 토큰 revoke. 플랫폼이 값을 주지 않았으면 [AuthUnknownException]
  Future<void> revokeAppleToken(AppleRevokeToken token);
}

class FirebaseAuthDataSource implements AuthDataSource {
  final Logger _logger = Logger();
  bool _isGoogleSignInInitialized = false;

  final FirebaseAuth _auth;
  FirebaseAuthDataSource(this._auth);

  @override
  AuthModel? getCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) return null;
    return AuthModel.fromFirebase(user);
  }

  @override
  Stream<AuthModel?> authStateChanges() {
    return _auth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) return null;
      return AuthModel.fromFirebase(firebaseUser);
    });
  }

  @override
  Future<AuthModel> signInWithGoogle() async {
    try {
      final credential = await _getGoogleCredential();
      final userCredential = await _auth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) {
        throw AuthUnknownException(message: '로그인 이후 User가 null입니다.');
      }

      return AuthModel.fromFirebase(user);
    } catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  @override
  Future<AuthModel> signInWithApple() async {
    try {
      final userCredential = await _getAppleCredential();

      final user = userCredential.user;
      if (user == null) {
        throw AuthUnknownException(message: '로그인 이후 User가 null입니다.');
      }

      return AuthModel.fromFirebase(user);
    } catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignOut();
      await _auth.signOut();
    } catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  @override
  Future<void> deleteAuth() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthUnknownException(message: '현재 로그인된 User가 null입니다.');
      }

      // Apple로 재인증한 세션에는 Google 로그인 상태가 없어 실패할 수 있다.
      // Apple과 달리 revoke가 의무는 아니고 Auth를 지우면 연결이 끊기므로 무시한다
      if (user.providerData.any((p) => p.providerId == 'google.com')) {
        try {
          await GoogleSignIn.instance.disconnect();
        } catch (e) {
          _logger.d('Google 계정 disconnect 실패 (무시 가능)', error: e);
        }
      }

      await user.delete();

      await signOut();
    } catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  @override
  Future<AppleRevokeToken?> reauthenticate() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthUnknownException(message: '현재 로그인된 User가 null입니다.');
      }

      final providerIds = user.providerData.map((p) => p.providerId);
      final targetProviderId = reauthProviderIdOf(providerIds);
      _logger.d('재인증 시도: Provider = $targetProviderId');

      switch (targetProviderId) {
        case 'apple.com':
          final userCredential = await user.reauthenticateWithProvider(
            AppleAuthProvider(),
          );
          _logger.d('재인증 성공');
          return _appleRevokeTokenOf(userCredential);
        case 'google.com':
          final credential = await _getGoogleCredential();
          await user.reauthenticateWithCredential(credential);
          _logger.d('재인증 성공');
          return null;
        default:
          throw AuthMethodNotSupportedException(
            message:
                '재인증을 지원하지 않는 로그인 방식입니다. (Provider: ${providerIds.toList()})',
          );
      }
    } catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  @override
  Future<void> revokeAppleToken(AppleRevokeToken token) async {
    try {
      _logger.d('Apple 계정 Revoke 시작');
      switch (token) {
        case AppleAuthorizationCode(:final code):
          if (code == null || code.isEmpty) {
            throw AuthUnknownException(
              message: 'Apple Authorization Code가 없습니다.',
            );
          }
          await _auth.revokeTokenWithAuthorizationCode(code);
        case AppleAccessToken(token: final accessToken):
          if (accessToken == null || accessToken.isEmpty) {
            throw AuthUnknownException(message: 'Apple Access Token이 없습니다.');
          }
          await _auth.revokeAccessToken(accessToken);
      }
      _logger.d('Apple 계정 Revoke 성공');
    } catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  // ===========================================================================
  // Private Helper Methods
  // ===========================================================================

  /// Google 로그인 로직
  Future<OAuthCredential> _getGoogleCredential() async {
    _logger.d('Google 로그인 시작');

    if (!_isGoogleSignInInitialized) {
      await GoogleSignIn.instance.initialize();
      _isGoogleSignInInitialized = true;
    }

    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw AuthMethodNotSupportedException();
    }

    // authenticate 호출
    final GoogleSignInAccount googleUser = await GoogleSignIn.instance
        .authenticate();

    final GoogleSignInAuthentication googleAuth = googleUser.authentication;
    final String? idToken = googleAuth.idToken;

    if (idToken == null) {
      throw AuthUnknownException(message: 'Google idToken이 null입니다.');
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);

    _logger.d('Google 로그인 성공');
    return credential;
  }

  /// Apple 로그인 로직
  Future<UserCredential> _getAppleCredential() async {
    _logger.d('Apple 로그인 시작');

    AppleAuthProvider appleProvider = AppleAuthProvider();
    appleProvider = appleProvider.addScope('email');
    appleProvider = appleProvider.addScope('name');
    try {
      final credential = await _auth.signInWithProvider(appleProvider);
      _logger.d('Apple 로그인 성공');
      return credential;
    } catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  Future<void> _googleSignOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      _logger.d('Google 로그아웃 실패 (무시 가능)', error: e);
    }
  }

  /// Apple 재인증 결과에서 플랫폼에 맞는 revoke용 값을 꺼낸다 ([AppleRevokeToken])
  AppleRevokeToken _appleRevokeTokenOf(UserCredential userCredential) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AppleAccessToken(userCredential.credential?.accessToken);
    }
    return AppleAuthorizationCode(
      userCredential.additionalUserInfo?.authorizationCode,
    );
  }

  // ===========================================================================
  // Error Handling
  // ===========================================================================

  Exception _handleFirebaseError(Object e) {
    _logger.e('Auth Error', error: e);

    if (e is AuthException) return e;

    if (e is GoogleSignInException &&
        e.code == GoogleSignInExceptionCode.canceled) {
      return AuthCancelledException(
        message: e.description ?? '사용자에 의해 취소되었습니다.',
        code: e.code.toString(),
      );
    }

    if (e is FirebaseAuthException) {
      final msg = e.message ?? 'Firebase Auth Error';
      final code = e.code;

      switch (e.code) {
        // 1. 보안 및 상태
        case 'requires-recent-login':
          return AuthRequiresRecentLoginException(message: msg, code: code);
        case 'user-disabled':
          return AuthUserDisabledException(message: msg, code: code);
        case 'user-not-found':
          return AuthUserNotFoundException(message: msg, code: code);
        case 'operation-not-allowed':
          return AuthOperationNotAllowedException(message: msg, code: code);
        case 'network-request-failed':
          return AuthNetworkException(message: msg, code: code);
        case 'too-many-requests':
          return AuthTooManyRequestsException(message: msg, code: code);
        case 'canceled':
          return AuthCancelledException(message: msg, code: code);

        // 2. 이메일/비밀번호 입력 에러
        case 'invalid-email':
          return AuthInvalidEmailException(message: msg, code: code);
        case 'wrong-password':
          return AuthWrongPasswordException(message: msg, code: code);
        case 'email-already-in-use':
          return AuthEmailAlreadyInUseException(message: msg, code: code);

        // 3. 계정 연동 및 충돌 에러
        case 'credential-already-in-use':
        case 'account-exists-with-different-credential':
          return AuthCredentialAlreadyInUseException(message: msg, code: code);

        case 'provider-already-linked':
          return AuthProviderAlreadyLinkedException(message: msg, code: code);

        // 4. 기타 자격 증명 에러
        case 'invalid-credential':
        case 'user-mismatch':
        case 'no-such-provider': // unlink 실패 등
          return AuthInvalidCredentialException(message: msg, code: code);

        default:
          return AuthUnknownException(message: msg, code: code);
      }
    }

    return AuthUnknownException(message: e.toString());
  }
}

@Riverpod(keepAlive: true)
AuthDataSource authDataSource(Ref ref) {
  return FirebaseAuthDataSource(FirebaseAuth.instance);
}
