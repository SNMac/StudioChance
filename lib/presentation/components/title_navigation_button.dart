import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, style: textTheme.bodyLarge),
            Row(
              spacing: 16,
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
                Icon(
                  CupertinoIcons.chevron_forward,
                  fontWeight: FontWeight.w600,
                  color: CupertinoDynamicColor.resolve(
                    CupertinoColors.tertiaryLabel,
                    context,
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
