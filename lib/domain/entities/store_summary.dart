import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/domain/enums/store_color.dart';

part 'store_summary.freezed.dart';

@freezed
abstract class StoreSummary with _$StoreSummary {
  const factory StoreSummary({
    required String id,
    required String name,
    required StoreColor color,
  }) = _StoreSummary;
}
