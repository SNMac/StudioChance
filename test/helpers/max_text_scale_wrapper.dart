import 'package:material_ui/material_ui.dart';

import 'package:studio_chance/constants/ui_constants.dart';

/// 큰 글자 배율 레이아웃 테스트에서 확인할 화면 폭.
///
/// 320은 가장 좁은 Android 기기, 375는 iOS 최소 지원 기기(iPhone SE) 논리 폭이다.
const maxTextScaleTestScreenWidths = [320.0, 375.0];

/// [child]를 앱 상한 배율([maxTextScaleFactor])로 렌더링한다.
///
/// 폭은 모달 시트의 폼 컨테이너와 같다 — 화면 폭에서 시트 좌우 여백
/// ([horizontalPadding])을 뺀 값. 배율은 `builder`로 Navigator 위에 걸어 팝업 메뉴처럼
/// 새 라우트로 뜨는 요소에도 적용된다.
///
/// 테스트 폰트는 글자마다 1em 폭이라 Pretendard보다 넓게 측정된다. 여기서 넘치지
/// 않으면 실기기에서도 넘치지 않는다.
Widget wrapAtMaxTextScale(Widget child, {required double screenWidth}) {
  return MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(maxTextScaleFactor)),
      child: child!,
    ),
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: screenWidth - horizontalPadding * 2,
          child: child,
        ),
      ),
    ),
  );
}
