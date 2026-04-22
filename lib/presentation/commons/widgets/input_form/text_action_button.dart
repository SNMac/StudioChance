import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

/// iOS plain text button 스타일.
/// 투명 배경 + systemBlue + titleMedium, 텍스트 중앙 정렬.
class TextActionButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;

  const TextActionButton({super.key, required this.title, this.onPressed});

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
            color: context.systemBlue,
          ),
        ),
      ),
    );
  }
}
