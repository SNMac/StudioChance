// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'holiday_year_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HolidayYearModel {

/// 날짜 키(`yyyy-MM-dd`) → 그날의 공휴일 이름들 (같은 날 공휴일이 겹칠 수 있다)
 Map<String, List<String>> get days;
/// Create a copy of HolidayYearModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HolidayYearModelCopyWith<HolidayYearModel> get copyWith => _$HolidayYearModelCopyWithImpl<HolidayYearModel>(this as HolidayYearModel, _$identity);

  /// Serializes this HolidayYearModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HolidayYearModel&&const DeepCollectionEquality().equals(other.days, days));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(days));

@override
String toString() {
  return 'HolidayYearModel(days: $days)';
}


}

/// @nodoc
abstract mixin class $HolidayYearModelCopyWith<$Res>  {
  factory $HolidayYearModelCopyWith(HolidayYearModel value, $Res Function(HolidayYearModel) _then) = _$HolidayYearModelCopyWithImpl;
@useResult
$Res call({
 Map<String, List<String>> days
});




}
/// @nodoc
class _$HolidayYearModelCopyWithImpl<$Res>
    implements $HolidayYearModelCopyWith<$Res> {
  _$HolidayYearModelCopyWithImpl(this._self, this._then);

  final HolidayYearModel _self;
  final $Res Function(HolidayYearModel) _then;

/// Create a copy of HolidayYearModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? days = null,}) {
  return _then(_self.copyWith(
days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,
  ));
}

}


/// Adds pattern-matching-related methods to [HolidayYearModel].
extension HolidayYearModelPatterns on HolidayYearModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HolidayYearModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HolidayYearModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HolidayYearModel value)  $default,){
final _that = this;
switch (_that) {
case _HolidayYearModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HolidayYearModel value)?  $default,){
final _that = this;
switch (_that) {
case _HolidayYearModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, List<String>> days)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HolidayYearModel() when $default != null:
return $default(_that.days);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, List<String>> days)  $default,) {final _that = this;
switch (_that) {
case _HolidayYearModel():
return $default(_that.days);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, List<String>> days)?  $default,) {final _that = this;
switch (_that) {
case _HolidayYearModel() when $default != null:
return $default(_that.days);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HolidayYearModel implements HolidayYearModel {
  const _HolidayYearModel({required final  Map<String, List<String>> days}): _days = days;
  factory _HolidayYearModel.fromJson(Map<String, dynamic> json) => _$HolidayYearModelFromJson(json);

/// 날짜 키(`yyyy-MM-dd`) → 그날의 공휴일 이름들 (같은 날 공휴일이 겹칠 수 있다)
 final  Map<String, List<String>> _days;
/// 날짜 키(`yyyy-MM-dd`) → 그날의 공휴일 이름들 (같은 날 공휴일이 겹칠 수 있다)
@override Map<String, List<String>> get days {
  if (_days is EqualUnmodifiableMapView) return _days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_days);
}


/// Create a copy of HolidayYearModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HolidayYearModelCopyWith<_HolidayYearModel> get copyWith => __$HolidayYearModelCopyWithImpl<_HolidayYearModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HolidayYearModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HolidayYearModel&&const DeepCollectionEquality().equals(other._days, _days));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_days));

@override
String toString() {
  return 'HolidayYearModel(days: $days)';
}


}

/// @nodoc
abstract mixin class _$HolidayYearModelCopyWith<$Res> implements $HolidayYearModelCopyWith<$Res> {
  factory _$HolidayYearModelCopyWith(_HolidayYearModel value, $Res Function(_HolidayYearModel) _then) = __$HolidayYearModelCopyWithImpl;
@override @useResult
$Res call({
 Map<String, List<String>> days
});




}
/// @nodoc
class __$HolidayYearModelCopyWithImpl<$Res>
    implements _$HolidayYearModelCopyWith<$Res> {
  __$HolidayYearModelCopyWithImpl(this._self, this._then);

  final _HolidayYearModel _self;
  final $Res Function(_HolidayYearModel) _then;

/// Create a copy of HolidayYearModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? days = null,}) {
  return _then(_HolidayYearModel(
days: null == days ? _self._days : days // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,
  ));
}


}

// dart format on
