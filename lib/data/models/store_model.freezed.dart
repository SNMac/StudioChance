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

@JsonKey(includeToJson: false) String get id; String get name; String get address; String get addressShort; String get addressGuide; String get memo; PriceSettingsModel get priceSettingsModel; Map<String, StoreMemberInfoModel> get memberById; Map<String, StoreMemberInfoModel> get waitingMemberById; InviteInfoModel? get inviteInfoModel;@TimestampConverter() DateTime get createdAt;@TimestampConverter() DateTime get updatedAt;@JsonKey(includeIfNull: false)@TimestampConverter() DateTime? get deletedAt;@JsonKey(includeIfNull: false)@TimestampConverter() DateTime? get expiresAt;
/// Create a copy of StoreModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoreModelCopyWith<StoreModel> get copyWith => _$StoreModelCopyWithImpl<StoreModel>(this as StoreModel, _$identity);

  /// Serializes this StoreModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoreModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.addressShort, addressShort) || other.addressShort == addressShort)&&(identical(other.addressGuide, addressGuide) || other.addressGuide == addressGuide)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.priceSettingsModel, priceSettingsModel) || other.priceSettingsModel == priceSettingsModel)&&const DeepCollectionEquality().equals(other.memberById, memberById)&&const DeepCollectionEquality().equals(other.waitingMemberById, waitingMemberById)&&(identical(other.inviteInfoModel, inviteInfoModel) || other.inviteInfoModel == inviteInfoModel)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,address,addressShort,addressGuide,memo,priceSettingsModel,const DeepCollectionEquality().hash(memberById),const DeepCollectionEquality().hash(waitingMemberById),inviteInfoModel,createdAt,updatedAt,deletedAt,expiresAt);

@override
String toString() {
  return 'StoreModel(id: $id, name: $name, address: $address, addressShort: $addressShort, addressGuide: $addressGuide, memo: $memo, priceSettingsModel: $priceSettingsModel, memberById: $memberById, waitingMemberById: $waitingMemberById, inviteInfoModel: $inviteInfoModel, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $StoreModelCopyWith<$Res>  {
  factory $StoreModelCopyWith(StoreModel value, $Res Function(StoreModel) _then) = _$StoreModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) String id, String name, String address, String addressShort, String addressGuide, String memo, PriceSettingsModel priceSettingsModel, Map<String, StoreMemberInfoModel> memberById, Map<String, StoreMemberInfoModel> waitingMemberById, InviteInfoModel? inviteInfoModel,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt,@JsonKey(includeIfNull: false)@TimestampConverter() DateTime? deletedAt,@JsonKey(includeIfNull: false)@TimestampConverter() DateTime? expiresAt
});


$PriceSettingsModelCopyWith<$Res> get priceSettingsModel;$InviteInfoModelCopyWith<$Res>? get inviteInfoModel;

}
/// @nodoc
class _$StoreModelCopyWithImpl<$Res>
    implements $StoreModelCopyWith<$Res> {
  _$StoreModelCopyWithImpl(this._self, this._then);

  final StoreModel _self;
  final $Res Function(StoreModel) _then;

/// Create a copy of StoreModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? address = null,Object? addressShort = null,Object? addressGuide = null,Object? memo = null,Object? priceSettingsModel = null,Object? memberById = null,Object? waitingMemberById = null,Object? inviteInfoModel = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? expiresAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,addressShort: null == addressShort ? _self.addressShort : addressShort // ignore: cast_nullable_to_non_nullable
as String,addressGuide: null == addressGuide ? _self.addressGuide : addressGuide // ignore: cast_nullable_to_non_nullable
as String,memo: null == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String,priceSettingsModel: null == priceSettingsModel ? _self.priceSettingsModel : priceSettingsModel // ignore: cast_nullable_to_non_nullable
as PriceSettingsModel,memberById: null == memberById ? _self.memberById : memberById // ignore: cast_nullable_to_non_nullable
as Map<String, StoreMemberInfoModel>,waitingMemberById: null == waitingMemberById ? _self.waitingMemberById : waitingMemberById // ignore: cast_nullable_to_non_nullable
as Map<String, StoreMemberInfoModel>,inviteInfoModel: freezed == inviteInfoModel ? _self.inviteInfoModel : inviteInfoModel // ignore: cast_nullable_to_non_nullable
as InviteInfoModel?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
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
$PriceSettingsModelCopyWith<$Res> get priceSettingsModel {
  
  return $PriceSettingsModelCopyWith<$Res>(_self.priceSettingsModel, (value) {
    return _then(_self.copyWith(priceSettingsModel: value));
  });
}/// Create a copy of StoreModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InviteInfoModelCopyWith<$Res>? get inviteInfoModel {
    if (_self.inviteInfoModel == null) {
    return null;
  }

  return $InviteInfoModelCopyWith<$Res>(_self.inviteInfoModel!, (value) {
    return _then(_self.copyWith(inviteInfoModel: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String name,  String address,  String addressShort,  String addressGuide,  String memo,  PriceSettingsModel priceSettingsModel,  Map<String, StoreMemberInfoModel> memberById,  Map<String, StoreMemberInfoModel> waitingMemberById,  InviteInfoModel? inviteInfoModel, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt, @JsonKey(includeIfNull: false)@TimestampConverter()  DateTime? deletedAt, @JsonKey(includeIfNull: false)@TimestampConverter()  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoreModel() when $default != null:
return $default(_that.id,_that.name,_that.address,_that.addressShort,_that.addressGuide,_that.memo,_that.priceSettingsModel,_that.memberById,_that.waitingMemberById,_that.inviteInfoModel,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String name,  String address,  String addressShort,  String addressGuide,  String memo,  PriceSettingsModel priceSettingsModel,  Map<String, StoreMemberInfoModel> memberById,  Map<String, StoreMemberInfoModel> waitingMemberById,  InviteInfoModel? inviteInfoModel, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt, @JsonKey(includeIfNull: false)@TimestampConverter()  DateTime? deletedAt, @JsonKey(includeIfNull: false)@TimestampConverter()  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _StoreModel():
return $default(_that.id,_that.name,_that.address,_that.addressShort,_that.addressGuide,_that.memo,_that.priceSettingsModel,_that.memberById,_that.waitingMemberById,_that.inviteInfoModel,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  String id,  String name,  String address,  String addressShort,  String addressGuide,  String memo,  PriceSettingsModel priceSettingsModel,  Map<String, StoreMemberInfoModel> memberById,  Map<String, StoreMemberInfoModel> waitingMemberById,  InviteInfoModel? inviteInfoModel, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt, @JsonKey(includeIfNull: false)@TimestampConverter()  DateTime? deletedAt, @JsonKey(includeIfNull: false)@TimestampConverter()  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _StoreModel() when $default != null:
return $default(_that.id,_that.name,_that.address,_that.addressShort,_that.addressGuide,_that.memo,_that.priceSettingsModel,_that.memberById,_that.waitingMemberById,_that.inviteInfoModel,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StoreModel extends StoreModel {
  const _StoreModel({@JsonKey(includeToJson: false) required this.id, required this.name, required this.address, required this.addressShort, required this.addressGuide, required this.memo, required this.priceSettingsModel, required final  Map<String, StoreMemberInfoModel> memberById, final  Map<String, StoreMemberInfoModel> waitingMemberById = const {}, this.inviteInfoModel, @TimestampConverter() required this.createdAt, @TimestampConverter() required this.updatedAt, @JsonKey(includeIfNull: false)@TimestampConverter() this.deletedAt, @JsonKey(includeIfNull: false)@TimestampConverter() this.expiresAt}): _memberById = memberById,_waitingMemberById = waitingMemberById,super._();
  factory _StoreModel.fromJson(Map<String, dynamic> json) => _$StoreModelFromJson(json);

@override@JsonKey(includeToJson: false) final  String id;
@override final  String name;
@override final  String address;
@override final  String addressShort;
@override final  String addressGuide;
@override final  String memo;
@override final  PriceSettingsModel priceSettingsModel;
 final  Map<String, StoreMemberInfoModel> _memberById;
@override Map<String, StoreMemberInfoModel> get memberById {
  if (_memberById is EqualUnmodifiableMapView) return _memberById;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_memberById);
}

 final  Map<String, StoreMemberInfoModel> _waitingMemberById;
@override@JsonKey() Map<String, StoreMemberInfoModel> get waitingMemberById {
  if (_waitingMemberById is EqualUnmodifiableMapView) return _waitingMemberById;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_waitingMemberById);
}

@override final  InviteInfoModel? inviteInfoModel;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoreModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.addressShort, addressShort) || other.addressShort == addressShort)&&(identical(other.addressGuide, addressGuide) || other.addressGuide == addressGuide)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.priceSettingsModel, priceSettingsModel) || other.priceSettingsModel == priceSettingsModel)&&const DeepCollectionEquality().equals(other._memberById, _memberById)&&const DeepCollectionEquality().equals(other._waitingMemberById, _waitingMemberById)&&(identical(other.inviteInfoModel, inviteInfoModel) || other.inviteInfoModel == inviteInfoModel)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,address,addressShort,addressGuide,memo,priceSettingsModel,const DeepCollectionEquality().hash(_memberById),const DeepCollectionEquality().hash(_waitingMemberById),inviteInfoModel,createdAt,updatedAt,deletedAt,expiresAt);

@override
String toString() {
  return 'StoreModel(id: $id, name: $name, address: $address, addressShort: $addressShort, addressGuide: $addressGuide, memo: $memo, priceSettingsModel: $priceSettingsModel, memberById: $memberById, waitingMemberById: $waitingMemberById, inviteInfoModel: $inviteInfoModel, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$StoreModelCopyWith<$Res> implements $StoreModelCopyWith<$Res> {
  factory _$StoreModelCopyWith(_StoreModel value, $Res Function(_StoreModel) _then) = __$StoreModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) String id, String name, String address, String addressShort, String addressGuide, String memo, PriceSettingsModel priceSettingsModel, Map<String, StoreMemberInfoModel> memberById, Map<String, StoreMemberInfoModel> waitingMemberById, InviteInfoModel? inviteInfoModel,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt,@JsonKey(includeIfNull: false)@TimestampConverter() DateTime? deletedAt,@JsonKey(includeIfNull: false)@TimestampConverter() DateTime? expiresAt
});


@override $PriceSettingsModelCopyWith<$Res> get priceSettingsModel;@override $InviteInfoModelCopyWith<$Res>? get inviteInfoModel;

}
/// @nodoc
class __$StoreModelCopyWithImpl<$Res>
    implements _$StoreModelCopyWith<$Res> {
  __$StoreModelCopyWithImpl(this._self, this._then);

  final _StoreModel _self;
  final $Res Function(_StoreModel) _then;

/// Create a copy of StoreModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? address = null,Object? addressShort = null,Object? addressGuide = null,Object? memo = null,Object? priceSettingsModel = null,Object? memberById = null,Object? waitingMemberById = null,Object? inviteInfoModel = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? expiresAt = freezed,}) {
  return _then(_StoreModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,addressShort: null == addressShort ? _self.addressShort : addressShort // ignore: cast_nullable_to_non_nullable
as String,addressGuide: null == addressGuide ? _self.addressGuide : addressGuide // ignore: cast_nullable_to_non_nullable
as String,memo: null == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String,priceSettingsModel: null == priceSettingsModel ? _self.priceSettingsModel : priceSettingsModel // ignore: cast_nullable_to_non_nullable
as PriceSettingsModel,memberById: null == memberById ? _self._memberById : memberById // ignore: cast_nullable_to_non_nullable
as Map<String, StoreMemberInfoModel>,waitingMemberById: null == waitingMemberById ? _self._waitingMemberById : waitingMemberById // ignore: cast_nullable_to_non_nullable
as Map<String, StoreMemberInfoModel>,inviteInfoModel: freezed == inviteInfoModel ? _self.inviteInfoModel : inviteInfoModel // ignore: cast_nullable_to_non_nullable
as InviteInfoModel?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
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
$PriceSettingsModelCopyWith<$Res> get priceSettingsModel {
  
  return $PriceSettingsModelCopyWith<$Res>(_self.priceSettingsModel, (value) {
    return _then(_self.copyWith(priceSettingsModel: value));
  });
}/// Create a copy of StoreModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InviteInfoModelCopyWith<$Res>? get inviteInfoModel {
    if (_self.inviteInfoModel == null) {
    return null;
  }

  return $InviteInfoModelCopyWith<$Res>(_self.inviteInfoModel!, (value) {
    return _then(_self.copyWith(inviteInfoModel: value));
  });
}
}

// dart format on
