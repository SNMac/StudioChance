import 'package:flutter/foundation.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'package:studio_chance/bootstrap.dart';
import 'package:studio_chance/data/data_sources/remote_config.dart';

import 'firebase_options_prod.dart';

void main() => bootstrap(
  firebaseOptions: DefaultFirebaseOptions.currentPlatform,
  configureFlavor: () async {
    // prod 플레이버: 릴리즈는 프로덕션 Provider, 디버그는 디버그 토큰 사용
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kDebugMode
          ? AndroidDebugProvider()
          : AndroidPlayIntegrityProvider(),
      providerApple: kDebugMode
          ? AppleDebugProvider()
          : AppleAppAttestProvider(),
    );

    // 콘솔에서 바꾼 값은 마지막으로 가져온 지 24시간이 지난 뒤 앱을 다시 실행할 때 반영된다.
    // 바꿀 값은 OCR 모델 ID뿐이고 모델 교체는 수개월 단위라 Firebase 권장(12시간)보다 길게 둔다
    await initializeRemoteConfig(
      minimumFetchInterval: const Duration(hours: 24),
    );
  },
);
