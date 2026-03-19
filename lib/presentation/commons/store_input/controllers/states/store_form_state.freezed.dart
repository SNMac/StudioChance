// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StoreFormState {

 String get name; String get address; String get addressDetail; String get addressGuide; String get memo; StoreColor get color; PriceSetting get priceSettings; AsyncValue<void> get status;
/// Create a copy of StoreFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoreFormStateCopyWith<StoreFormState> get copyWith => _$StoreFormStateCopyWithImpl<StoreFormState>(this as StoreFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoreFormState&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.addressDetail, addressDetail) || other.addressDetail == addressDetail)&&(identical(other.addressGuide, addressGuide) || other.addressGuide == addressGuide)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.color, color) || other.color == color)&&(identical(other.priceSettings, priceSettings) || other.priceSettings == priceSettings)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,name,address,addressDetail,addressGuide,memo,color,priceSettings,status);

@override
String toString() {
  return 'StoreFormState(name: $name, address: $address, addressDetail: $addressDetail, addressGuide: $addressGuide, memo: $memo, color: $color, priceSettings: $priceSettings, status: $status)';
}


}

/// @nodoc
abstract mixin class $StoreFormStateCopyWith<$Res>  {
  factory $StoreFormStateCopyWith(StoreFormState value, $Res Function(StoreFormState) _then) = _$StoreFormStateCopyWithImpl;
@useResult
$Res call({
 String name, String address, String addressDetail, String addressGuide, String memo, StoreColor color, PriceSetting priceSettings, AsyncValue<void> status
});


$PriceSettingCopyWith<$Res> get priceSettings;

}
/// @nodoc
class _$StoreFormStateCopyWithImpl<$Res>
    implements $StoreFormStateCopyWith<$Res> {
  _$StoreFormStateCopyWithImpl(this._self, this._then);

  final StoreFormState _self;
  final $Res Function(StoreFormState) _then;

/// Create a copy of StoreFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? address = null,Object? addressDetail = null,Object? addressGuide = null,Object? memo = null,Object? color = null,Object? priceSettings = null,Object? status = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,addressDetail: null == addressDetail ? _self.addressDetail : addressDetail // ignore: cast_nullable_to_non_nullable
as String,addressGuide: null == addressGuide ? _self.addressGuide : addressGuide // ignore: cast_nullable_to_non_nullable
as String,memo: null == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as StoreColor,priceSettings: null == priceSettings ? _self.priceSettings : priceSettings // ignore: cast_nullable_to_non_nullable
as PriceSetting,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AsyncValue<void>,
  ));
}
/// Create a copy of StoreFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceSettingCopyWith<$Res> get priceSettings {
  
  return $PriceSettingCopyWith<$Res>(_self.priceSettings, (value) {
    return _then(_self.copyWith(priceSettings: value));
  });
}
}


/// Adds pattern-matching-related methods to [StoreFormState].
extension StoreFormStatePatterns on StoreFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoreFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoreFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoreFormState value)  $default,){
final _that = this;
switch (_that) {
case _StoreFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoreFormState value)?  $default,){
final _that = this;
switch (_that) {
case _StoreFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String address,  String addressDetail,  String addressGuide,  String memo,  StoreColor color,  PriceSetting priceSettings,  AsyncValue<void> status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoreFormState() when $default != null:
return $default(_that.name,_that.address,_that.addressDetail,_that.addressGuide,_that.memo,_that.color,_that.priceSettings,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String address,  String addressDetail,  String addressGuide,  String memo,  StoreColor color,  PriceSetting priceSettings,  AsyncValue<void> status)  $default,) {final _that = this;
switch (_that) {
case _StoreFormState():
return $default(_that.name,_that.address,_that.addressDetail,_that.addressGuide,_that.memo,_that.color,_that.priceSettings,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String address,  String addressDetail,  String addressGuide,  String memo,  StoreColor color,  PriceSetting priceSettings,  AsyncValue<void> status)?  $default,) {final _that = this;
switch (_that) {
case _StoreFormState() when $default != null:
return $default(_that.name,_that.address,_that.addressDetail,_that.addressGuide,_that.memo,_that.color,_that.priceSettings,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _StoreFormState extends StoreFormState {
  const _StoreFormState({this.name = '', this.address = '', this.addressDetail = '', this.addressGuide = '', this.memo = '', this.color = StoreColor.red, required this.priceSettings, this.status = const AsyncData(null)}): super._();
  

@override@JsonKey() final  String name;
@override@JsonKey() final  String address;
@override@JsonKey() final  String addressDetail;
@override@JsonKey() final  String addressGuide;
@override@JsonKey() final  String memo;
@override@JsonKey() final  StoreColor color;
@override final  PriceSetting priceSettings;
@override@JsonKey() final  AsyncValue<void> status;

/// Create a copy of StoreFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoreFormStateCopyWith<_StoreFormState> get copyWith => __$StoreFormStateCopyWithImpl<_StoreFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoreFormState&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.addressDetail, addressDetail) || other.addressDetail == addressDetail)&&(identical(other.addressGuide, addressGuide) || other.addressGuide == addressGuide)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.color, color) || other.color == color)&&(identical(other.priceSettings, priceSettings) || other.priceSettings == priceSettings)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,name,address,addressDetail,addressGuide,memo,color,priceSettings,status);

@override
String toString() {
  return 'StoreFormState(name: $name, address: $address, addressDetail: $addressDetail, addressGuide: $addressGuide, memo: $memo, color: $color, priceSettings: $priceSettings, status: $status)';
}


}

/// @nodoc
abstract mixin class _$StoreFormStateCopyWith<$Res> implements $StoreFormStateCopyWith<$Res> {
  factory _$StoreFormStateCopyWith(_StoreFormState value, $Res Function(_StoreFormState) _then) = __$StoreFormStateCopyWithImpl;
@override @useResult
$Res call({
 String name, String address, String addressDetail, String addressGuide, String memo, StoreColor color, PriceSetting priceSettings, AsyncValue<void> status
});


@override $PriceSettingCopyWith<$Res> get priceSettings;

}
/// @nodoc
class __$StoreFormStateCopyWithImpl<$Res>
    implements _$StoreFormStateCopyWith<$Res> {
  __$StoreFormStateCopyWithImpl(this._self, this._then);

  final _StoreFormState _self;
  final $Res Function(_StoreFormState) _then;

/// Create a copy of StoreFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? address = null,Object? addressDetail = null,Object? addressGuide = null,Object? memo = null,Object? color = null,Object? priceSettings = null,Object? status = null,}) {
  return _then(_StoreFormState(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,addressDetail: null == addressDetail ? _self.addressDetail : addressDetail // ignore: cast_nullable_to_non_nullable
as String,addressGuide: null == addressGuide ? _self.addressGuide : addressGuide // ignore: cast_nullable_to_non_nullable
as String,memo: null == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as StoreColor,priceSettings: null == priceSettings ? _self.priceSettings : priceSettings // ignore: cast_nullable_to_non_nullable
as PriceSetting,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AsyncValue<void>,
  ));
}

/// Create a copy of StoreFormState
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
