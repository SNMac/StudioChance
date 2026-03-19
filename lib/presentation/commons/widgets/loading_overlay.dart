import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  /// 로딩 상태 여부
  final bool isLoading;

  /// 애니메이션 지속 시간 (기본값: 200ms)
  final Duration duration;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    final color = CupertinoColors.black.withValues(
      alpha: isDarkMode ? 0.5 : 0.2,
    );

    return AnimatedSwitcher(
      duration: duration,
      child: isLoading
          ? Container(
              key: const ValueKey('loading_overlay_container'),
              color: color,
              child: const Center(child: CircularProgressIndicator.adaptive()),
            )
          : const SizedBox.shrink(),
    );
  }
}
