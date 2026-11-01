import 'package:material_ui/material_ui.dart';

import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

class AppBarActionButton extends StatelessWidget {
  final String label;
  final TextStyle? style;
  final VoidCallback? onPressed;

  /// true: FontWeight.normal (regular), false: FontWeight.w600 (semibold)
  final bool isRegularWeight;

  const AppBarActionButton({
    super.key,
    required this.label,
    this.style,
    this.onPressed,
    this.isRegularWeight = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final baseStyle = style ?? textTheme.titleLarge;

    final color = onPressed != null
        ? colorScheme.primary
        : context.quaternaryLabel;

    final effectiveStyle = baseStyle?.copyWith(
      color: color,
      fontWeight: isRegularWeight ? FontWeight.normal : FontWeight.w600,
    );

    // 글자 배율 1.0 고정 (#58): ModalAppBar의 leadingWidth(60)와 iOS toolbarHeight(44)가
    // 고정이라 커지면 "취소"가 "취/소"로 줄바꿈되고 세로로 잘린다. iOS 내비게이션 바 버튼도
    // Dynamic Type을 따르지 않는다. 제목은 AppBar가 자체 상한(1.34)으로 키운다
    return MediaQuery.withNoTextScaling(
      child: TextButton(
        onPressed: onPressed,
        child: Text(label, style: effectiveStyle),
      ),
    );
  }
}
