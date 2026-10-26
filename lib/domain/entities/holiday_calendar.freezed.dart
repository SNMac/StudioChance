// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'holiday_calendar.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HolidayCalendar {

 Map<int, Map<String, List<String>>> get daysByYear;
/// Create a copy of HolidayCalendar
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HolidayCalendarCopyWith<HolidayCalendar> get copyWith => _$HolidayCalendarCopyWithImpl<HolidayCalendar>(this as HolidayCalendar, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HolidayCalendar;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HolidayCalendar&&const DeepCollectionEquality().equals(other.daysByYear, _this.daysByYear));
}


@override
int get hashCode {
  final _this = this as HolidayCalendar;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.daysByYear));
}

@override
String toString() {
  final _this = this as HolidayCalendar;
  return 'HolidayCalendar(daysByYear: ${_this.daysByYear})';
}


}

/// @nodoc
abstract mixin class $HolidayCalendarCopyWith<$Res>  {
  factory $HolidayCalendarCopyWith(HolidayCalendar value, $Res Function(HolidayCalendar) _then) = _$HolidayCalendarCopyWithImpl;
@useResult
$Res call({
 Map<int, Map<String, List<String>>> daysByYear
});




}
/// @nodoc
class _$HolidayCalendarCopyWithImpl<$Res>
    implements $HolidayCalendarCopyWith<$Res> {
  _$HolidayCalendarCopyWithImpl(this._self, this._then);

  final HolidayCalendar _self;
  final $Res Function(HolidayCalendar) _then;

/// Create a copy of HolidayCalendar
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? daysByYear = null,}) {
  return _then(HolidayCalendar(
daysByYear: null == daysByYear ? _self.daysByYear : daysByYear // ignore: cast_nullable_to_non_nullable
as Map<int, Map<String, List<String>>>,
  ));
}

}


/// Adds pattern-matching-related methods to [HolidayCalendar].
extension HolidayCalendarPatterns on HolidayCalendar {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HolidayCalendar value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HolidayCalendar() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HolidayCalendar value)  $default,){
final _that = this;
switch (_that) {
case _HolidayCalendar():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HolidayCalendar value)?  $default,){
final _that = this;
switch (_that) {
case _HolidayCalendar() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<int, Map<String, List<String>>> daysByYear)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HolidayCalendar() when $default != null:
return $default(_that.daysByYear);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<int, Map<String, List<String>>> daysByYear)  $default,) {final _that = this;
switch (_that) {
case _HolidayCalendar():
return $default(_that.daysByYear);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<int, Map<String, List<String>>> daysByYear)?  $default,) {final _that = this;
switch (_that) {
case _HolidayCalendar() when $default != null:
return $default(_that.daysByYear);case _:
  return null;

}
}

}

/// @nodoc


class _HolidayCalendar extends HolidayCalendar {
  const _HolidayCalendar({ Map<int, Map<String, List<String>>> daysByYear = const {}}): _daysByYear = daysByYear,super._();
  

 final  Map<int, Map<String, List<String>>> _daysByYear;
@override@JsonKey() Map<int, Map<String, List<String>>> get daysByYear {
  if (_daysByYear is EqualUnmodifiableMapView) return _daysByYear;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_daysByYear);
}


/// Create a copy of HolidayCalendar
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HolidayCalendarCopyWith<_HolidayCalendar> get copyWith => __$HolidayCalendarCopyWithImpl<_HolidayCalendar>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HolidayCalendar&&const DeepCollectionEquality().equals(other.daysByYear, _daysByYear));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_daysByYear));
}

@override
String toString() {
    return 'HolidayCalendar(daysByYear: $daysByYear)';
}


}

/// @nodoc
abstract mixin class _$HolidayCalendarCopyWith<$Res> implements $HolidayCalendarCopyWith<$Res> {
  factory _$HolidayCalendarCopyWith(_HolidayCalendar value, $Res Function(_HolidayCalendar) _then) = __$HolidayCalendarCopyWithImpl;
@override @useResult
$Res call({
 Map<int, Map<String, List<String>>> daysByYear
});




}
/// @nodoc
class __$HolidayCalendarCopyWithImpl<$Res>
    implements _$HolidayCalendarCopyWith<$Res> {
  __$HolidayCalendarCopyWithImpl(this._self, this._then);

  final _HolidayCalendar _self;
  final $Res Function(_HolidayCalendar) _then;

/// Create a copy of HolidayCalendar
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? daysByYear = null,}) {
  return _then(_HolidayCalendar(
daysByYear: null == daysByYear ? _self._daysByYear : daysByYear // ignore: cast_nullable_to_non_nullable
as Map<int, Map<String, List<String>>>,
  ));
}


}

// dart format on
