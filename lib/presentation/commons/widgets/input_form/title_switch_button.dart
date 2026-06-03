import 'package:flutter/material.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

class TitleSwitchButton extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const TitleSwitchButton({
    super.key,
    required this.title,
    required this.value,
    this.onChanged,
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
            Expanded(
              child: Text(
                title,
                style: textTheme.bodyLarge?.copyWith(
                  color: onChanged != null
                      ? context.label
                      : context.tertiaryLabel,
                ),
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: onChanged == null
                  ? null
                  : (val) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      onChanged!(val);
                    },
              padding: const EdgeInsetsDirectional.all(0),
            ),
          ],
        ),
      ),
    );
  }
}
