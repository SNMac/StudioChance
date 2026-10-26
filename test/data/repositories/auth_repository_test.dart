import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/common/exceptions/auth_exceptions.dart';
import 'package:studio_chance/data/data_sources/auth_data_source.dart';
import 'package:studio_chance/data/repositories/auth_repository_impl.dart';

import '../../helpers/either_expectations.dart';
import '../../helpers/mocks.dart';

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthDataSource mockAuthDs;
  late List<String> recordedReasons;

  const appleToken = AppleAuthorizationCode('code-123');

  setUpAll(() {
    registerFallbackValue(appleToken);
  });

  setUp(() {
    mockAuthDs = MockAuthDataSource();
    recordedReasons = [];
    repository = AuthRepositoryImpl(
      authDataSource: mockAuthDs,
      recordNonFatalError: (error, stackTrace, reason) async {
        recordedReasons.add(reason);
      },
    );
  });

  group('prepareDeletion', () {
    test('Google로 재인증하면 revoke 없이 성공한다', () async {
      when(() => mockAuthDs.reauthenticate()).thenAnswer((_) async => null);

      final result = await repository.prepareDeletion();

      expectRight(result);
      verifyNever(() => mockAuthDs.revokeAppleToken(any()));
    });

    test('Apple로 재인증하면 받은 값으로 revoke한다', () async {
      when(() => mockAuthDs.reauthenticate())
          .thenAnswer((_) async => appleToken);
      when(() => mockAuthDs.revokeAppleToken(any())).thenAnswer((_) async {});

      final result = await repository.prepareDeletion();

      expectRight(result);
      verify(() => mockAuthDs.revokeAppleToken(appleToken)).called(1);
      expect(recordedReasons, isEmpty);
    });

    test('재인증이 실패하면 left를 반환하고 revoke하지 않는다', () async {
      when(() => mockAuthDs.reauthenticate())
          .thenThrow(AuthRequiresRecentLoginException(message: '재인증 필요'));

      final result = await repository.prepareDeletion();

      expect(expectLeft(result), isA<AuthRequiresRecentLoginException>());
      verifyNever(() => mockAuthDs.revokeAppleToken(any()));
    });

    test('revoke 중 취소하면 계정 삭제를 멈춘다', () async {
      when(() => mockAuthDs.reauthenticate())
          .thenAnswer((_) async => appleToken);
      when(() => mockAuthDs.revokeAppleToken(any()))
          .thenThrow(AuthCancelledException(message: '취소'));

      final result = await repository.prepareDeletion();

      expect(expectLeft(result), isA<AuthCancelledException>());
      expect(recordedReasons, isEmpty);
    });

    test('revoke 중 네트워크 오류면 계정 삭제를 멈춘다', () async {
      when(() => mockAuthDs.reauthenticate())
          .thenAnswer((_) async => appleToken);
      when(() => mockAuthDs.revokeAppleToken(any()))
          .thenThrow(AuthNetworkException(message: '네트워크 오류'));

      final result = await repository.prepareDeletion();

      expect(expectLeft(result), isA<AuthNetworkException>());
      expect(recordedReasons, isEmpty);
    });

    // Firebase 콘솔의 Apple 설정 오류처럼 계속 반복되는 실패로 계정 삭제가 막히지 않게 한다
    test('그 밖의 revoke 실패는 기록하고 계정 삭제를 계속한다', () async {
      when(() => mockAuthDs.reauthenticate())
          .thenAnswer((_) async => appleToken);
      when(() => mockAuthDs.revokeAppleToken(any()))
          .thenThrow(AuthUnknownException(message: 'invalid_client'));

      final result = await repository.prepareDeletion();

      expectRight(result);
      expect(recordedReasons, hasLength(1));
    });

    test('Crashlytics 기록이 실패해도 계정 삭제를 계속한다', () async {
      repository = AuthRepositoryImpl(
        authDataSource: mockAuthDs,
        recordNonFatalError: (error, stackTrace, reason) async =>
            throw Exception('Crashlytics 오류'),
      );
      when(() => mockAuthDs.reauthenticate())
          .thenAnswer((_) async => appleToken);
      when(() => mockAuthDs.revokeAppleToken(any()))
          .thenThrow(AuthUnknownException(message: 'invalid_client'));

      final result = await repository.prepareDeletion();

      expectRight(result);
    });
  });
}
