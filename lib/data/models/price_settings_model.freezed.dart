// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'price_settings_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PriceSettingsModel {

 List<DayGroupModel> get dayGroupModels;
/// Create a copy of PriceSettingsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PriceSettingsModelCopyWith<PriceSettingsModel> get copyWith => _$PriceSettingsModelCopyWithImpl<PriceSettingsModel>(this as PriceSettingsModel, _$identity);

  /// Serializes this PriceSettingsModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PriceSettingsModel&&const DeepCollectionEquality().equals(other.dayGroupModels, dayGroupModels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(dayGroupModels));

@override
String toString() {
  return 'PriceSettingsModel(dayGroupModels: $dayGroupModels)';
}


}

/// @nodoc
abstract mixin class $PriceSettingsModelCopyWith<$Res>  {
  factory $PriceSettingsModelCopyWith(PriceSettingsModel value, $Res Function(PriceSettingsModel) _then) = _$PriceSettingsModelCopyWithImpl;
@useResult
$Res call({
 List<DayGroupModel> dayGroupModels
});




}
/// @nodoc
class _$PriceSettingsModelCopyWithImpl<$Res>
    implements $PriceSettingsModelCopyWith<$Res> {
  _$PriceSettingsModelCopyWithImpl(this._self, this._then);

  final PriceSettingsModel _self;
  final $Res Function(PriceSettingsModel) _then;

/// Create a copy of PriceSettingsModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dayGroupModels = null,}) {
  return _then(_self.copyWith(
dayGroupModels: null == dayGroupModels ? _self.dayGroupModels : dayGroupModels // ignore: cast_nullable_to_non_nullable
as List<DayGroupModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [PriceSettingsModel].
extension PriceSettingsModelPatterns on PriceSettingsModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PriceSettingsModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PriceSettingsModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PriceSettingsModel value)  $default,){
final _that = this;
switch (_that) {
case _PriceSettingsModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PriceSettingsModel value)?  $default,){
final _that = this;
switch (_that) {
case _PriceSettingsModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DayGroupModel> dayGroupModels)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PriceSettingsModel() when $default != null:
return $default(_that.dayGroupModels);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DayGroupModel> dayGroupModels)  $default,) {final _that = this;
switch (_that) {
case _PriceSettingsModel():
return $default(_that.dayGroupModels);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DayGroupModel> dayGroupModels)?  $default,) {final _that = this;
switch (_that) {
case _PriceSettingsModel() when $default != null:
return $default(_that.dayGroupModels);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PriceSettingsModel implements PriceSettingsModel {
  const _PriceSettingsModel({final  List<DayGroupModel> dayGroupModels = const []}): _dayGroupModels = dayGroupModels;
  factory _PriceSettingsModel.fromJson(Map<String, dynamic> json) => _$PriceSettingsModelFromJson(json);

 final  List<DayGroupModel> _dayGroupModels;
@override@JsonKey() List<DayGroupModel> get dayGroupModels {
  if (_dayGroupModels is EqualUnmodifiableListView) return _dayGroupModels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dayGroupModels);
}


/// Create a copy of PriceSettingsModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PriceSettingsModelCopyWith<_PriceSettingsModel> get copyWith => __$PriceSettingsModelCopyWithImpl<_PriceSettingsModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PriceSettingsModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PriceSettingsModel&&const DeepCollectionEquality().equals(other._dayGroupModels, _dayGroupModels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_dayGroupModels));

@override
String toString() {
  return 'PriceSettingsModel(dayGroupModels: $dayGroupModels)';
}


}

/// @nodoc
abstract mixin class _$PriceSettingsModelCopyWith<$Res> implements $PriceSettingsModelCopyWith<$Res> {
  factory _$PriceSettingsModelCopyWith(_PriceSettingsModel value, $Res Function(_PriceSettingsModel) _then) = __$PriceSettingsModelCopyWithImpl;
@override @useResult
$Res call({
 List<DayGroupModel> dayGroupModels
});




}
/// @nodoc
class __$PriceSettingsModelCopyWithImpl<$Res>
    implements _$PriceSettingsModelCopyWith<$Res> {
  __$PriceSettingsModelCopyWithImpl(this._self, this._then);

  final _PriceSettingsModel _self;
  final $Res Function(_PriceSettingsModel) _then;

/// Create a copy of PriceSettingsModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dayGroupModels = null,}) {
  return _then(_PriceSettingsModel(
dayGroupModels: null == dayGroupModels ? _self._dayGroupModels : dayGroupModels // ignore: cast_nullable_to_non_nullable
as List<DayGroupModel>,
  ));
}


}

// dart format on
