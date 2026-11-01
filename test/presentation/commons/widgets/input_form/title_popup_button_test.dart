import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_popup_button.dart';

import '../../../../helpers/max_text_scale_wrapper.dart';

/// `store_form_screen`의 `LengthLimitingTextInputFormatter(15)`가 허용하는
/// 최대 길이 점포명.
const _maxLengthStoreName = '스튜디오찬스수원영통구중부대로점';

void main() {
  group('TitlePopupButton 큰 글자 배율', () {
    for (final width in maxTextScaleTestScreenWidths) {
      testWidgets('최대 길이 점포명이어도 ${width.toInt()}pt에서 행과 팝업 메뉴가 넘치지 않는다', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrapAtMaxTextScale(
            // 예약 모달과 같이 행 좌우 패딩을 붙인다
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: horizontalPadding,
              ),
              child: TitlePopupButton<String>(
                title: '예약 점포',
                selectedValue: _maxLengthStoreName,
                items: const [_maxLengthStoreName, '스페이스클라우드'],
                itemLabelBuilder: (s) => s,
                itemLeadingBuilder: (_) => const SizedBox(width: 8, height: 8),
                onSelected: (_) {},
              ),
            ),
            screenWidth: width,
          ),
        );
        expect(tester.takeException(), isNull);

        await tester.tap(find.byType(TitlePopupButton<String>));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });
}
