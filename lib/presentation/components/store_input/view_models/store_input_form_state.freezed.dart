// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store_input_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StoreInputFormState {

 String get name; String get address; String get memo; StoreColor get color;// 기본 색상
// 복잡한 객체는 nullable로 두거나, 기본값을 상수로 정의해서 넣어줌
 PriceSetting get priceSettings;
/// Create a copy of StoreInputFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoreInputFormStateCopyWith<StoreInputFormState> get copyWith => _$StoreInputFormStateCopyWithImpl<StoreInputFormState>(this as StoreInputFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoreInputFormState&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.color, color) || other.color == color)&&(identical(other.priceSettings, priceSettings) || other.priceSettings == priceSettings));
}


@override
int get hashCode => Object.hash(runtimeType,name,address,memo,color,priceSettings);

@override
String toString() {
  return 'StoreInputFormState(name: $name, address: $address, memo: $memo, color: $color, priceSettings: $priceSettings)';
}


}

/// @nodoc
abstract mixin class $StoreInputFormStateCopyWith<$Res>  {
  factory $StoreInputFormStateCopyWith(StoreInputFormState value, $Res Function(StoreInputFormState) _then) = _$StoreInputFormStateCopyWithImpl;
@useResult
$Res call({
 String name, String address, String memo, StoreColor color, PriceSetting priceSettings
});


$PriceSettingCopyWith<$Res> get priceSettings;

}
/// @nodoc
class _$StoreInputFormStateCopyWithImpl<$Res>
    implements $StoreInputFormStateCopyWith<$Res> {
  _$StoreInputFormStateCopyWithImpl(this._self, this._then);

  final StoreInputFormState _self;
  final $Res Function(StoreInputFormState) _then;

/// Create a copy of StoreInputFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? address = null,Object? memo = null,Object? color = null,Object? priceSettings = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,memo: null == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as StoreColor,priceSettings: null == priceSettings ? _self.priceSettings : priceSettings // ignore: cast_nullable_to_non_nullable
as PriceSetting,
  ));
}
/// Create a copy of StoreInputFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceSettingCopyWith<$Res> get priceSettings {
  
  return $PriceSettingCopyWith<$Res>(_self.priceSettings, (value) {
    return _then(_self.copyWith(priceSettings: value));
  });
}
}


/// Adds pattern-matching-related methods to [StoreInputFormState].
extension StoreInputFormStatePatterns on StoreInputFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoreInputFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoreInputFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoreInputFormState value)  $default,){
final _that = this;
switch (_that) {
case _StoreInputFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoreInputFormState value)?  $default,){
final _that = this;
switch (_that) {
case _StoreInputFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String address,  String memo,  StoreColor color,  PriceSetting priceSettings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoreInputFormState() when $default != null:
return $default(_that.name,_that.address,_that.memo,_that.color,_that.priceSettings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String address,  String memo,  StoreColor color,  PriceSetting priceSettings)  $default,) {final _that = this;
switch (_that) {
case _StoreInputFormState():
return $default(_that.name,_that.address,_that.memo,_that.color,_that.priceSettings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String address,  String memo,  StoreColor color,  PriceSetting priceSettings)?  $default,) {final _that = this;
switch (_that) {
case _StoreInputFormState() when $default != null:
return $default(_that.name,_that.address,_that.memo,_that.color,_that.priceSettings);case _:
  return null;

}
}

}

/// @nodoc


class _StoreInputFormState extends StoreInputFormState {
  const _StoreInputFormState({this.name = '', this.address = '', this.memo = '', this.color = StoreColor.red, required this.priceSettings}): super._();
  

@override@JsonKey() final  String name;
@override@JsonKey() final  String address;
@override@JsonKey() final  String memo;
@override@JsonKey() final  StoreColor color;
// 기본 색상
// 복잡한 객체는 nullable로 두거나, 기본값을 상수로 정의해서 넣어줌
@override final  PriceSetting priceSettings;

/// Create a copy of StoreInputFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoreInputFormStateCopyWith<_StoreInputFormState> get copyWith => __$StoreInputFormStateCopyWithImpl<_StoreInputFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoreInputFormState&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.color, color) || other.color == color)&&(identical(other.priceSettings, priceSettings) || other.priceSettings == priceSettings));
}


@override
int get hashCode => Object.hash(runtimeType,name,address,memo,color,priceSettings);

@override
String toString() {
  return 'StoreInputFormState(name: $name, address: $address, memo: $memo, color: $color, priceSettings: $priceSettings)';
}


}

/// @nodoc
abstract mixin class _$StoreInputFormStateCopyWith<$Res> implements $StoreInputFormStateCopyWith<$Res> {
  factory _$StoreInputFormStateCopyWith(_StoreInputFormState value, $Res Function(_StoreInputFormState) _then) = __$StoreInputFormStateCopyWithImpl;
@override @useResult
$Res call({
 String name, String address, String memo, StoreColor color, PriceSetting priceSettings
});


@override $PriceSettingCopyWith<$Res> get priceSettings;

}
/// @nodoc
class __$StoreInputFormStateCopyWithImpl<$Res>
    implements _$StoreInputFormStateCopyWith<$Res> {
  __$StoreInputFormStateCopyWithImpl(this._self, this._then);

  final _StoreInputFormState _self;
  final $Res Function(_StoreInputFormState) _then;

/// Create a copy of StoreInputFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? address = null,Object? memo = null,Object? color = null,Object? priceSettings = null,}) {
  return _then(_StoreInputFormState(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,memo: null == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as StoreColor,priceSettings: null == priceSettings ? _self.priceSettings : priceSettings // ignore: cast_nullable_to_non_nullable
as PriceSetting,
  ));
}

/// Create a copy of StoreInputFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceSettingCopyWith<$Res> get priceSettings {
  
  return $PriceSettingCopyWith<$Res>(_self.priceSettings, (value) {
    return _then(_self.copyWith(priceSettings: value));
  });
}
}

// dart format on
