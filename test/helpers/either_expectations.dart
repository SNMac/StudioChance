import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

/// 성공(Right)이어야 하는 결과의 값을 꺼낸다. 실패(Left)면 그 예외를 담아 테스트를 실패시킨다.
///
/// CLAUDE.md의 Either 규칙(`isRight()`·`getRight().toNullable()` 같은 명령형 스타일 금지)을
/// 테스트에서도 지키기 위한 헬퍼다.
R expectRight<L, R>(Either<L, R> result) => result.fold<R>(
  (error) => fail('Right를 기대했지만 Left였다: $error'),
  (value) => value,
);

/// 실패(Left)여야 하는 결과의 예외를 꺼낸다. 성공(Right)이면 테스트를 실패시킨다.
L expectLeft<L, R>(Either<L, R> result) => result.fold<L>(
  (error) => error,
  (value) => fail('Left를 기대했지만 Right였다: $value'),
);
