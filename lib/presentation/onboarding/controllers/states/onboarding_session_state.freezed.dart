// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_session_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OnboardingSessionState {

 String get nickname; UserRole get selectedRole; AsyncValue<void> get status;
/// Create a copy of OnboardingSessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingSessionStateCopyWith<OnboardingSessionState> get copyWith => _$OnboardingSessionStateCopyWithImpl<OnboardingSessionState>(this as OnboardingSessionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingSessionState&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.selectedRole, selectedRole) || other.selectedRole == selectedRole)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,nickname,selectedRole,status);

@override
String toString() {
  return 'OnboardingSessionState(nickname: $nickname, selectedRole: $selectedRole, status: $status)';
}


}

/// @nodoc
abstract mixin class $OnboardingSessionStateCopyWith<$Res>  {
  factory $OnboardingSessionStateCopyWith(OnboardingSessionState value, $Res Function(OnboardingSessionState) _then) = _$OnboardingSessionStateCopyWithImpl;
@useResult
$Res call({
 String nickname, UserRole selectedRole, AsyncValue<void> status
});




}
/// @nodoc
class _$OnboardingSessionStateCopyWithImpl<$Res>
    implements $OnboardingSessionStateCopyWith<$Res> {
  _$OnboardingSessionStateCopyWithImpl(this._self, this._then);

  final OnboardingSessionState _self;
  final $Res Function(OnboardingSessionState) _then;

/// Create a copy of OnboardingSessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nickname = null,Object? selectedRole = null,Object? status = null,}) {
  return _then(_self.copyWith(
nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,selectedRole: null == selectedRole ? _self.selectedRole : selectedRole // ignore: cast_nullable_to_non_nullable
as UserRole,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AsyncValue<void>,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardingSessionState].
extension OnboardingSessionStatePatterns on OnboardingSessionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnboardingSessionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingSessionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnboardingSessionState value)  $default,){
final _that = this;
switch (_that) {
case _OnboardingSessionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnboardingSessionState value)?  $default,){
final _that = this;
switch (_that) {
case _OnboardingSessionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String nickname,  UserRole selectedRole,  AsyncValue<void> status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingSessionState() when $default != null:
return $default(_that.nickname,_that.selectedRole,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String nickname,  UserRole selectedRole,  AsyncValue<void> status)  $default,) {final _that = this;
switch (_that) {
case _OnboardingSessionState():
return $default(_that.nickname,_that.selectedRole,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String nickname,  UserRole selectedRole,  AsyncValue<void> status)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingSessionState() when $default != null:
return $default(_that.nickname,_that.selectedRole,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _OnboardingSessionState extends OnboardingSessionState {
  const _OnboardingSessionState({this.nickname = '', this.selectedRole = UserRole.none, this.status = const AsyncData(null)}): super._();
  

@override@JsonKey() final  String nickname;
@override@JsonKey() final  UserRole selectedRole;
@override@JsonKey() final  AsyncValue<void> status;

/// Create a copy of OnboardingSessionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingSessionStateCopyWith<_OnboardingSessionState> get copyWith => __$OnboardingSessionStateCopyWithImpl<_OnboardingSessionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingSessionState&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.selectedRole, selectedRole) || other.selectedRole == selectedRole)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,nickname,selectedRole,status);

@override
String toString() {
  return 'OnboardingSessionState(nickname: $nickname, selectedRole: $selectedRole, status: $status)';
}


}

/// @nodoc
abstract mixin class _$OnboardingSessionStateCopyWith<$Res> implements $OnboardingSessionStateCopyWith<$Res> {
  factory _$OnboardingSessionStateCopyWith(_OnboardingSessionState value, $Res Function(_OnboardingSessionState) _then) = __$OnboardingSessionStateCopyWithImpl;
@override @useResult
$Res call({
 String nickname, UserRole selectedRole, AsyncValue<void> status
});




}
/// @nodoc
class __$OnboardingSessionStateCopyWithImpl<$Res>
    implements _$OnboardingSessionStateCopyWith<$Res> {
  __$OnboardingSessionStateCopyWithImpl(this._self, this._then);

  final _OnboardingSessionState _self;
  final $Res Function(_OnboardingSessionState) _then;

/// Create a copy of OnboardingSessionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nickname = null,Object? selectedRole = null,Object? status = null,}) {
  return _then(_OnboardingSessionState(
nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,selectedRole: null == selectedRole ? _self.selectedRole : selectedRole // ignore: cast_nullable_to_non_nullable
as UserRole,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AsyncValue<void>,
  ));
}


}

// dart format on
