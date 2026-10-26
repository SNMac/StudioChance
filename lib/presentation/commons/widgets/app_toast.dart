import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/colors.dart';

const Duration _toastDuration = Duration(seconds: 2);

/// 나타날 때·사라질 때 페이드 시간
const Duration _toastFadeDuration = Duration(milliseconds: 200);
const EdgeInsets _toastPadding = EdgeInsets.symmetric(
  horizontal: 20,
  vertical: 12,
);

/// 하단 탭바(또는 키보드)와 캡슐 사이 간격
const double _toastGap = 24;

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
///
/// Material 3 floating SnackBar는 아래에서 위로 펼쳐지며 등장하므로 SnackBar 애니메이션은 끄고
/// 투명한 SnackBar 안에서 캡슐이 직접 페이드 인·아웃한다.
void showAppToast(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  // 화면 크기와 키보드 높이는 앱 최상단 기준으로 읽는다 — 화면 Scaffold 안쪽에서는 키보드 높이가 지워진다
  final appMediaQuery = MediaQuery.of(messenger.context);
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final capsuleColor = isDark ? toastBackgroundDarkColor : toastBackgroundColor;
  final textStyle = Theme.of(context).textTheme.bodyMedium
      ?.copyWith(color: toastTextColor);

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

  // floating SnackBar는 화면 아래에서 하단 안전 영역(viewPadding)만큼 올라간 선을 기준으로 놓인다.
  // 키보드 높이(viewInsets)는 화면 맨 아래부터 재므로 그 안전 영역을 이미 포함하고, 키보드가 떠 있으면
  // 탭바도 가려지므로 둘 다 빼야 키보드 바로 위에 뜬다
  final keyboardHeight = appMediaQuery.viewInsets.bottom;
  final bottomMargin = keyboardHeight > 0
      ? math.max(keyboardHeight - appMediaQuery.viewPadding.bottom, 0.0) +
            _toastGap
      : tabBarHeight + _toastGap;

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: _ToastCapsule(
          message: message,
          style: textStyle,
          color: capsuleColor,
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        margin: EdgeInsets.fromLTRB(sideMargin, 0, sideMargin, bottomMargin),
        duration: _toastDuration,
      ),
      snackBarAnimationStyle: AnimationStyle.noAnimation,
    );
}

/// 표시 시간 동안 페이드 인 → 유지 → 페이드 아웃하는 캡슐
class _ToastCapsule extends StatefulWidget {
  const _ToastCapsule({
    required this.message,
    required this.style,
    required this.color,
  });

  final String message;
  final TextStyle? style;
  final Color color;

  @override
  State<_ToastCapsule> createState() => _ToastCapsuleState();
}

class _ToastCapsuleState extends State<_ToastCapsule>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _toastDuration,
  )..forward();

  /// 표시 시간 전체를 0→1로 보고, 앞뒤 [_toastFadeDuration]만 페이드한다
  late final Animation<double> _opacity = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 0.0, end: 1.0),
      weight: _toastFadeDuration.inMilliseconds.toDouble(),
    ),
    TweenSequenceItem(
      tween: ConstantTween(1.0),
      weight: (_toastDuration - _toastFadeDuration * 2).inMilliseconds
          .toDouble(),
    ),
    TweenSequenceItem(
      tween: Tween(begin: 1.0, end: 0.0),
      weight: _toastFadeDuration.inMilliseconds.toDouble(),
    ),
  ]).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: const StadiumBorder(),
          color: widget.color,
        ),
        child: Padding(
          padding: _toastPadding,
          child: Text(
            widget.message,
            style: widget.style,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
