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

 String get id; List<String> get adminIds; String get name; String get color; List<User> get members; PriceSetting get priceSettings; InviteInfo? get inviteInfo;
/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoreCopyWith<Store> get copyWith => _$StoreCopyWithImpl<Store>(this as Store, _$identity);

  /// Serializes this Store to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Store&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.adminIds, adminIds)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&const DeepCollectionEquality().equals(other.members, members)&&(identical(other.priceSettings, priceSettings) || other.priceSettings == priceSettings)&&(identical(other.inviteInfo, inviteInfo) || other.inviteInfo == inviteInfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(adminIds),name,color,const DeepCollectionEquality().hash(members),priceSettings,inviteInfo);

@override
String toString() {
  return 'Store(id: $id, adminIds: $adminIds, name: $name, color: $color, members: $members, priceSettings: $priceSettings, inviteInfo: $inviteInfo)';
}


}

/// @nodoc
abstract mixin class $StoreCopyWith<$Res>  {
  factory $StoreCopyWith(Store value, $Res Function(Store) _then) = _$StoreCopyWithImpl;
@useResult
$Res call({
 String id, List<String> adminIds, String name, String color, List<User> members, PriceSetting priceSettings, InviteInfo? inviteInfo
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? adminIds = null,Object? name = null,Object? color = null,Object? members = null,Object? priceSettings = null,Object? inviteInfo = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,adminIds: null == adminIds ? _self.adminIds : adminIds // ignore: cast_nullable_to_non_nullable
as List<String>,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as List<User>,priceSettings: null == priceSettings ? _self.priceSettings : priceSettings // ignore: cast_nullable_to_non_nullable
as PriceSetting,inviteInfo: freezed == inviteInfo ? _self.inviteInfo : inviteInfo // ignore: cast_nullable_to_non_nullable
as InviteInfo?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  List<String> adminIds,  String name,  String color,  List<User> members,  PriceSetting priceSettings,  InviteInfo? inviteInfo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Store() when $default != null:
return $default(_that.id,_that.adminIds,_that.name,_that.color,_that.members,_that.priceSettings,_that.inviteInfo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  List<String> adminIds,  String name,  String color,  List<User> members,  PriceSetting priceSettings,  InviteInfo? inviteInfo)  $default,) {final _that = this;
switch (_that) {
case _Store():
return $default(_that.id,_that.adminIds,_that.name,_that.color,_that.members,_that.priceSettings,_that.inviteInfo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  List<String> adminIds,  String name,  String color,  List<User> members,  PriceSetting priceSettings,  InviteInfo? inviteInfo)?  $default,) {final _that = this;
switch (_that) {
case _Store() when $default != null:
return $default(_that.id,_that.adminIds,_that.name,_that.color,_that.members,_that.priceSettings,_that.inviteInfo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Store implements Store {
  const _Store({required this.id, required final  List<String> adminIds, required this.name, required this.color, required final  List<User> members, required this.priceSettings, required this.inviteInfo}): _adminIds = adminIds,_members = members;
  factory _Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);

@override final  String id;
 final  List<String> _adminIds;
@override List<String> get adminIds {
  if (_adminIds is EqualUnmodifiableListView) return _adminIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_adminIds);
}

@override final  String name;
@override final  String color;
 final  List<User> _members;
@override List<User> get members {
  if (_members is EqualUnmodifiableListView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_members);
}

@override final  PriceSetting priceSettings;
@override final  InviteInfo? inviteInfo;

/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoreCopyWith<_Store> get copyWith => __$StoreCopyWithImpl<_Store>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StoreToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Store&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._adminIds, _adminIds)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&const DeepCollectionEquality().equals(other._members, _members)&&(identical(other.priceSettings, priceSettings) || other.priceSettings == priceSettings)&&(identical(other.inviteInfo, inviteInfo) || other.inviteInfo == inviteInfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_adminIds),name,color,const DeepCollectionEquality().hash(_members),priceSettings,inviteInfo);

@override
String toString() {
  return 'Store(id: $id, adminIds: $adminIds, name: $name, color: $color, members: $members, priceSettings: $priceSettings, inviteInfo: $inviteInfo)';
}


}

/// @nodoc
abstract mixin class _$StoreCopyWith<$Res> implements $StoreCopyWith<$Res> {
  factory _$StoreCopyWith(_Store value, $Res Function(_Store) _then) = __$StoreCopyWithImpl;
@override @useResult
$Res call({
 String id, List<String> adminIds, String name, String color, List<User> members, PriceSetting priceSettings, InviteInfo? inviteInfo
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? adminIds = null,Object? name = null,Object? color = null,Object? members = null,Object? priceSettings = null,Object? inviteInfo = freezed,}) {
  return _then(_Store(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,adminIds: null == adminIds ? _self._adminIds : adminIds // ignore: cast_nullable_to_non_nullable
as List<String>,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,members: null == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as List<User>,priceSettings: null == priceSettings ? _self.priceSettings : priceSettings // ignore: cast_nullable_to_non_nullable
as PriceSetting,inviteInfo: freezed == inviteInfo ? _self.inviteInfo : inviteInfo // ignore: cast_nullable_to_non_nullable
as InviteInfo?,
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
