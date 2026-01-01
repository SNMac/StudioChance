import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_model.freezed.dart';

@freezed
abstract class AuthModel with _$AuthModel {
  const factory AuthModel({
    required String uid,
    String? displayName,
    @Default([]) List<String> authProviders,
  }) = _AuthModel;

  factory AuthModel.fromFirebase(firebase_auth.User user) {
    final authProviders = user.providerData
        .map((userInfo) => userInfo.providerId)
        .toList();

    return AuthModel(
      uid: user.uid,
      displayName: user.displayName,
      authProviders: authProviders,
    );
  }
}