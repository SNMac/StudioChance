import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_info.freezed.dart';

@freezed
abstract class AuthInfo with _$AuthInfo {
  const factory AuthInfo({
    required String uid,
    required String? email,
    required String? displayName,
    required List<String> authProviders,
  }) = _AuthInfo;
}
