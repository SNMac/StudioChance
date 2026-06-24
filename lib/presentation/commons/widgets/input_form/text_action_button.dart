import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

/// iOS plain text button 스타일.
/// 투명 배경 + titleMedium, 텍스트 중앙 정렬.
/// [isDestructive]가 true이면 systemRed, 아니면 systemBlue.
class TextActionButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final bool isDestructive;
  final FontWeight? fontWeight;

  const TextActionButton({
    super.key,
    required this.title,
    this.onPressed,
    this.isDestructive = false,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: inputFormComponentHeight,
      width: double.infinity,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: isDestructive ? context.systemRed : context.systemBlue,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }
}
