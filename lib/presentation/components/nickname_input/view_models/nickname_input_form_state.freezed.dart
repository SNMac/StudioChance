// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nickname_input_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NicknameInputFormState {

 String get nickname;
/// Create a copy of NicknameInputFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NicknameInputFormStateCopyWith<NicknameInputFormState> get copyWith => _$NicknameInputFormStateCopyWithImpl<NicknameInputFormState>(this as NicknameInputFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NicknameInputFormState&&(identical(other.nickname, nickname) || other.nickname == nickname));
}


@override
int get hashCode => Object.hash(runtimeType,nickname);

@override
String toString() {
  return 'NicknameInputFormState(nickname: $nickname)';
}


}

/// @nodoc
abstract mixin class $NicknameInputFormStateCopyWith<$Res>  {
  factory $NicknameInputFormStateCopyWith(NicknameInputFormState value, $Res Function(NicknameInputFormState) _then) = _$NicknameInputFormStateCopyWithImpl;
@useResult
$Res call({
 String nickname
});




}
/// @nodoc
class _$NicknameInputFormStateCopyWithImpl<$Res>
    implements $NicknameInputFormStateCopyWith<$Res> {
  _$NicknameInputFormStateCopyWithImpl(this._self, this._then);

  final NicknameInputFormState _self;
  final $Res Function(NicknameInputFormState) _then;

/// Create a copy of NicknameInputFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nickname = null,}) {
  return _then(_self.copyWith(
nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [NicknameInputFormState].
extension NicknameInputFormStatePatterns on NicknameInputFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NicknameInputFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NicknameInputFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NicknameInputFormState value)  $default,){
final _that = this;
switch (_that) {
case _NicknameInputFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NicknameInputFormState value)?  $default,){
final _that = this;
switch (_that) {
case _NicknameInputFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String nickname)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NicknameInputFormState() when $default != null:
return $default(_that.nickname);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String nickname)  $default,) {final _that = this;
switch (_that) {
case _NicknameInputFormState():
return $default(_that.nickname);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String nickname)?  $default,) {final _that = this;
switch (_that) {
case _NicknameInputFormState() when $default != null:
return $default(_that.nickname);case _:
  return null;

}
}

}

/// @nodoc


class _NicknameInputFormState extends NicknameInputFormState {
  const _NicknameInputFormState({this.nickname = ''}): super._();
  

@override@JsonKey() final  String nickname;

/// Create a copy of NicknameInputFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NicknameInputFormStateCopyWith<_NicknameInputFormState> get copyWith => __$NicknameInputFormStateCopyWithImpl<_NicknameInputFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NicknameInputFormState&&(identical(other.nickname, nickname) || other.nickname == nickname));
}


@override
int get hashCode => Object.hash(runtimeType,nickname);

@override
String toString() {
  return 'NicknameInputFormState(nickname: $nickname)';
}


}

/// @nodoc
abstract mixin class _$NicknameInputFormStateCopyWith<$Res> implements $NicknameInputFormStateCopyWith<$Res> {
  factory _$NicknameInputFormStateCopyWith(_NicknameInputFormState value, $Res Function(_NicknameInputFormState) _then) = __$NicknameInputFormStateCopyWithImpl;
@override @useResult
$Res call({
 String nickname
});




}
/// @nodoc
class __$NicknameInputFormStateCopyWithImpl<$Res>
    implements _$NicknameInputFormStateCopyWith<$Res> {
  __$NicknameInputFormStateCopyWithImpl(this._self, this._then);

  final _NicknameInputFormState _self;
  final $Res Function(_NicknameInputFormState) _then;

/// Create a copy of NicknameInputFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nickname = null,}) {
  return _then(_NicknameInputFormState(
nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
