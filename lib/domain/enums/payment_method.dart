import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum PaymentMethod {
  @JsonValue('BANK_TRANSFER')
  bankTransfer,
  @JsonValue('ON_SITE')
  onSite,
  @JsonValue('OTHER')
  other;

  String get displayName => switch (this) {
    PaymentMethod.bankTransfer => '계좌이체',
    PaymentMethod.onSite => '현장결제',
    PaymentMethod.other => '기타',
  };
}
