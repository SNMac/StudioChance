// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invite_code_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InviteCodeFormState {

 String get inviteCode; AsyncValue<void> get status;
/// Create a copy of InviteCodeFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InviteCodeFormStateCopyWith<InviteCodeFormState> get copyWith => _$InviteCodeFormStateCopyWithImpl<InviteCodeFormState>(this as InviteCodeFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InviteCodeFormState&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,inviteCode,status);

@override
String toString() {
  return 'InviteCodeFormState(inviteCode: $inviteCode, status: $status)';
}


}

/// @nodoc
abstract mixin class $InviteCodeFormStateCopyWith<$Res>  {
  factory $InviteCodeFormStateCopyWith(InviteCodeFormState value, $Res Function(InviteCodeFormState) _then) = _$InviteCodeFormStateCopyWithImpl;
@useResult
$Res call({
 String inviteCode, AsyncValue<void> status
});




}
/// @nodoc
class _$InviteCodeFormStateCopyWithImpl<$Res>
    implements $InviteCodeFormStateCopyWith<$Res> {
  _$InviteCodeFormStateCopyWithImpl(this._self, this._then);

  final InviteCodeFormState _self;
  final $Res Function(InviteCodeFormState) _then;

/// Create a copy of InviteCodeFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? inviteCode = null,Object? status = null,}) {
  return _then(_self.copyWith(
inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AsyncValue<void>,
  ));
}

}


/// Adds pattern-matching-related methods to [InviteCodeFormState].
extension InviteCodeFormStatePatterns on InviteCodeFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InviteCodeFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InviteCodeFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InviteCodeFormState value)  $default,){
final _that = this;
switch (_that) {
case _InviteCodeFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InviteCodeFormState value)?  $default,){
final _that = this;
switch (_that) {
case _InviteCodeFormState() when $default != null:
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
case _InviteCodeFormState() when $default != null:
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
case _InviteCodeFormState():
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
case _InviteCodeFormState() when $default != null:
return $default(_that.inviteCode,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _InviteCodeFormState extends InviteCodeFormState {
  const _InviteCodeFormState({this.inviteCode = '', this.status = const AsyncValue.data(null)}): super._();
  

@override@JsonKey() final  String inviteCode;
@override@JsonKey() final  AsyncValue<void> status;

/// Create a copy of InviteCodeFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InviteCodeFormStateCopyWith<_InviteCodeFormState> get copyWith => __$InviteCodeFormStateCopyWithImpl<_InviteCodeFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InviteCodeFormState&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,inviteCode,status);

@override
String toString() {
  return 'InviteCodeFormState(inviteCode: $inviteCode, status: $status)';
}


}

/// @nodoc
abstract mixin class _$InviteCodeFormStateCopyWith<$Res> implements $InviteCodeFormStateCopyWith<$Res> {
  factory _$InviteCodeFormStateCopyWith(_InviteCodeFormState value, $Res Function(_InviteCodeFormState) _then) = __$InviteCodeFormStateCopyWithImpl;
@override @useResult
$Res call({
 String inviteCode, AsyncValue<void> status
});




}
/// @nodoc
class __$InviteCodeFormStateCopyWithImpl<$Res>
    implements _$InviteCodeFormStateCopyWith<$Res> {
  __$InviteCodeFormStateCopyWithImpl(this._self, this._then);

  final _InviteCodeFormState _self;
  final $Res Function(_InviteCodeFormState) _then;

/// Create a copy of InviteCodeFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? inviteCode = null,Object? status = null,}) {
  return _then(_InviteCodeFormState(
inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AsyncValue<void>,
  ));
}


}

// dart format on
