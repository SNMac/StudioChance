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

 String get inviteCode; AsyncValue<Store?> get status; String get storeAlias; StoreColor get color; String get memo;// 초대 코드 조회(status)와 분리한다. status를 재사용하면 스택에 남아 있는
// 초대 코드 입력 화면의 ref.listen이 제출 완료를 조회 성공으로 오인해
// 점포 확인 화면을 한 번 더 push한다.
 AsyncValue<void> get submitStatus;
/// Create a copy of InviteCodeVerificationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InviteCodeVerificationStateCopyWith<InviteCodeVerificationState> get copyWith => _$InviteCodeVerificationStateCopyWithImpl<InviteCodeVerificationState>(this as InviteCodeVerificationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InviteCodeVerificationState&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.status, status) || other.status == status)&&(identical(other.storeAlias, storeAlias) || other.storeAlias == storeAlias)&&(identical(other.color, color) || other.color == color)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.submitStatus, submitStatus) || other.submitStatus == submitStatus));
}


@override
int get hashCode => Object.hash(runtimeType,inviteCode,status,storeAlias,color,memo,submitStatus);

@override
String toString() {
  return 'InviteCodeVerificationState(inviteCode: $inviteCode, status: $status, storeAlias: $storeAlias, color: $color, memo: $memo, submitStatus: $submitStatus)';
}


}

/// @nodoc
abstract mixin class $InviteCodeVerificationStateCopyWith<$Res>  {
  factory $InviteCodeVerificationStateCopyWith(InviteCodeVerificationState value, $Res Function(InviteCodeVerificationState) _then) = _$InviteCodeVerificationStateCopyWithImpl;
@useResult
$Res call({
 String inviteCode, AsyncValue<Store?> status, String storeAlias, StoreColor color, String memo, AsyncValue<void> submitStatus
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
@pragma('vm:prefer-inline') @override $Res call({Object? inviteCode = null,Object? status = null,Object? storeAlias = null,Object? color = null,Object? memo = null,Object? submitStatus = null,}) {
  return _then(_self.copyWith(
inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AsyncValue<Store?>,storeAlias: null == storeAlias ? _self.storeAlias : storeAlias // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as StoreColor,memo: null == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String,submitStatus: null == submitStatus ? _self.submitStatus : submitStatus // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String inviteCode,  AsyncValue<Store?> status,  String storeAlias,  StoreColor color,  String memo,  AsyncValue<void> submitStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InviteCodeVerificationState() when $default != null:
return $default(_that.inviteCode,_that.status,_that.storeAlias,_that.color,_that.memo,_that.submitStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String inviteCode,  AsyncValue<Store?> status,  String storeAlias,  StoreColor color,  String memo,  AsyncValue<void> submitStatus)  $default,) {final _that = this;
switch (_that) {
case _InviteCodeVerificationState():
return $default(_that.inviteCode,_that.status,_that.storeAlias,_that.color,_that.memo,_that.submitStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String inviteCode,  AsyncValue<Store?> status,  String storeAlias,  StoreColor color,  String memo,  AsyncValue<void> submitStatus)?  $default,) {final _that = this;
switch (_that) {
case _InviteCodeVerificationState() when $default != null:
return $default(_that.inviteCode,_that.status,_that.storeAlias,_that.color,_that.memo,_that.submitStatus);case _:
  return null;

}
}

}

/// @nodoc


class _InviteCodeVerificationState extends InviteCodeVerificationState {
  const _InviteCodeVerificationState({this.inviteCode = '', this.status = const AsyncData(null), this.storeAlias = '', this.color = StoreColor.red, this.memo = '', this.submitStatus = const AsyncData(null)}): super._();
  

@override@JsonKey() final  String inviteCode;
@override@JsonKey() final  AsyncValue<Store?> status;
@override@JsonKey() final  String storeAlias;
@override@JsonKey() final  StoreColor color;
@override@JsonKey() final  String memo;
// 초대 코드 조회(status)와 분리한다. status를 재사용하면 스택에 남아 있는
// 초대 코드 입력 화면의 ref.listen이 제출 완료를 조회 성공으로 오인해
// 점포 확인 화면을 한 번 더 push한다.
@override@JsonKey() final  AsyncValue<void> submitStatus;

/// Create a copy of InviteCodeVerificationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InviteCodeVerificationStateCopyWith<_InviteCodeVerificationState> get copyWith => __$InviteCodeVerificationStateCopyWithImpl<_InviteCodeVerificationState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InviteCodeVerificationState&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.status, status) || other.status == status)&&(identical(other.storeAlias, storeAlias) || other.storeAlias == storeAlias)&&(identical(other.color, color) || other.color == color)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.submitStatus, submitStatus) || other.submitStatus == submitStatus));
}


@override
int get hashCode => Object.hash(runtimeType,inviteCode,status,storeAlias,color,memo,submitStatus);

@override
String toString() {
  return 'InviteCodeVerificationState(inviteCode: $inviteCode, status: $status, storeAlias: $storeAlias, color: $color, memo: $memo, submitStatus: $submitStatus)';
}


}

/// @nodoc
abstract mixin class _$InviteCodeVerificationStateCopyWith<$Res> implements $InviteCodeVerificationStateCopyWith<$Res> {
  factory _$InviteCodeVerificationStateCopyWith(_InviteCodeVerificationState value, $Res Function(_InviteCodeVerificationState) _then) = __$InviteCodeVerificationStateCopyWithImpl;
@override @useResult
$Res call({
 String inviteCode, AsyncValue<Store?> status, String storeAlias, StoreColor color, String memo, AsyncValue<void> submitStatus
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
@override @pragma('vm:prefer-inline') $Res call({Object? inviteCode = null,Object? status = null,Object? storeAlias = null,Object? color = null,Object? memo = null,Object? submitStatus = null,}) {
  return _then(_InviteCodeVerificationState(
inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AsyncValue<Store?>,storeAlias: null == storeAlias ? _self.storeAlias : storeAlias // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as StoreColor,memo: null == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String,submitStatus: null == submitStatus ? _self.submitStatus : submitStatus // ignore: cast_nullable_to_non_nullable
as AsyncValue<void>,
  ));
}


}

// dart format on
