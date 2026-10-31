import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/domain/entities/store_naming.dart';

part 'store_summary.freezed.dart';

@freezed
abstract class StoreSummary with _$StoreSummary, StoreNaming {
  const StoreSummary._();

  const factory StoreSummary({
    required String id,
    required String name,
    String? alias,
    required StoreColor color,
  }) = _StoreSummary;
}
