import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/common/exceptions/auth_exceptions.dart';
import 'package:studio_chance/data/models/auth_model.dart';

part 'auth_data_source.g.dart';

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

      for (final provider in user.providerData) {
        // Google 연결 해제
        if (provider.providerId == 'google.com') {
          try {
            await GoogleSignIn.instance.disconnect();
          } catch (e) {
            _logger.d('Google 계정 disconnect 실패 (무시 가능)', error: e);
          }
        }
        // Apple 연결 해제
        else if (provider.providerId == 'apple.com') {
          try {
            await _revokeAppleSignIn();
          } catch (e) {
            if (e is AuthCancelledException) rethrow;
          }
        }
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

      if (targetProviderId == 'google.com') {
        final credential = await _getGoogleCredential();
        await user.reauthenticateWithCredential(credential);
      } else if (targetProviderId == 'apple.com') {
        AppleAuthProvider appleProvider = AppleAuthProvider();
        await user.reauthenticateWithProvider(appleProvider);
      } else {
        throw AuthMethodNotSupportedException(
          message:
              '재인증을 지원하지 않는 로그인 방식입니다. (Provider: ${user.providerData.map((e) => e.providerId)})',
        );
      }

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

  Future<void> _revokeAppleSignIn() async {
    _logger.d('Apple 계정 Revoke 시작');

    final appleProvider = AppleAuthProvider();

    UserCredential userCredential = await _auth.signInWithProvider(
      appleProvider,
    );
    String? authCode = userCredential.additionalUserInfo?.authorizationCode;

    if (authCode == null || authCode.isEmpty) {
      throw AuthUnknownException(message: 'Apple Authorization Code가 없습니다.');
    }

    await _auth.revokeTokenWithAuthorizationCode(authCode);
    _logger.d('Apple 계정 Revoke 성공');
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

        // 2. 이메일/비밀번호 입력 오류
        case 'invalid-email':
          return AuthInvalidEmailException(message: msg, code: code);
        case 'wrong-password':
          return AuthWrongPasswordException(message: msg, code: code);
        case 'email-already-in-use':
          return AuthEmailAlreadyInUseException(message: msg, code: code);

        // 3. 계정 연동 및 충돌 오류
        case 'credential-already-in-use':
        case 'account-exists-with-different-credential':
          return AuthCredentialAlreadyInUseException(message: msg, code: code);

        case 'provider-already-linked':
          return AuthProviderAlreadyLinkedException(message: msg, code: code);

        // 4. 기타 자격 증명 오류
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
