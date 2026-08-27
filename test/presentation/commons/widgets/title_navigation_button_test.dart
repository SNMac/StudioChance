import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_navigation_button.dart';

/// `store_form_screen`의 `LengthLimitingTextInputFormatter(15)`가 허용하는
/// 최대 길이 점포명. 실제로 도달 가능한 입력이다.
const _maxLengthTitle = '스튜디오찬스수원영통구중부대로점';

Widget _wrap(Widget child, double width) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: width,
          // 실제 폼과 동일하게 좌우 패딩이 붙는다.
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: horizontalPadding,
            ),
            child: child,
          ),
        ),
      ),
    ),
  );
}

void main() {
  // 고정 크기 요소(배지·chevron)가 붙은 상태에서 제목이 길면
  // 제목이 양보해야 한다. 제목이 non-flex면 Expanded가 0폭이 되어
  // 오른쪽 요소들이 행 밖으로 넘친다.
  //
  // 375는 iOS 최소 지원 기기(iPhone SE) 논리 폭이다.
  for (final width in [320.0, 375.0]) {
    testWidgets('제목이 최대 길이여도 ${width.toInt()}pt에서 오버플로하지 않는다', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          TitleNavigationButton(
            title: _maxLengthTitle,
            content: '관리자',
            contentLeading: Container(width: 8, height: 8, color: Colors.red),
            trailing: Container(width: 20, height: 20, color: Colors.blue),
            onPressed: () {},
          ),
          width,
        ),
      );

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('제목이 길면 말줄임 처리된다', (tester) async {
    await tester.pumpWidget(
      _wrap(
        TitleNavigationButton(
          title: _maxLengthTitle,
          content: '관리자',
          onPressed: () {},
        ),
        375.0,
      ),
    );

    final titleText = tester.widget<Text>(find.text(_maxLengthTitle));
    expect(titleText.overflow, TextOverflow.ellipsis);
    expect(titleText.maxLines, 1);
  });
}
