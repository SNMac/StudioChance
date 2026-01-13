import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:studio_chance/constants/ui_constants.dart';

class InputFormBodyTextField extends StatelessWidget {
  final String placeholder;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final int? maxLines;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;

  const InputFormBodyTextField({
    super.key,
    required this.placeholder,
    this.controller,
    this.onChanged,
    required this.maxLines,
    this.autofocus = false,
    this.inputFormatters,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: CupertinoTextField.borderless(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        placeholder: placeholder,
        placeholderStyle: textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.normal,
          color: CupertinoDynamicColor.resolve(
            CupertinoColors.secondaryLabel,
            context,
          ),
        ),
        cursorHeight: 20,
        controller: controller,
        textAlignVertical: TextAlignVertical.center,
        maxLines: maxLines,
        autofocus: autofocus,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal),
      ),
    );
  }
}
