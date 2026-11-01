import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_date_time_button.dart';

import '../../../../helpers/max_text_scale_wrapper.dart';

/// `formattedDateTime`이 만드는 가장 긴 형태 (두 자리 월·일, 요일, 시각).
const _dateTime = '2026. 11. 01. (일) 22:00';

void main() {
  group('TitleDateTimeButton', () {
    testWidgets('mode이 dateAndTime에서 date로 바뀌어도 예외가 발생하지 않는다', (tester) async {
      var mode = CupertinoDatePickerMode.dateAndTime;
      late StateSetter setParentState;

      await tester.pumpWidget(
        CupertinoApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              setParentState = setState;
              return TitleDateTimeButton(
                title: '입실 일시',
                content: '2026. 07. 30. (목) 10:00',
                isOpen: false,
                onPressed: () {},
                mode: mode,
                initialDateTime: DateTime(2026, 7, 30, 10),
                onDateTimeChanged: (_) {},
              );
            },
          ),
        ),
      );

      setParentState(() => mode = CupertinoDatePickerMode.date);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    for (final width in maxTextScaleTestScreenWidths) {
      testWidgets('큰 글자 배율이어도 ${width.toInt()}pt에서 일시가 행 안에 들어간다', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrapAtMaxTextScale(
            TitleDateTimeButton(
              title: '입실 일시',
              content: _dateTime,
              isOpen: false,
              onPressed: () {},
              mode: CupertinoDatePickerMode.dateAndTime,
              initialDateTime: DateTime(2026, 11, 1, 22),
              onDateTimeChanged: (_) {},
            ),
            screenWidth: width,
          ),
        );

        expect(tester.takeException(), isNull);
        expect(
          tester.getRect(find.text(_dateTime)).right,
          lessThanOrEqualTo(
            tester.getRect(find.byType(TitleDateTimeButton)).right,
          ),
        );
      });
    }
  });
}
