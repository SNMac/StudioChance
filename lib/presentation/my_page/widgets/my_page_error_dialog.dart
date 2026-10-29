import 'package:material_ui/material_ui.dart';

import 'package:studio_chance/common/exceptions/app_exception.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_alert_dialog.dart';

/// [home_screen.dart]의 에러 다이얼로그 패턴과 동일하게, silentable하지 않은
/// 에러만 사용자에게 알린다. 마이페이지 아래 화면들이 공유한다.
void showMyPageErrorDialog(BuildContext context, Object error) {
  if (!context.mounted) return;
  if (error is AppException && !error.isSilentable) {
    showCustomAlertDialog(
      context: context,
      title: error.title,
      content: error.content,
      showCancel: false,
    );
  } else if (error is! AppException) {
    showCustomAlertDialog(
      context: context,
      title: '오류',
      content: '잠시 후 다시 시도해 주세요.',
      showCancel: false,
    );
  }
}
