import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/enums/store_color.dart';

/// 생성/수정 컨트롤러가 공통으로 구현해야 할 인터페이스
abstract interface class StoreFormControllerable {
  void setName(String name);
  void setAddress(String address);
  void setAddressShort(String addressShort);
  void setAddressGuide(String addressGuide);
  void setMemo(String memo);
  void setColor(StoreColor color);

  /// 현재 폼 데이터를 반환 (유효하지 않으면 null)
  ({Store store, StoreColor color})? getFormData();

  /// API 요청 실행
  Future<void> submit();
}