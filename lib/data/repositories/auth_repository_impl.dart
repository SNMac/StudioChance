import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:studio_chance/domain/repository_interfaces/auth_repository.dart';
import 'package:studio_chance/common/errors/failures.dart';
import 'package:studio_chance/common/errors/special_failures.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/data/models/user_model.dart';
import 'package:studio_chance/common/enums/user_role.dart';

class AuthRepositoryImpl implements AuthRepository {
  bool _isGoogleSignInInitialized = false;

  final logger = Logger();
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      firebase_auth.OAuthCredential googleCredential = await _getGoogleCredential();
      return _authenticate(googleCredential);
    } catch (e) {
      return left(_handleAuthError(e));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithApple() async {
    try {
      firebase_auth.OAuthCredential appleCredential = await _getAppleCredential();
      return _authenticate(appleCredential);
    } catch (e) {
      return left(_handleAuthError(e));
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([_googleSignOutSafe(), _auth.signOut()]);
  }

  @override
  Future<Either<Failure, void>> delete() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return left(const AuthFailure('로그인 정보가 없습니다.'));

      // 삭제 순서 중요
      // 1. Firestore 데이터 삭제
      // TODO: Firestore 데이터 삭제 확인 필요
      await _firestore.collection('users').doc(user.uid).delete();

      // 2. Firebase Auth 계정 삭제
      await user.delete();

      // 3. Google SDK 정리
      try {
        await GoogleSignIn.instance.disconnect();
      } catch (e) {
        logger.d('Google disconnect 실패 (무시 가능)', error: e);
      }
      await _googleSignOutSafe();

      // 4. Firebase 정리
      await _auth.signOut();

      return right(null);
    } catch (e) {
      return left(_handleAuthError(e));
    }
  }

  @override
  Future<void> syncFcmToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final fcmToken = await _messaging.getToken();
      if (fcmToken == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'fcmTokens': FieldValue.arrayUnion([fcmToken]),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      logger.w('FCM 토큰 획득 실패', error: e);
    }
  }

  @override
  Future<Either<Failure, void>> reauthenticate() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return left(const AuthFailure('로그인 정보가 없습니다.'));

      final providerId = user.providerData.first.providerId;

      firebase_auth.AuthCredential? credential;
      logger.d('재인증 시도: Provider = $providerId');

      if (providerId == 'google.com') {
        // 구글 재로그인
        credential = await _getGoogleCredential();
      } else if (providerId == 'apple.com') {
        // 애플 재로그인 로직
        credential = await _getAppleCredential();
      } else {
        return left(const AuthFailure('지원하지 않는 로그인 방식입니다.'));
      }

      await user.reauthenticateWithCredential(credential);

      logger.d('재인증 성공');
      return right(null);
    } catch (e) {
      return left(_handleAuthError(e));
    }
  }

  // ===========================================================================
  // Private Helper Methods
  // ===========================================================================

  /// Google 로그인 로직
  Future<firebase_auth.OAuthCredential> _getGoogleCredential() async {
    logger.d('Google 로그인 시작');

    if (!_isGoogleSignInInitialized) {
      await GoogleSignIn.instance.initialize();
      _isGoogleSignInInitialized = true;
    }

    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw AuthFailure('Google 로그인을 지원하지 않는 기기입니다.');
    }

    final GoogleSignInAccount googleUser = await GoogleSignIn.instance
        .authenticate();

    final GoogleSignInAuthentication googleAuth = googleUser.authentication;
    final String? idToken = googleAuth.idToken;
    if (idToken == null) {
      throw AuthFailure('Google 로그인에 실패했습니다.');
    }

    final credential = firebase_auth.GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );
    logger.d('Google 로그인 성공');

    return credential;
  }

  /// Apple 로그인 로직
  Future<firebase_auth.OAuthCredential> _getAppleCredential() async {
    logger.d('Apple 로그인 시작');

    final rawNonce = _generateNonce();
    final sha256Nonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.fullName],
      nonce: sha256Nonce,
    );

    final credential = firebase_auth.OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
      rawNonce: rawNonce,
    );
    logger.d('Apple 로그인 성공');

    return credential;
  }

  /// Firebase Authentication 공통 메서드
  Future<Either<Failure, User>> _authenticate(
    firebase_auth.AuthCredential credential,
  ) async {
    try {
      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return left(const AuthFailure('인증 정보를 불러오지 못했습니다.'));
      }

      String? fcmToken;
      try {
        fcmToken = await _messaging.getToken();
      } catch (e) {
        logger.w('FCM 토큰 획득 실패', error: e);
      }

      final docRef = _firestore.collection('users').doc(firebaseUser.uid);
      final docSnapshot = await docRef.get();

      UserModel userModel;
      if (docSnapshot.exists) {
        // 기존 유저
        userModel = UserModel.fromJson(docSnapshot.data()!);

        if (fcmToken != null) {
          await docRef.update({
            'fcmTokens': FieldValue.arrayUnion([fcmToken]),
            'updatedAt': Timestamp.now(),
            'lastLoginAt': Timestamp.now(),
          });
        }
      } else {
        final name = firebaseUser.displayName ?? '이름 없음';

        // 신규 유저
        userModel = UserModel(
          id: firebaseUser.uid,
          name: name,
          fcmTokens: [],
          role: UserRole.none,
          storeIds: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await docRef.set(userModel.toJson());
      }

      return right(userModel.toEntity());
    } catch (e) {
      return left(_handleAuthError(e));
    }
  }

  Future<void> _googleSignOutSafe() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      logger.d('Google 로그아웃 실패 (무시 가능)', error: e);
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

  /// 에러 핸들링 메서드
  Failure _handleAuthError(Object e) {
    logger.e('Auth 처리 실패', error: e);

    if (e is PlatformException) {
      if (e.code == 'sign_in_canceled' || e.code == 'canceled') {
        return const IgnoreableFailure();
      }
    }

    if (e is AuthFailure) {
      return e;
    }

    if (e is firebase_auth.FirebaseAuthException) {
      switch (e.code) {
        // 재로그인이 필요할 때
        case 'requires-recent-login':
          return const RequiresRecentLoginFailure();

        // Google/Apple 토큰이 유효하지 않을 때
        case 'invalid-credential':
        case 'invalid-token':
          return const AuthFailure('인증 정보가 유효하지 않습니다.\n다시 시도해 주세요.');

        // 계정이 정지된 경우
        case 'user-disabled':
          return const AuthFailure('해당 계정은 비활성화되었습니다.\n개발자에게 문의하세요.');

        // Firebase 콘솔에서 해당 소셜 로그인을 켜지 않았을 때
        case 'operation-not-allowed':
          return const AuthFailure('로그인 제공업체가 활성화되지 않았습니다.');

        // 네트워크 이슈
        case 'network-request-failed':
          return const AuthFailure('네트워크 연결이 불안정합니다.\n인터넷 상태를 확인해 주세요.');

        // 그 외
        default:
          return AuthFailure('로그인에 실패했습니다.\n(${e.code})');
      }
    }
    return AuthFailure(e.toString());
  }
}
