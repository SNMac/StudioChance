// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invite_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InviteInfo {

 String get inviteCode;/// 서버가 정한 발급 시각 (Callable `issueInviteCode`, ADR-0006).
 DateTime? get createdAt;
/// Create a copy of InviteInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InviteInfoCopyWith<InviteInfo> get copyWith => _$InviteInfoCopyWithImpl<InviteInfo>(this as InviteInfo, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InviteInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InviteInfo&&(identical(other.inviteCode, _this.inviteCode) || other.inviteCode == _this.inviteCode)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}


@override
int get hashCode {
  final _this = this as InviteInfo;
  return Object.hash(runtimeType,_this.inviteCode,_this.createdAt);
}

@override
String toString() {
  final _this = this as InviteInfo;
  return 'InviteInfo(inviteCode: ${_this.inviteCode}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $InviteInfoCopyWith<$Res>  {
  factory $InviteInfoCopyWith(InviteInfo value, $Res Function(InviteInfo) _then) = _$InviteInfoCopyWithImpl;
@useResult
$Res call({
 String inviteCode, DateTime? createdAt
});




}
/// @nodoc
class _$InviteInfoCopyWithImpl<$Res>
    implements $InviteInfoCopyWith<$Res> {
  _$InviteInfoCopyWithImpl(this._self, this._then);

  final InviteInfo _self;
  final $Res Function(InviteInfo) _then;

/// Create a copy of InviteInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? inviteCode = null,Object? createdAt = freezed,}) {
  return _then(InviteInfo(
inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [InviteInfo].
extension InviteInfoPatterns on InviteInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InviteInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InviteInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InviteInfo value)  $default,){
final _that = this;
switch (_that) {
case _InviteInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InviteInfo value)?  $default,){
final _that = this;
switch (_that) {
case _InviteInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String inviteCode,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InviteInfo() when $default != null:
return $default(_that.inviteCode,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String inviteCode,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _InviteInfo():
return $default(_that.inviteCode,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String inviteCode,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _InviteInfo() when $default != null:
return $default(_that.inviteCode,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _InviteInfo extends InviteInfo {
  const _InviteInfo({required this.inviteCode, this.createdAt}): super._();
  

@override final  String inviteCode;
/// 서버가 정한 발급 시각 (Callable `issueInviteCode`, ADR-0006).
@override final  DateTime? createdAt;

/// Create a copy of InviteInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InviteInfoCopyWith<_InviteInfo> get copyWith => __$InviteInfoCopyWithImpl<_InviteInfo>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InviteInfo&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,inviteCode,createdAt);
}

@override
String toString() {
    return 'InviteInfo(inviteCode: $inviteCode, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$InviteInfoCopyWith<$Res> implements $InviteInfoCopyWith<$Res> {
  factory _$InviteInfoCopyWith(_InviteInfo value, $Res Function(_InviteInfo) _then) = __$InviteInfoCopyWithImpl;
@override @useResult
$Res call({
 String inviteCode, DateTime? createdAt
});




}
/// @nodoc
class __$InviteInfoCopyWithImpl<$Res>
    implements _$InviteInfoCopyWith<$Res> {
  __$InviteInfoCopyWithImpl(this._self, this._then);

  final _InviteInfo _self;
  final $Res Function(_InviteInfo) _then;

/// Create a copy of InviteInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? inviteCode = null,Object? createdAt = freezed,}) {
  return _then(_InviteInfo(
inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
