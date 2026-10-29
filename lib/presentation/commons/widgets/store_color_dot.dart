import 'package:material_ui/material_ui.dart';

import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/presentation/commons/extensions/store_color_extensions.dart';

/// 점포 색상 점 (8×8)
class StoreColorDot extends StatelessWidget {
  const StoreColorDot({super.key, required this.color});

  final StoreColor color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(color.foregroundColorValue),
      ),
    );
  }
}
