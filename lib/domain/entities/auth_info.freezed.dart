// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthInfo {

 String get uid; String? get email; String? get displayName; List<String> get authProviders;
/// Create a copy of AuthInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthInfoCopyWith<AuthInfo> get copyWith => _$AuthInfoCopyWithImpl<AuthInfo>(this as AuthInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthInfo&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&const DeepCollectionEquality().equals(other.authProviders, authProviders));
}


@override
int get hashCode => Object.hash(runtimeType,uid,email,displayName,const DeepCollectionEquality().hash(authProviders));

@override
String toString() {
  return 'AuthInfo(uid: $uid, email: $email, displayName: $displayName, authProviders: $authProviders)';
}


}

/// @nodoc
abstract mixin class $AuthInfoCopyWith<$Res>  {
  factory $AuthInfoCopyWith(AuthInfo value, $Res Function(AuthInfo) _then) = _$AuthInfoCopyWithImpl;
@useResult
$Res call({
 String uid, String? email, String? displayName, List<String> authProviders
});




}
/// @nodoc
class _$AuthInfoCopyWithImpl<$Res>
    implements $AuthInfoCopyWith<$Res> {
  _$AuthInfoCopyWithImpl(this._self, this._then);

  final AuthInfo _self;
  final $Res Function(AuthInfo) _then;

/// Create a copy of AuthInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? email = freezed,Object? displayName = freezed,Object? authProviders = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,authProviders: null == authProviders ? _self.authProviders : authProviders // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthInfo].
extension AuthInfoPatterns on AuthInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthInfo value)  $default,){
final _that = this;
switch (_that) {
case _AuthInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthInfo value)?  $default,){
final _that = this;
switch (_that) {
case _AuthInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String? email,  String? displayName,  List<String> authProviders)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthInfo() when $default != null:
return $default(_that.uid,_that.email,_that.displayName,_that.authProviders);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String? email,  String? displayName,  List<String> authProviders)  $default,) {final _that = this;
switch (_that) {
case _AuthInfo():
return $default(_that.uid,_that.email,_that.displayName,_that.authProviders);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String? email,  String? displayName,  List<String> authProviders)?  $default,) {final _that = this;
switch (_that) {
case _AuthInfo() when $default != null:
return $default(_that.uid,_that.email,_that.displayName,_that.authProviders);case _:
  return null;

}
}

}

/// @nodoc


class _AuthInfo implements AuthInfo {
  const _AuthInfo({required this.uid, required this.email, required this.displayName, required final  List<String> authProviders}): _authProviders = authProviders;
  

@override final  String uid;
@override final  String? email;
@override final  String? displayName;
 final  List<String> _authProviders;
@override List<String> get authProviders {
  if (_authProviders is EqualUnmodifiableListView) return _authProviders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_authProviders);
}


/// Create a copy of AuthInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthInfoCopyWith<_AuthInfo> get copyWith => __$AuthInfoCopyWithImpl<_AuthInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthInfo&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&const DeepCollectionEquality().equals(other._authProviders, _authProviders));
}


@override
int get hashCode => Object.hash(runtimeType,uid,email,displayName,const DeepCollectionEquality().hash(_authProviders));

@override
String toString() {
  return 'AuthInfo(uid: $uid, email: $email, displayName: $displayName, authProviders: $authProviders)';
}


}

/// @nodoc
abstract mixin class _$AuthInfoCopyWith<$Res> implements $AuthInfoCopyWith<$Res> {
  factory _$AuthInfoCopyWith(_AuthInfo value, $Res Function(_AuthInfo) _then) = __$AuthInfoCopyWithImpl;
@override @useResult
$Res call({
 String uid, String? email, String? displayName, List<String> authProviders
});




}
/// @nodoc
class __$AuthInfoCopyWithImpl<$Res>
    implements _$AuthInfoCopyWith<$Res> {
  __$AuthInfoCopyWithImpl(this._self, this._then);

  final _AuthInfo _self;
  final $Res Function(_AuthInfo) _then;

/// Create a copy of AuthInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? email = freezed,Object? displayName = freezed,Object? authProviders = null,}) {
  return _then(_AuthInfo(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,authProviders: null == authProviders ? _self._authProviders : authProviders // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
