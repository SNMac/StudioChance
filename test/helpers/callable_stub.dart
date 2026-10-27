import 'package:mocktail/mocktail.dart';

import 'mocks.dart';

/// [functions]의 [name] Callable이 [data]를 응답하게 하고 그 Callable 목을 돌려준다.
///
/// Android 플랫폼 채널처럼 `Map<Object?, Object?>`를 넘기면 앱의 방어적 변환까지 검증된다.
MockHttpsCallable stubCallable(
  MockFirebaseFunctions functions,
  String name,
  Object? data,
) {
  final callable = MockHttpsCallable();
  final result = MockHttpsCallableResult();
  when(() => result.data).thenReturn(data);
  when(() => callable.call<dynamic>(any())).thenAnswer((_) async => result);
  when(() => functions.httpsCallable(name)).thenReturn(callable);
  return callable;
}
