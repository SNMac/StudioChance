import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_model.freezed.dart';

@freezed
abstract class AuthModel with _$AuthModel {
  const factory AuthModel({
    required String uid,
    String? displayName,
  }) = _AuthModel;

  factory AuthModel.fromFirebase(firebase_auth.User user) {
    return AuthModel(
      uid: user.uid,
      displayName: user.displayName,
    );
  }
}