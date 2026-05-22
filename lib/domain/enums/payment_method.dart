import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum PaymentMethod {
  @JsonValue('ON_SITE')
  onSite,
  @JsonValue('BANK_TRANSFER')
  bankTransfer,
  @JsonValue('OTHER')
  other;

  String get displayName => switch (this) {
    PaymentMethod.onSite => '현장결제',
    PaymentMethod.bankTransfer => '계좌이체',
    PaymentMethod.other => '기타',
  };
}
