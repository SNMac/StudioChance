import 'package:flutter/cupertino.dart';
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
  // 고정 크기 요소(배지·수정 버튼·chevron)가 붙은 상태에서 제목이 길면 제목이
  // 양보해야 한다. 양보하지 않으면 오른쪽 요소가 제목과 겹치거나 행 밖으로 밀린다.
  // CustomMultiChildLayout은 Row와 달리 넘쳐도 오류를 내지 않으므로, 실제로
  // 배치된 위치로 겹침과 행 이탈을 확인한다.
  //
  // 375는 iOS 최소 지원 기기(iPhone SE) 논리 폭이다.
  for (final width in [320.0, 375.0, 411.0]) {
    testWidgets('제목이 최대 길이여도 ${width.toInt()}pt에서 오른쪽 요소와 겹치거나 행 밖으로 나가지 않는다', (
      tester,
    ) async {
      const leadingKey = Key('leading');
      const badgeKey = Key('badge');
      const editKey = Key('edit');

      await tester.pumpWidget(
        _wrap(
          TitleNavigationButton(
            title: _maxLengthTitle,
            content: '관리자',
            contentLeading: Container(
              key: leadingKey,
              width: 8,
              height: 8,
              color: Colors.red,
            ),
            // 마이페이지 ADMIN 점포 행과 같은 구성: 두 자리 대기 배지 + 수정 버튼.
            // 오른쪽 고정 요소가 이보다 작으면 제목 비율을 키웠을 때 생기는
            // 겹침을 놓친다.
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                Container(
                  key: badgeKey,
                  width: 30,
                  height: 20,
                  color: Colors.blue,
                ),
                Container(
                  key: editKey,
                  width: 28,
                  height: 28,
                  color: Colors.green,
                ),
              ],
            ),
            onPressed: () {},
          ),
          width,
        ),
      );

      expect(tester.takeException(), isNull);

      final row = tester.getRect(find.byType(TitleNavigationButton));
      // 왼쪽부터 놓이는 순서
      final ordered = [
        tester.getRect(find.text(_maxLengthTitle)),
        tester.getRect(find.byKey(leadingKey)),
        tester.getRect(find.text('관리자')),
        tester.getRect(find.byKey(badgeKey)),
        tester.getRect(find.byKey(editKey)),
        tester.getRect(find.byIcon(CupertinoIcons.chevron_forward)),
      ];

      for (final rect in ordered) {
        expect(rect.left, greaterThanOrEqualTo(row.left), reason: '행 왼쪽 밖');
        expect(rect.right, lessThanOrEqualTo(row.right), reason: '행 오른쪽 밖');
      }
      for (var i = 0; i < ordered.length - 1; i++) {
        expect(
          ordered[i].right,
          lessThanOrEqualTo(ordered[i + 1].left),
          reason: '$i번째 요소가 다음 요소와 겹친다',
        );
      }
    });
  }
}
