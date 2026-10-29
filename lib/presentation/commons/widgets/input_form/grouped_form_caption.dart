import 'package:material_ui/material_ui.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

/// [GroupedFormContainer]의 header·footer에 넣는 회색 설명 글.
///
/// header면 카드 위에, footer면 카드 아래에 붙도록 여백 방향만 다르다.
class GroupedFormCaption extends StatelessWidget {
  const GroupedFormCaption.header(this.text, {super.key}) : _isHeader = true;

  const GroupedFormCaption.footer(this.text, {super.key}) : _isHeader = false;

  final String text;
  final bool _isHeader;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        horizontalPadding,
        _isHeader ? 0 : 4,
        horizontalPadding,
        _isHeader ? 4 : 0,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: context.secondaryLabel),
      ),
    );
  }
}
