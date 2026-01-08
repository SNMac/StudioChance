import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BodyTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final void Function(String)? onChanged;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;

  const BodyTextField({
    super.key,
    this.controller,
    required this.hintText,
    this.onChanged,
    this.autofocus = false,
    this.inputFormatters,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: CupertinoDynamicColor.resolve(
              CupertinoColors.tertiaryLabel,
              context,
            ),
          ),
          filled: true,
          fillColor: CupertinoDynamicColor.resolve(
            CupertinoColors.secondarySystemGroupedBackground,
            context,
          ),
          contentPadding: const EdgeInsets.all(0),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
