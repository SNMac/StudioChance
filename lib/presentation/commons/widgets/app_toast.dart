import 'package:flutter/material.dart';

import 'package:studio_chance/constants/ui_constants.dart';

const Duration _toastDuration = Duration(seconds: 2);
const EdgeInsets _toastPadding = EdgeInsets.symmetric(
  horizontal: 20,
  vertical: 12,
);

/// 하단 탭바 위로 띄우는 간격
const double _toastGapAboveTabBar = 24;

/// 앱 전체를 감싸는 바깥 Scaffold — `MaterialApp.builder`에서 Navigator를 감싼다.
///
/// ScaffoldMessenger는 중첩된 Scaffold 중 가장 바깥 것에만 SnackBar를 그린다. 이 Scaffold가
/// Navigator보다 위에 있으므로 [showAppToast]는 바텀시트·다이얼로그를 포함한 모든 화면 위에 뜬다.
class ToastHost extends StatelessWidget {
  const ToastHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 키보드 여백은 각 화면의 Scaffold가 처리한다 — 여기서도 줄이면 앱 전체가 이중으로 줄어든다
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: child,
    );
  }
}

/// 회색 캡슐 안에 짧은 알림을 띄운다 (예전 안드로이드 Toast 형태).
///
/// [ToastHost] 아래에서 호출하면 어떤 화면·모달 위에서든 보인다. 캡슐은 글자 폭만큼만
/// 차지해 바깥 터치를 막지 않으며, 키보드가 떠 있으면 키보드 위로 올라간다.
void showAppToast(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  // 화면 크기와 키보드 높이는 앱 최상단 기준으로 읽는다 — 화면 Scaffold 안쪽에서는 키보드 높이가 지워진다
  final appMediaQuery = MediaQuery.of(messenger.context);
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final textStyle = Theme.of(
    context,
  ).textTheme.bodyMedium?.copyWith(color: Colors.white);

  final maxTextWidth =
      appMediaQuery.size.width -
      horizontalPadding * 2 -
      _toastPadding.horizontal;
  final painter = TextPainter(
    text: TextSpan(text: message, style: textStyle),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
    maxLines: 2,
  )..layout(maxWidth: maxTextWidth);
  // 반올림 오차로 줄바꿈되지 않게 여유를 둔다
  final capsuleWidth =
      painter.width.ceilToDouble() + 2 + _toastPadding.horizontal;
  painter.dispose();
  final sideMargin = (appMediaQuery.size.width - capsuleWidth) / 2;

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message, style: textStyle, textAlign: TextAlign.center),
        behavior: SnackBarBehavior.floating,
        shape: const StadiumBorder(),
        backgroundColor: isDark
            ? const Color(0xE6595959)
            : const Color(0xE6323232),
        elevation: 0,
        padding: _toastPadding,
        margin: EdgeInsets.fromLTRB(
          sideMargin,
          0,
          sideMargin,
          tabBarHeight + _toastGapAboveTabBar + appMediaQuery.viewInsets.bottom,
        ),
        duration: _toastDuration,
      ),
    );
}
