import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:studio_chance/presentation/commons/widgets/input_form/title_text_label.dart';

import '../../../../helpers/max_text_scale_wrapper.dart';

/// `formattedDateTime`이 만드는 가장 긴 형태 (두 자리 월·일, 요일, 시각).
const _dateTime = '2026. 11. 01. (일) 22:00';

/// `store_form_screen`의 `LengthLimitingTextInputFormatter(15)`가 허용하는
/// 최대 길이 점포명.
const _maxLengthStoreName = '스튜디오찬스수원영통구중부대로점';

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

      testWidgets('기본값이면 ${width.toInt()}pt에서 긴 점포명이 한 줄로 말줄임되어 행 안에 들어간다', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrapAtMaxTextScale(
            // 예약 상세의 예약 점포 행처럼 점포 색상 점을 앞에 붙인다
            const TitleTextLabel(
              title: '예약 점포',
              content: _maxLengthStoreName,
              leading: SizedBox(width: 8, height: 8),
            ),
            screenWidth: width,
          ),
        );

        expect(tester.takeException(), isNull);
        final paragraph = tester.renderObject<RenderParagraph>(
          find.text(_maxLengthStoreName),
        );
        expect(paragraph.didExceedMaxLines, isTrue);
        expect(
          tester.getRect(find.text(_maxLengthStoreName)).right,
          lessThanOrEqualTo(tester.getRect(find.byType(TitleTextLabel)).right),
        );
      });
    }
  });
}
