// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Store {

 String get id; String get name; String get address; String get memo; StoreColor get color; List<User> get members; List<User> get waitingMembers; PriceSetting get priceSettings; InviteInfo? get inviteInfo; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoreCopyWith<Store> get copyWith => _$StoreCopyWithImpl<Store>(this as Store, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Store&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.color, color) || other.color == color)&&const DeepCollectionEquality().equals(other.members, members)&&const DeepCollectionEquality().equals(other.waitingMembers, waitingMembers)&&(identical(other.priceSettings, priceSettings) || other.priceSettings == priceSettings)&&(identical(other.inviteInfo, inviteInfo) || other.inviteInfo == inviteInfo)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,address,memo,color,const DeepCollectionEquality().hash(members),const DeepCollectionEquality().hash(waitingMembers),priceSettings,inviteInfo,createdAt,updatedAt);

@override
String toString() {
  return 'Store(id: $id, name: $name, address: $address, memo: $memo, color: $color, members: $members, waitingMembers: $waitingMembers, priceSettings: $priceSettings, inviteInfo: $inviteInfo, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $StoreCopyWith<$Res>  {
  factory $StoreCopyWith(Store value, $Res Function(Store) _then) = _$StoreCopyWithImpl;
@useResult
$Res call({
 String id, String name, String address, String memo, StoreColor color, List<User> members, List<User> waitingMembers, PriceSetting priceSettings, InviteInfo? inviteInfo, DateTime? createdAt, DateTime? updatedAt
});


$PriceSettingCopyWith<$Res> get priceSettings;$InviteInfoCopyWith<$Res>? get inviteInfo;

}
/// @nodoc
class _$StoreCopyWithImpl<$Res>
    implements $StoreCopyWith<$Res> {
  _$StoreCopyWithImpl(this._self, this._then);

  final Store _self;
  final $Res Function(Store) _then;

/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? address = null,Object? memo = null,Object? color = null,Object? members = null,Object? waitingMembers = null,Object? priceSettings = null,Object? inviteInfo = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,memo: null == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as StoreColor,members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as List<User>,waitingMembers: null == waitingMembers ? _self.waitingMembers : waitingMembers // ignore: cast_nullable_to_non_nullable
as List<User>,priceSettings: null == priceSettings ? _self.priceSettings : priceSettings // ignore: cast_nullable_to_non_nullable
as PriceSetting,inviteInfo: freezed == inviteInfo ? _self.inviteInfo : inviteInfo // ignore: cast_nullable_to_non_nullable
as InviteInfo?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceSettingCopyWith<$Res> get priceSettings {
  
  return $PriceSettingCopyWith<$Res>(_self.priceSettings, (value) {
    return _then(_self.copyWith(priceSettings: value));
  });
}/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InviteInfoCopyWith<$Res>? get inviteInfo {
    if (_self.inviteInfo == null) {
    return null;
  }

  return $InviteInfoCopyWith<$Res>(_self.inviteInfo!, (value) {
    return _then(_self.copyWith(inviteInfo: value));
  });
}
}


/// Adds pattern-matching-related methods to [Store].
extension StorePatterns on Store {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Store value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Store() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Store value)  $default,){
final _that = this;
switch (_that) {
case _Store():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Store value)?  $default,){
final _that = this;
switch (_that) {
case _Store() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String address,  String memo,  StoreColor color,  List<User> members,  List<User> waitingMembers,  PriceSetting priceSettings,  InviteInfo? inviteInfo,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Store() when $default != null:
return $default(_that.id,_that.name,_that.address,_that.memo,_that.color,_that.members,_that.waitingMembers,_that.priceSettings,_that.inviteInfo,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String address,  String memo,  StoreColor color,  List<User> members,  List<User> waitingMembers,  PriceSetting priceSettings,  InviteInfo? inviteInfo,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Store():
return $default(_that.id,_that.name,_that.address,_that.memo,_that.color,_that.members,_that.waitingMembers,_that.priceSettings,_that.inviteInfo,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String address,  String memo,  StoreColor color,  List<User> members,  List<User> waitingMembers,  PriceSetting priceSettings,  InviteInfo? inviteInfo,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Store() when $default != null:
return $default(_that.id,_that.name,_that.address,_that.memo,_that.color,_that.members,_that.waitingMembers,_that.priceSettings,_that.inviteInfo,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Store implements Store {
  const _Store({required this.id, required this.name, required this.address, required this.memo, required this.color, required final  List<User> members, required final  List<User> waitingMembers, required this.priceSettings, required this.inviteInfo, required this.createdAt, required this.updatedAt}): _members = members,_waitingMembers = waitingMembers;
  

@override final  String id;
@override final  String name;
@override final  String address;
@override final  String memo;
@override final  StoreColor color;
 final  List<User> _members;
@override List<User> get members {
  if (_members is EqualUnmodifiableListView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_members);
}

 final  List<User> _waitingMembers;
@override List<User> get waitingMembers {
  if (_waitingMembers is EqualUnmodifiableListView) return _waitingMembers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_waitingMembers);
}

@override final  PriceSetting priceSettings;
@override final  InviteInfo? inviteInfo;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoreCopyWith<_Store> get copyWith => __$StoreCopyWithImpl<_Store>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Store&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.color, color) || other.color == color)&&const DeepCollectionEquality().equals(other._members, _members)&&const DeepCollectionEquality().equals(other._waitingMembers, _waitingMembers)&&(identical(other.priceSettings, priceSettings) || other.priceSettings == priceSettings)&&(identical(other.inviteInfo, inviteInfo) || other.inviteInfo == inviteInfo)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,address,memo,color,const DeepCollectionEquality().hash(_members),const DeepCollectionEquality().hash(_waitingMembers),priceSettings,inviteInfo,createdAt,updatedAt);

@override
String toString() {
  return 'Store(id: $id, name: $name, address: $address, memo: $memo, color: $color, members: $members, waitingMembers: $waitingMembers, priceSettings: $priceSettings, inviteInfo: $inviteInfo, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$StoreCopyWith<$Res> implements $StoreCopyWith<$Res> {
  factory _$StoreCopyWith(_Store value, $Res Function(_Store) _then) = __$StoreCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String address, String memo, StoreColor color, List<User> members, List<User> waitingMembers, PriceSetting priceSettings, InviteInfo? inviteInfo, DateTime? createdAt, DateTime? updatedAt
});


@override $PriceSettingCopyWith<$Res> get priceSettings;@override $InviteInfoCopyWith<$Res>? get inviteInfo;

}
/// @nodoc
class __$StoreCopyWithImpl<$Res>
    implements _$StoreCopyWith<$Res> {
  __$StoreCopyWithImpl(this._self, this._then);

  final _Store _self;
  final $Res Function(_Store) _then;

/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? address = null,Object? memo = null,Object? color = null,Object? members = null,Object? waitingMembers = null,Object? priceSettings = null,Object? inviteInfo = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Store(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,memo: null == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as StoreColor,members: null == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as List<User>,waitingMembers: null == waitingMembers ? _self._waitingMembers : waitingMembers // ignore: cast_nullable_to_non_nullable
as List<User>,priceSettings: null == priceSettings ? _self.priceSettings : priceSettings // ignore: cast_nullable_to_non_nullable
as PriceSetting,inviteInfo: freezed == inviteInfo ? _self.inviteInfo : inviteInfo // ignore: cast_nullable_to_non_nullable
as InviteInfo?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceSettingCopyWith<$Res> get priceSettings {
  
  return $PriceSettingCopyWith<$Res>(_self.priceSettings, (value) {
    return _then(_self.copyWith(priceSettings: value));
  });
}/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InviteInfoCopyWith<$Res>? get inviteInfo {
    if (_self.inviteInfo == null) {
    return null;
  }

  return $InviteInfoCopyWith<$Res>(_self.inviteInfo!, (value) {
    return _then(_self.copyWith(inviteInfo: value));
  });
}
}

// dart format on
