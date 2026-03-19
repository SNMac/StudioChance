import 'package:studio_chance/domain/entities/auth_info.dart';
import 'package:studio_chance/domain/entities/day_group.dart';
import 'package:studio_chance/domain/entities/price_setting.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/enums/store_color.dart';
import 'package:studio_chance/domain/enums/user_role.dart';
import 'package:studio_chance/domain/entities/user_store_info.dart';

final fakeAuthInfo = AuthInfo(
  uid: 'user-123',
  email: 'test@example.com',
  displayName: '테스트 유저',
  authProviders: ['google'],
);

final fakeUser = User(
  id: 'user-123',
  name: '테스트 유저',
  email: 'test@example.com',
  nickname: '닉네임',
  authProviders: ['google'],
  storeInfos: [
    UserStoreInfo(
      id: 'store-123',
      name: '테스트 점포',
      role: UserRole.admin,
      color: StoreColor.red,
      memo: '기존 메모',
    ),
  ],
);

final fakeStore = Store(
  id: 'store-123',
  name: '테스트 점포',
  address: '서울시 강남구 테헤란로 1',
  addressDetail: '101호',
  addressGuide: '정문으로 오세요',
  memberInfos: [],
  waitingMemberInfos: [],
  priceSettings: PriceSetting(dayGroups: [DayGroup.empty()]),
  inviteInfo: null,
);
