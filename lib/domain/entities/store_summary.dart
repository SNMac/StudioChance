import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/common/enums/store_color.dart';

part 'store_summary.freezed.dart';

@freezed
abstract class StoreSummary with _$StoreSummary {
  const StoreSummary._();

  const factory StoreSummary({
    required String id,

    /// 점포 이름. 고객에게 보내는 안내문처럼 다른 사람이 읽는 곳에 쓴다
    required String name,

    /// 내 점포 별명. 없으면 null
    String? alias,
    required StoreColor color,
  }) = _StoreSummary;

  /// 내 화면에 보이는 점포 이름 — 점포 별명이 있으면 별명, 없으면 점포 이름
  String get displayName => alias ?? name;

  /// OCR이 읽은 점포 이름이 이 점포를 가리키는지. 플랫폼에 등록한 이름이 점포 이름과
  /// 다를 수 있어 별명도 비교한다
  bool isCalled(String storeName) => name == storeName || alias == storeName;
}
