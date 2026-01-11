// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserModel {

@JsonKey(includeToJson: false) String get id; String get email; String get name; String? get nickname; List<String> get authProviders; List<String> get fcmTokens;@JsonKey(unknownEnumValue: UserRole.none) UserRole get role; List<String> get storeIds;// DataSource에서 serverTimestamp로 저장되지만, 우선 Datetime 입력
@TimestampConverter() DateTime get createdAt;@TimestampConverter() DateTime get updatedAt;@TimestampConverter() DateTime get lastLoginAt;@JsonKey(includeIfNull: false)@TimestampConverter() DateTime? get deletedAt;@JsonKey(includeIfNull: false)@TimestampConverter() DateTime? get expiresAt;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.name, name) || other.name == name)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&const DeepCollectionEquality().equals(other.authProviders, authProviders)&&const DeepCollectionEquality().equals(other.fcmTokens, fcmTokens)&&(identical(other.role, role) || other.role == role)&&const DeepCollectionEquality().equals(other.storeIds, storeIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,name,nickname,const DeepCollectionEquality().hash(authProviders),const DeepCollectionEquality().hash(fcmTokens),role,const DeepCollectionEquality().hash(storeIds),createdAt,updatedAt,lastLoginAt,deletedAt,expiresAt);

@override
String toString() {
  return 'UserModel(id: $id, email: $email, name: $name, nickname: $nickname, authProviders: $authProviders, fcmTokens: $fcmTokens, role: $role, storeIds: $storeIds, createdAt: $createdAt, updatedAt: $updatedAt, lastLoginAt: $lastLoginAt, deletedAt: $deletedAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) String id, String email, String name, String? nickname, List<String> authProviders, List<String> fcmTokens,@JsonKey(unknownEnumValue: UserRole.none) UserRole role, List<String> storeIds,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt,@TimestampConverter() DateTime lastLoginAt,@JsonKey(includeIfNull: false)@TimestampConverter() DateTime? deletedAt,@JsonKey(includeIfNull: false)@TimestampConverter() DateTime? expiresAt
});




}
/// @nodoc
class _$UserModelCopyWithImpl<$Res>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? name = null,Object? nickname = freezed,Object? authProviders = null,Object? fcmTokens = null,Object? role = null,Object? storeIds = null,Object? createdAt = null,Object? updatedAt = null,Object? lastLoginAt = null,Object? deletedAt = freezed,Object? expiresAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nickname: freezed == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String?,authProviders: null == authProviders ? _self.authProviders : authProviders // ignore: cast_nullable_to_non_nullable
as List<String>,fcmTokens: null == fcmTokens ? _self.fcmTokens : fcmTokens // ignore: cast_nullable_to_non_nullable
as List<String>,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,storeIds: null == storeIds ? _self.storeIds : storeIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastLoginAt: null == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserModel].
extension UserModelPatterns on UserModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserModel value)  $default,){
final _that = this;
switch (_that) {
case _UserModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String email,  String name,  String? nickname,  List<String> authProviders,  List<String> fcmTokens, @JsonKey(unknownEnumValue: UserRole.none)  UserRole role,  List<String> storeIds, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt, @TimestampConverter()  DateTime lastLoginAt, @JsonKey(includeIfNull: false)@TimestampConverter()  DateTime? deletedAt, @JsonKey(includeIfNull: false)@TimestampConverter()  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.email,_that.name,_that.nickname,_that.authProviders,_that.fcmTokens,_that.role,_that.storeIds,_that.createdAt,_that.updatedAt,_that.lastLoginAt,_that.deletedAt,_that.expiresAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String email,  String name,  String? nickname,  List<String> authProviders,  List<String> fcmTokens, @JsonKey(unknownEnumValue: UserRole.none)  UserRole role,  List<String> storeIds, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt, @TimestampConverter()  DateTime lastLoginAt, @JsonKey(includeIfNull: false)@TimestampConverter()  DateTime? deletedAt, @JsonKey(includeIfNull: false)@TimestampConverter()  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _UserModel():
return $default(_that.id,_that.email,_that.name,_that.nickname,_that.authProviders,_that.fcmTokens,_that.role,_that.storeIds,_that.createdAt,_that.updatedAt,_that.lastLoginAt,_that.deletedAt,_that.expiresAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  String id,  String email,  String name,  String? nickname,  List<String> authProviders,  List<String> fcmTokens, @JsonKey(unknownEnumValue: UserRole.none)  UserRole role,  List<String> storeIds, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt, @TimestampConverter()  DateTime lastLoginAt, @JsonKey(includeIfNull: false)@TimestampConverter()  DateTime? deletedAt, @JsonKey(includeIfNull: false)@TimestampConverter()  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.email,_that.name,_that.nickname,_that.authProviders,_that.fcmTokens,_that.role,_that.storeIds,_that.createdAt,_that.updatedAt,_that.lastLoginAt,_that.deletedAt,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserModel extends UserModel {
  const _UserModel({@JsonKey(includeToJson: false) required this.id, required this.email, required this.name, this.nickname, final  List<String> authProviders = const [], final  List<String> fcmTokens = const [], @JsonKey(unknownEnumValue: UserRole.none) required this.role, final  List<String> storeIds = const [], @TimestampConverter() required this.createdAt, @TimestampConverter() required this.updatedAt, @TimestampConverter() required this.lastLoginAt, @JsonKey(includeIfNull: false)@TimestampConverter() this.deletedAt, @JsonKey(includeIfNull: false)@TimestampConverter() this.expiresAt}): _authProviders = authProviders,_fcmTokens = fcmTokens,_storeIds = storeIds,super._();
  factory _UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

@override@JsonKey(includeToJson: false) final  String id;
@override final  String email;
@override final  String name;
@override final  String? nickname;
 final  List<String> _authProviders;
@override@JsonKey() List<String> get authProviders {
  if (_authProviders is EqualUnmodifiableListView) return _authProviders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_authProviders);
}

 final  List<String> _fcmTokens;
@override@JsonKey() List<String> get fcmTokens {
  if (_fcmTokens is EqualUnmodifiableListView) return _fcmTokens;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fcmTokens);
}

@override@JsonKey(unknownEnumValue: UserRole.none) final  UserRole role;
 final  List<String> _storeIds;
@override@JsonKey() List<String> get storeIds {
  if (_storeIds is EqualUnmodifiableListView) return _storeIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_storeIds);
}

// DataSource에서 serverTimestamp로 저장되지만, 우선 Datetime 입력
@override@TimestampConverter() final  DateTime createdAt;
@override@TimestampConverter() final  DateTime updatedAt;
@override@TimestampConverter() final  DateTime lastLoginAt;
@override@JsonKey(includeIfNull: false)@TimestampConverter() final  DateTime? deletedAt;
@override@JsonKey(includeIfNull: false)@TimestampConverter() final  DateTime? expiresAt;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserModelCopyWith<_UserModel> get copyWith => __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.name, name) || other.name == name)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&const DeepCollectionEquality().equals(other._authProviders, _authProviders)&&const DeepCollectionEquality().equals(other._fcmTokens, _fcmTokens)&&(identical(other.role, role) || other.role == role)&&const DeepCollectionEquality().equals(other._storeIds, _storeIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,name,nickname,const DeepCollectionEquality().hash(_authProviders),const DeepCollectionEquality().hash(_fcmTokens),role,const DeepCollectionEquality().hash(_storeIds),createdAt,updatedAt,lastLoginAt,deletedAt,expiresAt);

@override
String toString() {
  return 'UserModel(id: $id, email: $email, name: $name, nickname: $nickname, authProviders: $authProviders, fcmTokens: $fcmTokens, role: $role, storeIds: $storeIds, createdAt: $createdAt, updatedAt: $updatedAt, lastLoginAt: $lastLoginAt, deletedAt: $deletedAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(_UserModel value, $Res Function(_UserModel) _then) = __$UserModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) String id, String email, String name, String? nickname, List<String> authProviders, List<String> fcmTokens,@JsonKey(unknownEnumValue: UserRole.none) UserRole role, List<String> storeIds,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt,@TimestampConverter() DateTime lastLoginAt,@JsonKey(includeIfNull: false)@TimestampConverter() DateTime? deletedAt,@JsonKey(includeIfNull: false)@TimestampConverter() DateTime? expiresAt
});




}
/// @nodoc
class __$UserModelCopyWithImpl<$Res>
    implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? name = null,Object? nickname = freezed,Object? authProviders = null,Object? fcmTokens = null,Object? role = null,Object? storeIds = null,Object? createdAt = null,Object? updatedAt = null,Object? lastLoginAt = null,Object? deletedAt = freezed,Object? expiresAt = freezed,}) {
  return _then(_UserModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nickname: freezed == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String?,authProviders: null == authProviders ? _self._authProviders : authProviders // ignore: cast_nullable_to_non_nullable
as List<String>,fcmTokens: null == fcmTokens ? _self._fcmTokens : fcmTokens // ignore: cast_nullable_to_non_nullable
as List<String>,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,storeIds: null == storeIds ? _self._storeIds : storeIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastLoginAt: null == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
