import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:studio_chance/constants/ui_constants.dart';

class TitleNavigationButton extends StatelessWidget {
  final String title;
  final String? content;
  final VoidCallback onPressed;

  const TitleNavigationButton({
    super.key,
    required this.title,
    this.content,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 48,
      child: CupertinoButton(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, style: textTheme.bodyLarge),
            Row(
              spacing: 12,
              children: [
                if (content != null)
                  Text(
                    content!,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.normal,
                      color: CupertinoDynamicColor.resolve(
                        CupertinoColors.secondaryLabel,
                        context,
                      ),
                    ),
                  ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 10),
                  child: Icon(
                    CupertinoIcons.chevron_forward,
                    color: CupertinoDynamicColor.resolve(
                      CupertinoColors.tertiaryLabel,
                      context,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
