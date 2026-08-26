import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/entities/store_member_info.dart';
import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/presentation/providers/store_detail_provider.dart';
import 'package:studio_chance/presentation/my_page/widgets/pending_member_modal.dart';

import '../../helpers/fake_entities.dart';

Store storeWithWaiting(List<StoreMemberInfo> waiting) =>
    fakeStore.copyWith(waitingMemberInfos: waiting);

Widget wrap(Widget child, {required Store store}) {
  return ProviderScope(
    overrides: [
      storeDetailProvider(store.id).overrideWith((ref) async => store),
    ],
    child: MaterialApp(
      home: Scaffold(body: LayoutBuilder(builder: (_, constraints) => child)),
    ),
  );
}

void main() {
  testWidgets('대기 중인 신청자의 닉네임과 신청 역할을 보여준다', (tester) async {
    final store = storeWithWaiting([
      StoreMemberInfo(
        user: fakeUser.copyWith(id: 'applicant-1', nickname: '홍길동'),
        role: UserRole.staff,
      ),
    ]);

    await tester.pumpWidget(
      wrap(
        PendingMemberModal(storeId: store.id, maxAvailableHeight: 600),
        store: store,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('홍길동'), findsOneWidget);
    expect(find.text(UserRole.staff.displayName), findsOneWidget);
  });

  testWidgets('대기자가 없으면 안내 문구를 보여준다', (tester) async {
    final store = storeWithWaiting([]);

    await tester.pumpWidget(
      wrap(
        PendingMemberModal(storeId: store.id, maxAvailableHeight: 600),
        store: store,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('대기 중인 가입 신청이 없습니다.'), findsOneWidget);
  });

  testWidgets('닉네임이 없으면 이름으로 대체 표시한다', (tester) async {
    final store = storeWithWaiting([
      StoreMemberInfo(
        user: fakeUser.copyWith(id: 'applicant-2', nickname: null, name: '김철수'),
        role: UserRole.viewer,
      ),
    ]);

    await tester.pumpWidget(
      wrap(
        PendingMemberModal(storeId: store.id, maxAvailableHeight: 600),
        store: store,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('김철수'), findsOneWidget);
  });
}
