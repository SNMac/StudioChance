import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_date_time_button.dart';

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
  });
}
