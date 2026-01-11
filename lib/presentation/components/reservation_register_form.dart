import 'package:flutter/material.dart';
import 'package:studio_chance/presentation/components/title_popup_button.dart';

class ReservationRegisterForm extends StatelessWidget {
  // final Map<String, Color> colorMap = {
  //   '빨간색': Colors.red,
  //   '파란색': Colors.blue,
  //   '초록색': Colors.green,
  // };

  const ReservationRegisterForm({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
    // return TitlePopupButton<String>(
    //   title: "색상",
    //   selectedValue: "빨간색", // 현재 선택된 키값
    //   items: colorMap.keys.toList(), // ["빨간색", "파란색", "초록색"]
    //   // 1. 텍스트 라벨 만드는 법
    //   itemLabelBuilder: (key) => key,
    //
    //   // 2. ★ 핵심: 앞에 동그라미(Dot) 만드는 법
    //   itemLeadingBuilder: (key) {
    //     return Container(
    //       width: 8,
    //       height: 8,
    //       decoration: BoxDecoration(
    //         color: colorMap[key], // 해당 키의 색상 사용
    //         shape: BoxShape.circle,
    //       ),
    //     );
    //   },
    //
    //   onSelected: (value) {
    //     // 선택 시 로직
    //   },
    // );
  }
}
