import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:studio_chance/presentation/commons/widgets/input_form/title_text_label.dart';

import '../../../../helpers/max_text_scale_wrapper.dart';

/// `formattedDateTime`이 만드는 가장 긴 형태 (두 자리 월·일, 요일, 시각).
const _dateTime = '2026. 11. 01. (일) 22:00';

void main() {
  group('TitleTextLabel 큰 글자 배율', () {
    for (final width in maxTextScaleTestScreenWidths) {
      testWidgets(
        'scaleDownToFit이면 ${width.toInt()}pt에서 일시가 잘리지 않고 행 안에 들어간다',
        (tester) async {
          await tester.pumpWidget(
            wrapAtMaxTextScale(
              const TitleTextLabel(
                title: '입실 일시',
                content: _dateTime,
                scaleDownToFit: true,
              ),
              screenWidth: width,
            ),
          );

          expect(tester.takeException(), isNull);
          final paragraph = tester.renderObject<RenderParagraph>(
            find.text(_dateTime),
          );
          expect(paragraph.didExceedMaxLines, isFalse);
          expect(
            tester.getRect(find.text(_dateTime)).right,
            lessThanOrEqualTo(
              tester.getRect(find.byType(TitleTextLabel)).right,
            ),
          );
        },
      );
    }
  });
}
