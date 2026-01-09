import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studio_chance/presentation/components/body_text_field.dart';

class TitleTextField extends StatelessWidget {
  final String title;
  final String? hintText;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;

  const TitleTextField({
    super.key,
    required this.title,
    this.hintText,
    this.controller,
    this.onChanged,
    this.autofocus = false,
    this.inputFormatters,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: textTheme.bodyLarge),
          Expanded(
            child: BodyTextField(
              hintText: hintText ?? title,
              controller: controller,
              textAlign: TextAlign.end,
              autofocus: autofocus,
              onChanged: onChanged,
              inputFormatters: inputFormatters,
              keyboardType: keyboardType,
            ),
          ),
        ],
      ),
    );
  }
}
