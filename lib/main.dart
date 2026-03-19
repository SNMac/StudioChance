import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:studio_chance/domain/use_cases/auth_use_case.dart';
import 'package:studio_chance/my_app.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final provideAndroid = kDebugMode
      ? AndroidDebugProvider()
      : AndroidPlayIntegrityProvider();

  final provideApple = kDebugMode
      ? AppleDebugProvider()
      : AppleAppAttestProvider();

  await FirebaseAppCheck.instance.activate(
    providerAndroid: provideAndroid,
    providerApple: provideApple,
  );

  await _setPreferredOrientations();
  await _checkFirstLaunchAndClearData();

  runApp(ProviderScope(child: const MyApp()));
}

Future<void> _setPreferredOrientations() {
  return SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

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
