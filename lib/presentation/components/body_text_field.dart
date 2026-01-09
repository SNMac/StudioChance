import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BodyTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;

  const BodyTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.autofocus = false,
    this.inputFormatters,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: textTheme.bodyLarge?.copyWith(
            color: colorScheme.outlineVariant,
          ),
          filled: true,
          fillColor: CupertinoDynamicColor.resolve(
            CupertinoColors.secondarySystemGroupedBackground,
            context,
          ),
          contentPadding: const EdgeInsets.all(0),
          border: OutlineInputBorder(borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
