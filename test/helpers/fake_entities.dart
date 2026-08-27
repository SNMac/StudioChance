import 'package:studio_chance/domain/entities/auth_info.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/entities/space_option.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/entities/store_member_info.dart';
import 'package:studio_chance/domain/entities/store_summary.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/entities/user_store_info.dart';
import 'package:studio_chance/common/enums/payment_method.dart';
import 'package:studio_chance/common/enums/reservation_platform.dart';
import 'package:studio_chance/common/enums/reservation_status.dart';
import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/common/enums/user_role.dart';

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
  spaceOptions: [SpaceOption.empty()],
  inviteInfo: null,
);

final fakeStoreSummary = StoreSummary(
  id: 'store-123',
  name: '테스트 점포',
  color: StoreColor.blue,
);

final fakeWriterMemberInfo = StoreMemberInfo(
  user: fakeUser,
  role: UserRole.admin,
);

final fakeReservation = Reservation(
  id: 'res-001',
  storeSummary: fakeStoreSummary,
  writer: fakeWriterMemberInfo,
  status: ReservationStatus.confirmed,
  customerName: '홍길동',
  headCount: 4,
  customerPhone: '010-1234-5678',
  memo: '주차 필요',
  isAllDay: false,
  startTime: DateTime(2026, 5, 1, 10, 0),
  endTime: DateTime(2026, 5, 1, 12, 0),
  platform: ReservationPlatform.naver,
  paymentMethod: PaymentMethod.bankTransfer,
  calculatedPrice: 50000,
  priceAdjustment: -5000,
  totalPrice: 45000,
);

/// 지정한 점포 ID 목록을 가진 사용자 (홈 점포 필터 테스트용)
User fakeUserWithStores(List<String> storeIds) {
  return fakeUser.copyWith(
    storeInfos: [
      for (final id in storeIds)
        UserStoreInfo(
          id: id,
          name: '점포 $id',
          role: UserRole.admin,
          color: StoreColor.red,
          memo: '',
        ),
    ],
  );
}
