import 'package:flutter_test/flutter_test.dart';

import 'package:studio_chance/presentation/commons/extensions/store_deletion_formatter.dart';

void main() {
  final now = DateTime(2026, 10, 29, 12);

  test('막 삭제한 점포는 7일 후로 보인다', () {
    expect(
      now.add(const Duration(days: 7)).remainingUntilDeletion(now),
      '7일 후',
    );
  });

  test('하루 이상 남았으면 일 수를 올림한다', () {
    final deadline = now.add(const Duration(days: 2, hours: 1));

    expect(deadline.remainingUntilDeletion(now), '3일 후');
  });

  test('정확히 하루 남았으면 1일 후다', () {
    expect(
      now.add(const Duration(days: 1)).remainingUntilDeletion(now),
      '1일 후',
    );
  });

  test('24시간 미만으로 남았으면 오늘이다', () {
    final deadline = now.add(const Duration(hours: 23, minutes: 59));

    expect(deadline.remainingUntilDeletion(now), '오늘');
  });
}
