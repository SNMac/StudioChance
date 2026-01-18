import 'package:studio_chance/presentation/commons/store_input/controllers/states/store_form_state.dart';

extension StoreFormAddressFormatter on StoreFormState {
  /// 주소 표시용 문자열 (예: "경기 오산시" or "주소 검색")
  String get formattedAddress {
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
}
