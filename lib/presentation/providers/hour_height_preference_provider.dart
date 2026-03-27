import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/ui_constants.dart';

part 'hour_height_preference_provider.g.dart';

const _kHourHeightKey = 'hour_height_preference';

/// SharedPreferences 인스턴스 Provider
@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  return SharedPreferences.getInstance();
}

/// hourHeight 값을 SharedPreferences에 저장
Future<void> saveHourHeight(SharedPreferences prefs, double height) async {
  await prefs.setDouble(_kHourHeightKey, height);
}

/// hourHeight 값을 SharedPreferences에서 불러옴 (없으면 기본값 반환)
/// clamp 적용: 저장된 값이 범위 밖일 경우(예: 이전 minHourHeight=18 기기) 보정
double loadHourHeight(SharedPreferences prefs) {
  final saved = prefs.getDouble(_kHourHeightKey) ?? defaultHourHeight;
  return saved.clamp(minHourHeight, maxHourHeight);
}
