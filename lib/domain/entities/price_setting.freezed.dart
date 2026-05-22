// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'price_setting.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PriceSetting {

 List<DayGroup> get dayGroups;
/// Create a copy of PriceSetting
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PriceSettingCopyWith<PriceSetting> get copyWith => _$PriceSettingCopyWithImpl<PriceSetting>(this as PriceSetting, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PriceSetting&&const DeepCollectionEquality().equals(other.dayGroups, dayGroups));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(dayGroups));

@override
String toString() {
  return 'PriceSetting(dayGroups: $dayGroups)';
}


}

/// @nodoc
abstract mixin class $PriceSettingCopyWith<$Res>  {
  factory $PriceSettingCopyWith(PriceSetting value, $Res Function(PriceSetting) _then) = _$PriceSettingCopyWithImpl;
@useResult
$Res call({
 List<DayGroup> dayGroups
});




}
/// @nodoc
class _$PriceSettingCopyWithImpl<$Res>
    implements $PriceSettingCopyWith<$Res> {
  _$PriceSettingCopyWithImpl(this._self, this._then);

  final PriceSetting _self;
  final $Res Function(PriceSetting) _then;

/// Create a copy of PriceSetting
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dayGroups = null,}) {
  return _then(_self.copyWith(
dayGroups: null == dayGroups ? _self.dayGroups : dayGroups // ignore: cast_nullable_to_non_nullable
as List<DayGroup>,
  ));
}

}


/// Adds pattern-matching-related methods to [PriceSetting].
extension PriceSettingPatterns on PriceSetting {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PriceSetting value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PriceSetting() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PriceSetting value)  $default,){
final _that = this;
switch (_that) {
case _PriceSetting():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PriceSetting value)?  $default,){
final _that = this;
switch (_that) {
case _PriceSetting() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DayGroup> dayGroups)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PriceSetting() when $default != null:
return $default(_that.dayGroups);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DayGroup> dayGroups)  $default,) {final _that = this;
switch (_that) {
case _PriceSetting():
return $default(_that.dayGroups);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DayGroup> dayGroups)?  $default,) {final _that = this;
switch (_that) {
case _PriceSetting() when $default != null:
return $default(_that.dayGroups);case _:
  return null;

}
}

}

/// @nodoc


class _PriceSetting extends PriceSetting {
  const _PriceSetting({required final  List<DayGroup> dayGroups}): _dayGroups = dayGroups,super._();
  

 final  List<DayGroup> _dayGroups;
@override List<DayGroup> get dayGroups {
  if (_dayGroups is EqualUnmodifiableListView) return _dayGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dayGroups);
}


/// Create a copy of PriceSetting
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PriceSettingCopyWith<_PriceSetting> get copyWith => __$PriceSettingCopyWithImpl<_PriceSetting>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PriceSetting&&const DeepCollectionEquality().equals(other._dayGroups, _dayGroups));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_dayGroups));

@override
String toString() {
  return 'PriceSetting(dayGroups: $dayGroups)';
}


}

/// @nodoc
abstract mixin class _$PriceSettingCopyWith<$Res> implements $PriceSettingCopyWith<$Res> {
  factory _$PriceSettingCopyWith(_PriceSetting value, $Res Function(_PriceSetting) _then) = __$PriceSettingCopyWithImpl;
@override @useResult
$Res call({
 List<DayGroup> dayGroups
});




}
/// @nodoc
class __$PriceSettingCopyWithImpl<$Res>
    implements _$PriceSettingCopyWith<$Res> {
  __$PriceSettingCopyWithImpl(this._self, this._then);

  final _PriceSetting _self;
  final $Res Function(_PriceSetting) _then;

/// Create a copy of PriceSetting
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dayGroups = null,}) {
  return _then(_PriceSetting(
dayGroups: null == dayGroups ? _self._dayGroups : dayGroups // ignore: cast_nullable_to_non_nullable
as List<DayGroup>,
  ));
}


}

// dart format on
