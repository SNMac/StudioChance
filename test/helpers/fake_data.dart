import 'package:studio_chance/data/models/price_settings_model.dart';
import 'package:studio_chance/data/models/reservation_model.dart';
import 'package:studio_chance/data/models/store_member_info_model.dart';
import 'package:studio_chance/data/models/store_model.dart';
import 'package:studio_chance/data/models/user_model.dart';
import 'package:studio_chance/data/models/user_store_info_model.dart';
import 'package:studio_chance/domain/entities/auth_info.dart';
import 'package:studio_chance/domain/entities/day_group.dart';
import 'package:studio_chance/domain/entities/price_setting.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/entities/store_member_info.dart';
import 'package:studio_chance/domain/entities/store_summary.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/enums/payment_method.dart';
import 'package:studio_chance/domain/enums/reservation_platform.dart';
import 'package:studio_chance/domain/enums/reservation_status.dart';
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

// ── Reservation 관련 ──────────────────────────────────────────────────────────

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

// ── Data Model fakes (Repository 테스트용) ────────────────────────────────────

final fakeReservationModel = ReservationModel(
  id: 'res-001',
  storeId: 'store-123',
  writerId: 'user-123',
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

final fakeStoreModel = StoreModel(
  id: 'store-123',
  name: '테스트 점포',
  address: '서울시 강남구 테헤란로 1',
  addressDetail: '101호',
  addressGuide: '정문으로 오세요',
  priceSettingsModel: PriceSettingsModel(),
  memberById: {'user-123': StoreMemberInfoModel(role: UserRole.admin)},
);

final fakeUserModel = UserModel(
  id: 'user-123',
  email: 'test@example.com',
  name: '테스트 유저',
  nickname: '닉네임',
  storeById: {
    'store-123': UserStoreInfoModel(
      name: '테스트 점포',
      role: UserRole.admin,
      color: StoreColor.blue,
      memo: '',
    ),
  },
);
