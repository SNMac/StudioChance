import 'package:flutter/material.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

class TitleTextLabel extends StatelessWidget {
  final String title;
  final String content;

  const TitleTextLabel({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: horizontalPadding,
      ),
      child: SizedBox(
        height: inputFormComponentHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 4,
          children: [
            Text(title, style: textTheme.bodyLarge),
            Expanded(
              child: Text(
                content,
                textAlign: TextAlign.end,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.normal,
                  color: context.label,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
