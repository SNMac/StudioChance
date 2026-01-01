import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:studio_chance/common/exceptions/auth_exceptions.dart';
import 'package:studio_chance/data/models/auth_model.dart';

part 'auth_data_source.g.dart';

abstract interface class AuthDataSource {
  /// 현재 로그인된 유저 정보 가져오기
  AuthModel? getCurrentUser();

  /// Google 로그인
  Future<AuthModel> signInWithGoogle();

  /// Apple 로그인
  Future<AuthModel> signInWithApple();

  /// 로그아웃
  Future<void> signOut();

  /// 회원 탈퇴
  Future<void> deleteAuth();

  /// 재인증
  Future<void> reauthenticate();
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
      final credential = await _getAppleCredential();
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
  Future<void> signOut() async {
    try {
      try {
        await _googleSignOutSafe();
      } catch (e) {
        _logger.d('Google 로그아웃 실패 (무시 가능)', error: e);
      }
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

      try {
        await GoogleSignIn.instance.disconnect();
      } catch (e) {
        _logger.d('Google 계정 disconnect 실패 (무시 가능)', error: e);
      }

      await user.delete();
      await signOut();
    } catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  @override
  Future<void> reauthenticate() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthUnknownException(message: '현재 로그인된 User가 null입니다.');
      }

      String? targetProviderId;
      for (final provider in user.providerData) {
        if (provider.providerId == 'google.com') {
          targetProviderId = 'google.com';
          break;
        } else if (provider.providerId == 'apple.com') {
          targetProviderId = 'apple.com';
          break;
        }
      }
      _logger.d('재인증 시도: Provider = $targetProviderId');

      AuthCredential? credential;
      if (targetProviderId == 'google.com') {
        credential = await _getGoogleCredential();
      } else if (targetProviderId == 'apple.com') {
        credential = await _getAppleCredential();
      } else {
        // 구글도 애플도 아니면(이메일 등) 지원하지 않음 처리
        throw AuthMethodNotSupportedException(
          message:
              '재인증을 지원하지 않는 로그인 방식입니다. (Provider: ${user.providerData.map((e) => e.providerId)})',
        );
      }

      await user.reauthenticateWithCredential(credential);
      _logger.d('재인증 성공');
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

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    _logger.d('Google 로그인 성공');
    return credential;
  }

  /// Apple 로그인 로직
  Future<OAuthCredential> _getAppleCredential() async {
    _logger.d('Apple 로그인 시작');

    final rawNonce = _generateNonce();
    final sha256Nonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.fullName,
        AppleIDAuthorizationScopes.email,
      ],
      nonce: sha256Nonce,
    );

    final credential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
      rawNonce: rawNonce,
    );
    _logger.d('Apple 로그인 성공');

    return credential;
  }

  Future<void> _googleSignOutSafe() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      _logger.d('Google 로그아웃 실패 (무시 가능)', error: e);
    }
  }

  /// Apple 로그인용 Nonce 생성 메서드
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  // ===========================================================================
  // Error Handling
  // ===========================================================================

  Exception _handleFirebaseError(Object e) {
    _logger.e('Auth Error', error: e);

    // 1. 이미 변환된 예외는 그대로 통과
    if (e is AuthException) return e;

    // 2. Platform Exception (취소 등)
    if (e is PlatformException) {
      if (e.code == 'sign_in_canceled' || e.code == 'canceled') {
        return AuthCancelledException(
          message: '소셜 로그인 팝업이 닫혔거나 사용자가 취소 버튼을 눌렀습니다.',
          code: e.code,
        );
      }
    }

    // 3. Firebase Auth Exception 상세 매핑
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'requires-recent-login':
          return AuthRequiresRecentLoginException(
            message: '계정 삭제나 비밀번호 변경 같은 민감한 작업 전에는 다시 로그인해야 합니다.',
            code: e.code,
          );

        case 'invalid-credential':
        case 'invalid-token':
          return AuthInvalidCredentialException(
            message: '자격 증명이 만료되었거나 형식이 잘못되었습니다. (ID 토큰 또는 Access 토큰 확인 필요)',
            code: e.code,
          );

        case 'wrong-password':
          return AuthInvalidCredentialException(
            message: '비밀번호가 일치하지 않습니다. (이메일 로그인)',
            code: e.code,
          );

        case 'user-disabled':
          return AuthUserDisabledException(
            message: 'Firebase 관리자 콘솔에 의해 사용이 중지된 계정입니다.',
            code: e.code,
          );

        case 'user-not-found':
          return AuthUserNotFoundException(
            message: '가입된 계정이 없거나 삭제되었습니다.',
            code: e.code,
          );

        case 'operation-not-allowed':
          return AuthOperationNotAllowedException(
            message:
                'Firebase Console > Authentication > Sign-in method 탭에서 해당 제공업체가 꺼져있습니다.',
            code: e.code,
          );

        case 'network-request-failed':
          return AuthNetworkException(
            message: 'Firebase 서버에 도달하지 못했습니다. 인터넷 연결이나 DNS 설정을 확인하세요.',
            code: e.code,
          );

        case 'too-many-requests':
          return AuthTooManyRequestsException(
            message: '비정상적으로 많은 로그인 시도가 감지되어 일시적으로 차단되었습니다. 잠시 후 시도하세요.',
            code: e.code,
          );

        // 자주 발생하진 않지만 명시하면 좋은 에러들
        case 'email-already-in-use':
          return AuthInvalidCredentialException(
            message: '이미 다른 계정에서 사용 중인 이메일입니다.',
            code: e.code,
          );

        case 'credential-already-in-use':
          return AuthInvalidCredentialException(
            message: '해당 소셜 계정은 이미 다른 유저와 연동되어 있습니다.',
            code: e.code,
          );

        default:
          return AuthUnknownException(
            message:
                '정의되지 않은 Firebase Auth 에러가 발생했습니다. 메시지를 확인하세요: ${e.message}',
            code: e.code,
          );
      }
    }

    // 4. 기타 에러
    return AuthUnknownException(message: '예상치 못한 시스템 오류가 발생했습니다. ($e)');
  }
}

@Riverpod(keepAlive: true)
AuthDataSource authDataSource(Ref ref) {
  return FirebaseAuthDataSource(FirebaseAuth.instance);
}
