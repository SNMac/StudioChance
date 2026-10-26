import 'package:firebase_app_check/firebase_app_check.dart';

import 'package:studio_chance/bootstrap.dart';
import 'package:studio_chance/data/data_sources/remote_config.dart';

import 'firebase_options_dev.dart';

void main() => bootstrap(
  firebaseOptions: DefaultFirebaseOptions.currentPlatform,
  configureFlavor: () async {
    // dev 플레이버는 항상 디버그 AppCheck Provider 사용
    await FirebaseAppCheck.instance.activate(
      providerAndroid: AndroidDebugProvider(),
      providerApple: AppleDebugProvider(),
    );

    // 모델 변경을 확인하기 쉽도록 prod(24시간)보다 짧게 둔다
    await initializeRemoteConfig(
      minimumFetchInterval: const Duration(minutes: 5),
    );
  },
);
