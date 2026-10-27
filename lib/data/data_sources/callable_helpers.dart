import 'package:cloud_functions/cloud_functions.dart';

extension CallableMapResponse on FirebaseFunctions {
  /// Callable [name]을 호출하고 응답을 `Map<String, dynamic>`으로 돌려준다.
  ///
  /// Android 플랫폼 채널은 `Map<Object?, Object?>`를 돌려주므로 제네릭 캐스트가
  /// 런타임에 깨질 수 있다. 제네릭 없이 호출하고 방어적으로 변환한다.
  /// 응답 안의 중첩 Map도 같은 이유로 [Map.from]을 거쳐 읽어야 한다.
  Future<Map<String, dynamic>> callForMap(
    String name, [
    Map<String, dynamic>? parameters,
  ]) async {
    final response = await httpsCallable(name).call(parameters);
    return Map<String, dynamic>.from(response.data as Map);
  }
}

/// Callable이 시각을 밀리초로 보낸 값을 [DateTime]으로 옮긴다.
/// Timestamp는 Callable 응답 JSON으로 그대로 직렬화되지 않아 밀리초로 주고받는다.
DateTime dateTimeFromCallableMillis(Object? millis) =>
    DateTime.fromMillisecondsSinceEpoch((millis as num).toInt());
