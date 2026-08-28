import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/domain/entities/invite_store_preview.dart';

part 'invite_store_preview_model.freezed.dart';
part 'invite_store_preview_model.g.dart';

@freezed
abstract class InviteStorePreviewModel with _$InviteStorePreviewModel {
  const InviteStorePreviewModel._();

  const factory InviteStorePreviewModel({
    required String storeId,
    required String storeName,
    required String address,
    required String addressDetail,
    required String adminName,
  }) = _InviteStorePreviewModel;

  factory InviteStorePreviewModel.fromJson(Map<String, dynamic> json) =>
      _$InviteStorePreviewModelFromJson(json);

  InviteStorePreview toEntity() {
    return InviteStorePreview(
      storeId: storeId,
      storeName: storeName,
      address: address,
      addressDetail: addressDetail,
      adminName: adminName,
    );
  }
}
