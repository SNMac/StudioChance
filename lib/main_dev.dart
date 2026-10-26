import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:studio_chance/data/data_sources/remote_config.dart';
import 'package:studio_chance/domain/use_cases/auth_use_case_provider.dart';
import 'package:studio_chance/my_app.dart';

import 'firebase_options_dev.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  _reportUncaughtErrorsToCrashlytics();

  // dev 플레이버는 항상 디버그 AppCheck Provider 사용
  await FirebaseAppCheck.instance.activate(
    providerAndroid: AndroidDebugProvider(),
    providerApple: AppleDebugProvider(),
  );

  // 모델 변경을 확인하기 쉽도록 prod(24시간)보다 짧게 둔다
  await initializeRemoteConfig(
    minimumFetchInterval: const Duration(minutes: 5),
  );

  await _setPreferredOrientations();
  await _checkFirstLaunchAndClearData();

  runApp(ProviderScope(child: const MyApp()));
}

/// 처리되지 않은 Dart 오류를 Crashlytics에 보낸다 (Firebase 초기화 이후 호출)
///
/// Crashlytics가 스스로 잡는 것은 네이티브 크래시뿐이다. Dart 오류는 앱을 죽이지 않아
/// 이 연결이 없으면 기록되지 않는다
void _reportUncaughtErrorsToCrashlytics() {
  // recordFlutterFatalError는 콘솔 출력(FlutterError.presentError)도 유지한다
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // 프레임워크 밖의 비동기 오류. true를 돌려주면 기본 콘솔 출력이 사라지므로 직접 남긴다
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    Logger().e('처리되지 않은 오류', error: error, stackTrace: stackTrace);
    FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
    return true;
  };
}

Future<void> _setPreferredOrientations() {
  return SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

/// 앱 설치 후 첫 실행이면 남아 있는 인증 데이터를 지운다 (D9)
Future<void> _checkFirstLaunchAndClearData() async {
  final Logger logger = Logger();
  final prefs = await SharedPreferences.getInstance();

  final hasLaunchedBefore = prefs.getBool('hasLaunchedBefore') ?? false;

  if (!hasLaunchedBefore) {
    final container = ProviderContainer();

    try {
      await container.read(authUseCaseProvider).signOut();
      logger.i('앱 최초 실행 감지 - 기존 인증 데이터 삭제');
    } catch (e) {
      logger.e('기존 인증 데이터 삭제 중 에러 발생', error: e);
    } finally {
      container.dispose();
    }

    await prefs.setBool('hasLaunchedBefore', true);
  }
}
