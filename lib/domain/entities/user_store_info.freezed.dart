// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_store_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserStoreInfo {

 String get id; String get name; UserRole get role; StoreColor get color; String get memo;
/// Create a copy of UserStoreInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserStoreInfoCopyWith<UserStoreInfo> get copyWith => _$UserStoreInfoCopyWithImpl<UserStoreInfo>(this as UserStoreInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserStoreInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.role, role) || other.role == role)&&(identical(other.color, color) || other.color == color)&&(identical(other.memo, memo) || other.memo == memo));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,role,color,memo);

@override
String toString() {
  return 'UserStoreInfo(id: $id, name: $name, role: $role, color: $color, memo: $memo)';
}


}

/// @nodoc
abstract mixin class $UserStoreInfoCopyWith<$Res>  {
  factory $UserStoreInfoCopyWith(UserStoreInfo value, $Res Function(UserStoreInfo) _then) = _$UserStoreInfoCopyWithImpl;
@useResult
$Res call({
 String id, String name, UserRole role, StoreColor color, String memo
});




}
/// @nodoc
class _$UserStoreInfoCopyWithImpl<$Res>
    implements $UserStoreInfoCopyWith<$Res> {
  _$UserStoreInfoCopyWithImpl(this._self, this._then);

  final UserStoreInfo _self;
  final $Res Function(UserStoreInfo) _then;

/// Create a copy of UserStoreInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? role = null,Object? color = null,Object? memo = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as StoreColor,memo: null == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UserStoreInfo].
extension UserStoreInfoPatterns on UserStoreInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserStoreInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserStoreInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserStoreInfo value)  $default,){
final _that = this;
switch (_that) {
case _UserStoreInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserStoreInfo value)?  $default,){
final _that = this;
switch (_that) {
case _UserStoreInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  UserRole role,  StoreColor color,  String memo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserStoreInfo() when $default != null:
return $default(_that.id,_that.name,_that.role,_that.color,_that.memo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  UserRole role,  StoreColor color,  String memo)  $default,) {final _that = this;
switch (_that) {
case _UserStoreInfo():
return $default(_that.id,_that.name,_that.role,_that.color,_that.memo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  UserRole role,  StoreColor color,  String memo)?  $default,) {final _that = this;
switch (_that) {
case _UserStoreInfo() when $default != null:
return $default(_that.id,_that.name,_that.role,_that.color,_that.memo);case _:
  return null;

}
}

}

/// @nodoc


class _UserStoreInfo implements UserStoreInfo {
  const _UserStoreInfo({required this.id, required this.name, required this.role, required this.color, required this.memo});
  

@override final  String id;
@override final  String name;
@override final  UserRole role;
@override final  StoreColor color;
@override final  String memo;

/// Create a copy of UserStoreInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserStoreInfoCopyWith<_UserStoreInfo> get copyWith => __$UserStoreInfoCopyWithImpl<_UserStoreInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserStoreInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.role, role) || other.role == role)&&(identical(other.color, color) || other.color == color)&&(identical(other.memo, memo) || other.memo == memo));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,role,color,memo);

@override
String toString() {
  return 'UserStoreInfo(id: $id, name: $name, role: $role, color: $color, memo: $memo)';
}


}

/// @nodoc
abstract mixin class _$UserStoreInfoCopyWith<$Res> implements $UserStoreInfoCopyWith<$Res> {
  factory _$UserStoreInfoCopyWith(_UserStoreInfo value, $Res Function(_UserStoreInfo) _then) = __$UserStoreInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, UserRole role, StoreColor color, String memo
});




}
/// @nodoc
class __$UserStoreInfoCopyWithImpl<$Res>
    implements _$UserStoreInfoCopyWith<$Res> {
  __$UserStoreInfoCopyWithImpl(this._self, this._then);

  final _UserStoreInfo _self;
  final $Res Function(_UserStoreInfo) _then;

/// Create a copy of UserStoreInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? role = null,Object? color = null,Object? memo = null,}) {
  return _then(_UserStoreInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as StoreColor,memo: null == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
