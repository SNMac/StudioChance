// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StoreModel {

 String get id; String get ownerId; String get name; Map<String, String> get memberIds; String get address; String get memo; String get color; InviteInfoModel? get inviteInfo; PriceSettingsModel get priceSettings;@TimestampConverter() DateTime get createdAt;@TimestampConverter() DateTime get updatedAt;@JsonKey(includeIfNull: false)@TimestampConverter() DateTime? get deletedAt;@JsonKey(includeIfNull: false)@TimestampConverter() DateTime? get expiresAt;
/// Create a copy of StoreModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoreModelCopyWith<StoreModel> get copyWith => _$StoreModelCopyWithImpl<StoreModel>(this as StoreModel, _$identity);

  /// Serializes this StoreModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoreModel&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.memberIds, memberIds)&&(identical(other.address, address) || other.address == address)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.color, color) || other.color == color)&&(identical(other.inviteInfo, inviteInfo) || other.inviteInfo == inviteInfo)&&(identical(other.priceSettings, priceSettings) || other.priceSettings == priceSettings)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerId,name,const DeepCollectionEquality().hash(memberIds),address,memo,color,inviteInfo,priceSettings,createdAt,updatedAt,deletedAt,expiresAt);

@override
String toString() {
  return 'StoreModel(id: $id, ownerId: $ownerId, name: $name, memberIds: $memberIds, address: $address, memo: $memo, color: $color, inviteInfo: $inviteInfo, priceSettings: $priceSettings, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $StoreModelCopyWith<$Res>  {
  factory $StoreModelCopyWith(StoreModel value, $Res Function(StoreModel) _then) = _$StoreModelCopyWithImpl;
@useResult
$Res call({
 String id, String ownerId, String name, Map<String, String> memberIds, String address, String memo, String color, InviteInfoModel? inviteInfo, PriceSettingsModel priceSettings,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt,@JsonKey(includeIfNull: false)@TimestampConverter() DateTime? deletedAt,@JsonKey(includeIfNull: false)@TimestampConverter() DateTime? expiresAt
});


$InviteInfoModelCopyWith<$Res>? get inviteInfo;$PriceSettingsModelCopyWith<$Res> get priceSettings;

}
/// @nodoc
class _$StoreModelCopyWithImpl<$Res>
    implements $StoreModelCopyWith<$Res> {
  _$StoreModelCopyWithImpl(this._self, this._then);

  final StoreModel _self;
  final $Res Function(StoreModel) _then;

/// Create a copy of StoreModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ownerId = null,Object? name = null,Object? memberIds = null,Object? address = null,Object? memo = null,Object? color = null,Object? inviteInfo = freezed,Object? priceSettings = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? expiresAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,memberIds: null == memberIds ? _self.memberIds : memberIds // ignore: cast_nullable_to_non_nullable
as Map<String, String>,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,memo: null == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,inviteInfo: freezed == inviteInfo ? _self.inviteInfo : inviteInfo // ignore: cast_nullable_to_non_nullable
as InviteInfoModel?,priceSettings: null == priceSettings ? _self.priceSettings : priceSettings // ignore: cast_nullable_to_non_nullable
as PriceSettingsModel,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of StoreModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InviteInfoModelCopyWith<$Res>? get inviteInfo {
    if (_self.inviteInfo == null) {
    return null;
  }

  return $InviteInfoModelCopyWith<$Res>(_self.inviteInfo!, (value) {
    return _then(_self.copyWith(inviteInfo: value));
  });
}/// Create a copy of StoreModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceSettingsModelCopyWith<$Res> get priceSettings {
  
  return $PriceSettingsModelCopyWith<$Res>(_self.priceSettings, (value) {
    return _then(_self.copyWith(priceSettings: value));
  });
}
}


/// Adds pattern-matching-related methods to [StoreModel].
extension StoreModelPatterns on StoreModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoreModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoreModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoreModel value)  $default,){
final _that = this;
switch (_that) {
case _StoreModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoreModel value)?  $default,){
final _that = this;
switch (_that) {
case _StoreModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String ownerId,  String name,  Map<String, String> memberIds,  String address,  String memo,  String color,  InviteInfoModel? inviteInfo,  PriceSettingsModel priceSettings, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt, @JsonKey(includeIfNull: false)@TimestampConverter()  DateTime? deletedAt, @JsonKey(includeIfNull: false)@TimestampConverter()  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoreModel() when $default != null:
return $default(_that.id,_that.ownerId,_that.name,_that.memberIds,_that.address,_that.memo,_that.color,_that.inviteInfo,_that.priceSettings,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String ownerId,  String name,  Map<String, String> memberIds,  String address,  String memo,  String color,  InviteInfoModel? inviteInfo,  PriceSettingsModel priceSettings, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt, @JsonKey(includeIfNull: false)@TimestampConverter()  DateTime? deletedAt, @JsonKey(includeIfNull: false)@TimestampConverter()  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _StoreModel():
return $default(_that.id,_that.ownerId,_that.name,_that.memberIds,_that.address,_that.memo,_that.color,_that.inviteInfo,_that.priceSettings,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String ownerId,  String name,  Map<String, String> memberIds,  String address,  String memo,  String color,  InviteInfoModel? inviteInfo,  PriceSettingsModel priceSettings, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt, @JsonKey(includeIfNull: false)@TimestampConverter()  DateTime? deletedAt, @JsonKey(includeIfNull: false)@TimestampConverter()  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _StoreModel() when $default != null:
return $default(_that.id,_that.ownerId,_that.name,_that.memberIds,_that.address,_that.memo,_that.color,_that.inviteInfo,_that.priceSettings,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StoreModel implements StoreModel {
  const _StoreModel({required this.id, required this.ownerId, required this.name, required final  Map<String, String> memberIds, required this.address, required this.memo, required this.color, this.inviteInfo, required this.priceSettings, @TimestampConverter() required this.createdAt, @TimestampConverter() required this.updatedAt, @JsonKey(includeIfNull: false)@TimestampConverter() this.deletedAt, @JsonKey(includeIfNull: false)@TimestampConverter() this.expiresAt}): _memberIds = memberIds;
  factory _StoreModel.fromJson(Map<String, dynamic> json) => _$StoreModelFromJson(json);

@override final  String id;
@override final  String ownerId;
@override final  String name;
 final  Map<String, String> _memberIds;
@override Map<String, String> get memberIds {
  if (_memberIds is EqualUnmodifiableMapView) return _memberIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_memberIds);
}

@override final  String address;
@override final  String memo;
@override final  String color;
@override final  InviteInfoModel? inviteInfo;
@override final  PriceSettingsModel priceSettings;
@override@TimestampConverter() final  DateTime createdAt;
@override@TimestampConverter() final  DateTime updatedAt;
@override@JsonKey(includeIfNull: false)@TimestampConverter() final  DateTime? deletedAt;
@override@JsonKey(includeIfNull: false)@TimestampConverter() final  DateTime? expiresAt;

/// Create a copy of StoreModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoreModelCopyWith<_StoreModel> get copyWith => __$StoreModelCopyWithImpl<_StoreModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StoreModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoreModel&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._memberIds, _memberIds)&&(identical(other.address, address) || other.address == address)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.color, color) || other.color == color)&&(identical(other.inviteInfo, inviteInfo) || other.inviteInfo == inviteInfo)&&(identical(other.priceSettings, priceSettings) || other.priceSettings == priceSettings)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerId,name,const DeepCollectionEquality().hash(_memberIds),address,memo,color,inviteInfo,priceSettings,createdAt,updatedAt,deletedAt,expiresAt);

@override
String toString() {
  return 'StoreModel(id: $id, ownerId: $ownerId, name: $name, memberIds: $memberIds, address: $address, memo: $memo, color: $color, inviteInfo: $inviteInfo, priceSettings: $priceSettings, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$StoreModelCopyWith<$Res> implements $StoreModelCopyWith<$Res> {
  factory _$StoreModelCopyWith(_StoreModel value, $Res Function(_StoreModel) _then) = __$StoreModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String ownerId, String name, Map<String, String> memberIds, String address, String memo, String color, InviteInfoModel? inviteInfo, PriceSettingsModel priceSettings,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt,@JsonKey(includeIfNull: false)@TimestampConverter() DateTime? deletedAt,@JsonKey(includeIfNull: false)@TimestampConverter() DateTime? expiresAt
});


@override $InviteInfoModelCopyWith<$Res>? get inviteInfo;@override $PriceSettingsModelCopyWith<$Res> get priceSettings;

}
/// @nodoc
class __$StoreModelCopyWithImpl<$Res>
    implements _$StoreModelCopyWith<$Res> {
  __$StoreModelCopyWithImpl(this._self, this._then);

  final _StoreModel _self;
  final $Res Function(_StoreModel) _then;

/// Create a copy of StoreModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ownerId = null,Object? name = null,Object? memberIds = null,Object? address = null,Object? memo = null,Object? color = null,Object? inviteInfo = freezed,Object? priceSettings = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? expiresAt = freezed,}) {
  return _then(_StoreModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,memberIds: null == memberIds ? _self._memberIds : memberIds // ignore: cast_nullable_to_non_nullable
as Map<String, String>,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,memo: null == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,inviteInfo: freezed == inviteInfo ? _self.inviteInfo : inviteInfo // ignore: cast_nullable_to_non_nullable
as InviteInfoModel?,priceSettings: null == priceSettings ? _self.priceSettings : priceSettings // ignore: cast_nullable_to_non_nullable
as PriceSettingsModel,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of StoreModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InviteInfoModelCopyWith<$Res>? get inviteInfo {
    if (_self.inviteInfo == null) {
    return null;
  }

  return $InviteInfoModelCopyWith<$Res>(_self.inviteInfo!, (value) {
    return _then(_self.copyWith(inviteInfo: value));
  });
}/// Create a copy of StoreModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceSettingsModelCopyWith<$Res> get priceSettings {
  
  return $PriceSettingsModelCopyWith<$Res>(_self.priceSettings, (value) {
    return _then(_self.copyWith(priceSettings: value));
  });
}
}

// dart format on
