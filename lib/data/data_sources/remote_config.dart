import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'remote_config.g.dart';

/// OCR에 쓸 Gemini 모델 ID. 모델이 지원 종료돼도 앱 업데이트 없이 콘솔에서 바꾼다.
/// 바꾸는 절차는 docs/operations.md의 "OCR 모델 변경"
const ocrModelNameKey = 'ocr_model_name';

/// 콘솔 값을 아직 가져오지 못했거나 비어 있을 때 쓰는 모델
const defaultOcrModelName = 'gemini-3.5-flash-lite';

/// 콘솔 값이 비어 있으면 [defaultOcrModelName]을 쓴다.
/// 잘못된 모델 ID는 그대로 둔다 — 기본값으로 몰래 돌리면 설정 오류가 드러나지 않는다.
String resolveOcrModelName(String remoteValue) {
  final trimmed = remoteValue.trim();
  return trimmed.isEmpty ? defaultOcrModelName : trimmed;
}

/// 지금 활성화된 값으로 OCR 모델 ID를 읽는다. 네트워크 없이 캐시에서 읽는다.
String readOcrModelName(FirebaseRemoteConfig remoteConfig) =>
    resolveOcrModelName(remoteConfig.getString(ocrModelNameKey));

/// 기본값을 등록하고 콘솔 값을 백그라운드로 가져온다.
/// 앱 시작을 기다리게 하지 않으므로, 이번 실행의 첫 OCR은 이전 실행에서 가져온 값이나 기본값을 쓴다.
Future<void> initializeRemoteConfig({
  required Duration minimumFetchInterval,
}) async {
  final logger = Logger();
  final remoteConfig = FirebaseRemoteConfig.instance;

  await remoteConfig.setConfigSettings(
    RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: minimumFetchInterval,
    ),
  );
  await remoteConfig.setDefaults(const {ocrModelNameKey: defaultOcrModelName});

  unawaited(
    remoteConfig
        .fetchAndActivate()
        .then((_) {
          logger.i(
            'Remote Config 적용 - $ocrModelNameKey: '
            '${remoteConfig.getString(ocrModelNameKey)}',
          );
        })
        .catchError((Object e) {
          logger.w('Remote Config 가져오기 실패 - 캐시 또는 기본값 사용', error: e);
        }),
  );
}

@Riverpod(keepAlive: true)
FirebaseRemoteConfig remoteConfig(Ref ref) {
  return FirebaseRemoteConfig.instance;
}
