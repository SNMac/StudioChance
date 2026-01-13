// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store_creation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StoreCreationState {

 String get name; String get address; String get memo; StoreColor? get selectedColor; PriceSetting? get priceSetting;
/// Create a copy of StoreCreationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoreCreationStateCopyWith<StoreCreationState> get copyWith => _$StoreCreationStateCopyWithImpl<StoreCreationState>(this as StoreCreationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoreCreationState&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.selectedColor, selectedColor) || other.selectedColor == selectedColor)&&(identical(other.priceSetting, priceSetting) || other.priceSetting == priceSetting));
}


@override
int get hashCode => Object.hash(runtimeType,name,address,memo,selectedColor,priceSetting);

@override
String toString() {
  return 'StoreCreationState(name: $name, address: $address, memo: $memo, selectedColor: $selectedColor, priceSetting: $priceSetting)';
}


}

/// @nodoc
abstract mixin class $StoreCreationStateCopyWith<$Res>  {
  factory $StoreCreationStateCopyWith(StoreCreationState value, $Res Function(StoreCreationState) _then) = _$StoreCreationStateCopyWithImpl;
@useResult
$Res call({
 String name, String address, String memo, StoreColor? selectedColor, PriceSetting? priceSetting
});


$PriceSettingCopyWith<$Res>? get priceSetting;

}
/// @nodoc
class _$StoreCreationStateCopyWithImpl<$Res>
    implements $StoreCreationStateCopyWith<$Res> {
  _$StoreCreationStateCopyWithImpl(this._self, this._then);

  final StoreCreationState _self;
  final $Res Function(StoreCreationState) _then;

/// Create a copy of StoreCreationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? address = null,Object? memo = null,Object? selectedColor = freezed,Object? priceSetting = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,memo: null == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String,selectedColor: freezed == selectedColor ? _self.selectedColor : selectedColor // ignore: cast_nullable_to_non_nullable
as StoreColor?,priceSetting: freezed == priceSetting ? _self.priceSetting : priceSetting // ignore: cast_nullable_to_non_nullable
as PriceSetting?,
  ));
}
/// Create a copy of StoreCreationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceSettingCopyWith<$Res>? get priceSetting {
    if (_self.priceSetting == null) {
    return null;
  }

  return $PriceSettingCopyWith<$Res>(_self.priceSetting!, (value) {
    return _then(_self.copyWith(priceSetting: value));
  });
}
}


/// Adds pattern-matching-related methods to [StoreCreationState].
extension StoreCreationStatePatterns on StoreCreationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoreCreationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoreCreationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoreCreationState value)  $default,){
final _that = this;
switch (_that) {
case _StoreCreationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoreCreationState value)?  $default,){
final _that = this;
switch (_that) {
case _StoreCreationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String address,  String memo,  StoreColor? selectedColor,  PriceSetting? priceSetting)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoreCreationState() when $default != null:
return $default(_that.name,_that.address,_that.memo,_that.selectedColor,_that.priceSetting);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String address,  String memo,  StoreColor? selectedColor,  PriceSetting? priceSetting)  $default,) {final _that = this;
switch (_that) {
case _StoreCreationState():
return $default(_that.name,_that.address,_that.memo,_that.selectedColor,_that.priceSetting);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String address,  String memo,  StoreColor? selectedColor,  PriceSetting? priceSetting)?  $default,) {final _that = this;
switch (_that) {
case _StoreCreationState() when $default != null:
return $default(_that.name,_that.address,_that.memo,_that.selectedColor,_that.priceSetting);case _:
  return null;

}
}

}

/// @nodoc


class _StoreCreationState extends StoreCreationState {
  const _StoreCreationState({this.name = '', this.address = '', this.memo = '', this.selectedColor, this.priceSetting}): super._();
  

@override@JsonKey() final  String name;
@override@JsonKey() final  String address;
@override@JsonKey() final  String memo;
@override final  StoreColor? selectedColor;
@override final  PriceSetting? priceSetting;

/// Create a copy of StoreCreationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoreCreationStateCopyWith<_StoreCreationState> get copyWith => __$StoreCreationStateCopyWithImpl<_StoreCreationState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoreCreationState&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.selectedColor, selectedColor) || other.selectedColor == selectedColor)&&(identical(other.priceSetting, priceSetting) || other.priceSetting == priceSetting));
}


@override
int get hashCode => Object.hash(runtimeType,name,address,memo,selectedColor,priceSetting);

@override
String toString() {
  return 'StoreCreationState(name: $name, address: $address, memo: $memo, selectedColor: $selectedColor, priceSetting: $priceSetting)';
}


}

/// @nodoc
abstract mixin class _$StoreCreationStateCopyWith<$Res> implements $StoreCreationStateCopyWith<$Res> {
  factory _$StoreCreationStateCopyWith(_StoreCreationState value, $Res Function(_StoreCreationState) _then) = __$StoreCreationStateCopyWithImpl;
@override @useResult
$Res call({
 String name, String address, String memo, StoreColor? selectedColor, PriceSetting? priceSetting
});


@override $PriceSettingCopyWith<$Res>? get priceSetting;

}
/// @nodoc
class __$StoreCreationStateCopyWithImpl<$Res>
    implements _$StoreCreationStateCopyWith<$Res> {
  __$StoreCreationStateCopyWithImpl(this._self, this._then);

  final _StoreCreationState _self;
  final $Res Function(_StoreCreationState) _then;

/// Create a copy of StoreCreationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? address = null,Object? memo = null,Object? selectedColor = freezed,Object? priceSetting = freezed,}) {
  return _then(_StoreCreationState(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,memo: null == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String,selectedColor: freezed == selectedColor ? _self.selectedColor : selectedColor // ignore: cast_nullable_to_non_nullable
as StoreColor?,priceSetting: freezed == priceSetting ? _self.priceSetting : priceSetting // ignore: cast_nullable_to_non_nullable
as PriceSetting?,
  ));
}

/// Create a copy of StoreCreationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceSettingCopyWith<$Res>? get priceSetting {
    if (_self.priceSetting == null) {
    return null;
  }

  return $PriceSettingCopyWith<$Res>(_self.priceSetting!, (value) {
    return _then(_self.copyWith(priceSetting: value));
  });
}
}

// dart format on
