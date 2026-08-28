import 'package:studio_chance/domain/entities/invite_store_preview.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/states/store_form_state.dart';

/// 주소 표시용 문자열 (예: "오산시 경기대로285번길" or "주소 검색")
///
/// 도로명 주소는 `postal_ko`가 돌려준 값이 그대로 저장되므로
/// "경기 오산시 경기대로285번길 26"처럼 토큰이 4개인 경우가 일반적이다.
String formatShortAddress(String address, String addressDetail) {
  if (address.isEmpty) {
    return addressDetail.isEmpty ? '주소 검색' : addressDetail;
  }

  List<String> trimmed = address.trim().split(RegExp(r'\s+'));
  if (trimmed.isEmpty) {
    return '';
  } else if (trimmed.length == 1) {
    return trimmed[0];
  } else if (trimmed.length == 2) {
    return '${trimmed[0]} ${trimmed[1]}';
  } else {
    return '${trimmed[1]} ${trimmed[2]}';
  }
}

extension StoreFormAddressFormatter on StoreFormState {
  String get formattedAddress => formatShortAddress(address, addressDetail);
}

extension StoreAddressFormatter on Store {
  /// 점포 폼과 같은 규칙으로 줄여 표시한다.
  String get formattedAddress => formatShortAddress(address, addressDetail);
}

extension InviteStorePreviewAddressFormatter on InviteStorePreview {
  /// 점포 폼과 같은 규칙으로 줄여 표시한다.
  String get formattedAddress => formatShortAddress(address, addressDetail);
}
