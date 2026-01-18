import 'package:flutter/material.dart';

import 'package:studio_chance/constants/ui_constants.dart';

class TitleSwitchButton extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const TitleSwitchButton({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: inputFormComponentHeight,
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(horizontal: horizontalPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(title, style: textTheme.bodyLarge)),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              padding: const EdgeInsetsDirectional.all(0),
            ),
          ],
        ),
      ),
    );
  }
}
