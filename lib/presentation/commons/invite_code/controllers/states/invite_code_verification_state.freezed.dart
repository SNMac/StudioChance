// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invite_code_verification_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InviteCodeVerificationState {

 String get inviteCode; AsyncValue<void> get status;
/// Create a copy of InviteCodeVerificationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InviteCodeVerificationStateCopyWith<InviteCodeVerificationState> get copyWith => _$InviteCodeVerificationStateCopyWithImpl<InviteCodeVerificationState>(this as InviteCodeVerificationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InviteCodeVerificationState&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,inviteCode,status);

@override
String toString() {
  return 'InviteCodeVerificationState(inviteCode: $inviteCode, status: $status)';
}


}

/// @nodoc
abstract mixin class $InviteCodeVerificationStateCopyWith<$Res>  {
  factory $InviteCodeVerificationStateCopyWith(InviteCodeVerificationState value, $Res Function(InviteCodeVerificationState) _then) = _$InviteCodeVerificationStateCopyWithImpl;
@useResult
$Res call({
 String inviteCode, AsyncValue<void> status
});




}
/// @nodoc
class _$InviteCodeVerificationStateCopyWithImpl<$Res>
    implements $InviteCodeVerificationStateCopyWith<$Res> {
  _$InviteCodeVerificationStateCopyWithImpl(this._self, this._then);

  final InviteCodeVerificationState _self;
  final $Res Function(InviteCodeVerificationState) _then;

/// Create a copy of InviteCodeVerificationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? inviteCode = null,Object? status = null,}) {
  return _then(_self.copyWith(
inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AsyncValue<void>,
  ));
}

}


/// Adds pattern-matching-related methods to [InviteCodeVerificationState].
extension InviteCodeVerificationStatePatterns on InviteCodeVerificationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InviteCodeVerificationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InviteCodeVerificationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InviteCodeVerificationState value)  $default,){
final _that = this;
switch (_that) {
case _InviteCodeVerificationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InviteCodeVerificationState value)?  $default,){
final _that = this;
switch (_that) {
case _InviteCodeVerificationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String inviteCode,  AsyncValue<void> status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InviteCodeVerificationState() when $default != null:
return $default(_that.inviteCode,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String inviteCode,  AsyncValue<void> status)  $default,) {final _that = this;
switch (_that) {
case _InviteCodeVerificationState():
return $default(_that.inviteCode,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String inviteCode,  AsyncValue<void> status)?  $default,) {final _that = this;
switch (_that) {
case _InviteCodeVerificationState() when $default != null:
return $default(_that.inviteCode,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _InviteCodeVerificationState extends InviteCodeVerificationState {
  const _InviteCodeVerificationState({this.inviteCode = '', this.status = const AsyncData(null)}): super._();
  

@override@JsonKey() final  String inviteCode;
@override@JsonKey() final  AsyncValue<void> status;

/// Create a copy of InviteCodeVerificationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InviteCodeVerificationStateCopyWith<_InviteCodeVerificationState> get copyWith => __$InviteCodeVerificationStateCopyWithImpl<_InviteCodeVerificationState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InviteCodeVerificationState&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,inviteCode,status);

@override
String toString() {
  return 'InviteCodeVerificationState(inviteCode: $inviteCode, status: $status)';
}


}

/// @nodoc
abstract mixin class _$InviteCodeVerificationStateCopyWith<$Res> implements $InviteCodeVerificationStateCopyWith<$Res> {
  factory _$InviteCodeVerificationStateCopyWith(_InviteCodeVerificationState value, $Res Function(_InviteCodeVerificationState) _then) = __$InviteCodeVerificationStateCopyWithImpl;
@override @useResult
$Res call({
 String inviteCode, AsyncValue<void> status
});




}
/// @nodoc
class __$InviteCodeVerificationStateCopyWithImpl<$Res>
    implements _$InviteCodeVerificationStateCopyWith<$Res> {
  __$InviteCodeVerificationStateCopyWithImpl(this._self, this._then);

  final _InviteCodeVerificationState _self;
  final $Res Function(_InviteCodeVerificationState) _then;

/// Create a copy of InviteCodeVerificationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? inviteCode = null,Object? status = null,}) {
  return _then(_InviteCodeVerificationState(
inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AsyncValue<void>,
  ));
}


}

// dart format on
