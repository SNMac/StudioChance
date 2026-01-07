import 'package:json_annotation/json_annotation.dart';

@JsonEnum(alwaysCreate: true)
enum UserRole {
  admin,
  staff,
  viewer,
  none
}