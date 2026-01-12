// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store_member_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StoreMemberInfo {

 User get user; UserRole get role;
/// Create a copy of StoreMemberInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoreMemberInfoCopyWith<StoreMemberInfo> get copyWith => _$StoreMemberInfoCopyWithImpl<StoreMemberInfo>(this as StoreMemberInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoreMemberInfo&&(identical(other.user, user) || other.user == user)&&(identical(other.role, role) || other.role == role));
}


@override
int get hashCode => Object.hash(runtimeType,user,role);

@override
String toString() {
  return 'StoreMemberInfo(user: $user, role: $role)';
}


}

/// @nodoc
abstract mixin class $StoreMemberInfoCopyWith<$Res>  {
  factory $StoreMemberInfoCopyWith(StoreMemberInfo value, $Res Function(StoreMemberInfo) _then) = _$StoreMemberInfoCopyWithImpl;
@useResult
$Res call({
 User user, UserRole role
});


$UserCopyWith<$Res> get user;

}
/// @nodoc
class _$StoreMemberInfoCopyWithImpl<$Res>
    implements $StoreMemberInfoCopyWith<$Res> {
  _$StoreMemberInfoCopyWithImpl(this._self, this._then);

  final StoreMemberInfo _self;
  final $Res Function(StoreMemberInfo) _then;

/// Create a copy of StoreMemberInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = null,Object? role = null,}) {
  return _then(_self.copyWith(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,
  ));
}
/// Create a copy of StoreMemberInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [StoreMemberInfo].
extension StoreMemberInfoPatterns on StoreMemberInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoreMemberInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoreMemberInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoreMemberInfo value)  $default,){
final _that = this;
switch (_that) {
case _StoreMemberInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoreMemberInfo value)?  $default,){
final _that = this;
switch (_that) {
case _StoreMemberInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( User user,  UserRole role)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoreMemberInfo() when $default != null:
return $default(_that.user,_that.role);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( User user,  UserRole role)  $default,) {final _that = this;
switch (_that) {
case _StoreMemberInfo():
return $default(_that.user,_that.role);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( User user,  UserRole role)?  $default,) {final _that = this;
switch (_that) {
case _StoreMemberInfo() when $default != null:
return $default(_that.user,_that.role);case _:
  return null;

}
}

}

/// @nodoc


class _StoreMemberInfo implements StoreMemberInfo {
  const _StoreMemberInfo({required this.user, required this.role});
  

@override final  User user;
@override final  UserRole role;

/// Create a copy of StoreMemberInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoreMemberInfoCopyWith<_StoreMemberInfo> get copyWith => __$StoreMemberInfoCopyWithImpl<_StoreMemberInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoreMemberInfo&&(identical(other.user, user) || other.user == user)&&(identical(other.role, role) || other.role == role));
}


@override
int get hashCode => Object.hash(runtimeType,user,role);

@override
String toString() {
  return 'StoreMemberInfo(user: $user, role: $role)';
}


}

/// @nodoc
abstract mixin class _$StoreMemberInfoCopyWith<$Res> implements $StoreMemberInfoCopyWith<$Res> {
  factory _$StoreMemberInfoCopyWith(_StoreMemberInfo value, $Res Function(_StoreMemberInfo) _then) = __$StoreMemberInfoCopyWithImpl;
@override @useResult
$Res call({
 User user, UserRole role
});


@override $UserCopyWith<$Res> get user;

}
/// @nodoc
class __$StoreMemberInfoCopyWithImpl<$Res>
    implements _$StoreMemberInfoCopyWith<$Res> {
  __$StoreMemberInfoCopyWithImpl(this._self, this._then);

  final _StoreMemberInfo _self;
  final $Res Function(_StoreMemberInfo) _then;

/// Create a copy of StoreMemberInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = null,Object? role = null,}) {
  return _then(_StoreMemberInfo(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,
  ));
}

/// Create a copy of StoreMemberInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
