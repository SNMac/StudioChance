import 'package:flutter/material.dart';
import 'package:studio_chance/domain/enums/store_color.dart';
import 'package:studio_chance/presentation/components/grouped_form_container.dart';
import 'package:studio_chance/presentation/components/input_form_selection_button.dart';

class StoreColorInputView extends StatefulWidget {
  const StoreColorInputView({super.key});

  @override
  State<StoreColorInputView> createState() => _StoreColorInputViewState();
}

class _StoreColorInputViewState extends State<StoreColorInputView> {
  StoreColor selectedColor = StoreColor.red;

  @override
  Widget build(BuildContext context) {
    return GroupedFormContainer(
      children: StoreColor.values.map((color) {
        return InputFormSelectionButton<StoreColor>(
          value: color,
          label: color.displayName,
          isSelected: selectedColor == color,
          leading: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Color(color.foregroundColorValue),
              shape: BoxShape.circle,
            ),
          ),
          onPressed: () {
            setState(() {
              selectedColor = color;
            });
          },
        );
      }).toList(),
    );
  }
}
