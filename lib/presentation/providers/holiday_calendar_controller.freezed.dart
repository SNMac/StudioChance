// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'holiday_calendar_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HolidayCalendarState {

 HolidayCalendar get calendar;/// 조회를 마친 연도 (성공·실패·문서 없음 모두 포함). 불러오는 중인 연도는 없다.
 Set<int> get settledYears;
/// Create a copy of HolidayCalendarState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HolidayCalendarStateCopyWith<HolidayCalendarState> get copyWith => _$HolidayCalendarStateCopyWithImpl<HolidayCalendarState>(this as HolidayCalendarState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HolidayCalendarState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HolidayCalendarState&&(identical(other.calendar, _this.calendar) || other.calendar == _this.calendar)&&const DeepCollectionEquality().equals(other.settledYears, _this.settledYears));
}


@override
int get hashCode {
  final _this = this as HolidayCalendarState;
  return Object.hash(runtimeType,_this.calendar,const DeepCollectionEquality().hash(_this.settledYears));
}

@override
String toString() {
  final _this = this as HolidayCalendarState;
  return 'HolidayCalendarState(calendar: ${_this.calendar}, settledYears: ${_this.settledYears})';
}


}

/// @nodoc
abstract mixin class $HolidayCalendarStateCopyWith<$Res>  {
  factory $HolidayCalendarStateCopyWith(HolidayCalendarState value, $Res Function(HolidayCalendarState) _then) = _$HolidayCalendarStateCopyWithImpl;
@useResult
$Res call({
 HolidayCalendar calendar, Set<int> settledYears
});


$HolidayCalendarCopyWith<$Res> get calendar;

}
/// @nodoc
class _$HolidayCalendarStateCopyWithImpl<$Res>
    implements $HolidayCalendarStateCopyWith<$Res> {
  _$HolidayCalendarStateCopyWithImpl(this._self, this._then);

  final HolidayCalendarState _self;
  final $Res Function(HolidayCalendarState) _then;

/// Create a copy of HolidayCalendarState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? calendar = null,Object? settledYears = null,}) {
  return _then(HolidayCalendarState(
calendar: null == calendar ? _self.calendar : calendar // ignore: cast_nullable_to_non_nullable
as HolidayCalendar,settledYears: null == settledYears ? _self.settledYears : settledYears // ignore: cast_nullable_to_non_nullable
as Set<int>,
  ));
}
/// Create a copy of HolidayCalendarState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HolidayCalendarCopyWith<$Res> get calendar {
  
  return $HolidayCalendarCopyWith<$Res>(_self.calendar, (value) {
    return _then(_self.copyWith(calendar: value));
  });
}
}


/// Adds pattern-matching-related methods to [HolidayCalendarState].
extension HolidayCalendarStatePatterns on HolidayCalendarState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HolidayCalendarState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HolidayCalendarState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HolidayCalendarState value)  $default,){
final _that = this;
switch (_that) {
case _HolidayCalendarState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HolidayCalendarState value)?  $default,){
final _that = this;
switch (_that) {
case _HolidayCalendarState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HolidayCalendar calendar,  Set<int> settledYears)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HolidayCalendarState() when $default != null:
return $default(_that.calendar,_that.settledYears);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HolidayCalendar calendar,  Set<int> settledYears)  $default,) {final _that = this;
switch (_that) {
case _HolidayCalendarState():
return $default(_that.calendar,_that.settledYears);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HolidayCalendar calendar,  Set<int> settledYears)?  $default,) {final _that = this;
switch (_that) {
case _HolidayCalendarState() when $default != null:
return $default(_that.calendar,_that.settledYears);case _:
  return null;

}
}

}

/// @nodoc


class _HolidayCalendarState extends HolidayCalendarState {
  const _HolidayCalendarState({this.calendar = const HolidayCalendar(),  Set<int> settledYears = const {}}): _settledYears = settledYears,super._();
  

@override@JsonKey() final  HolidayCalendar calendar;
/// 조회를 마친 연도 (성공·실패·문서 없음 모두 포함). 불러오는 중인 연도는 없다.
 final  Set<int> _settledYears;
/// 조회를 마친 연도 (성공·실패·문서 없음 모두 포함). 불러오는 중인 연도는 없다.
@override@JsonKey() Set<int> get settledYears {
  if (_settledYears is EqualUnmodifiableSetView) return _settledYears;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_settledYears);
}


/// Create a copy of HolidayCalendarState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HolidayCalendarStateCopyWith<_HolidayCalendarState> get copyWith => __$HolidayCalendarStateCopyWithImpl<_HolidayCalendarState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HolidayCalendarState&&(identical(other.calendar, calendar) || other.calendar == calendar)&&const DeepCollectionEquality().equals(other.settledYears, _settledYears));
}


@override
int get hashCode {
    return Object.hash(runtimeType,calendar,const DeepCollectionEquality().hash(_settledYears));
}

@override
String toString() {
    return 'HolidayCalendarState(calendar: $calendar, settledYears: $settledYears)';
}


}

/// @nodoc
abstract mixin class _$HolidayCalendarStateCopyWith<$Res> implements $HolidayCalendarStateCopyWith<$Res> {
  factory _$HolidayCalendarStateCopyWith(_HolidayCalendarState value, $Res Function(_HolidayCalendarState) _then) = __$HolidayCalendarStateCopyWithImpl;
@override @useResult
$Res call({
 HolidayCalendar calendar, Set<int> settledYears
});


@override $HolidayCalendarCopyWith<$Res> get calendar;

}
/// @nodoc
class __$HolidayCalendarStateCopyWithImpl<$Res>
    implements _$HolidayCalendarStateCopyWith<$Res> {
  __$HolidayCalendarStateCopyWithImpl(this._self, this._then);

  final _HolidayCalendarState _self;
  final $Res Function(_HolidayCalendarState) _then;

/// Create a copy of HolidayCalendarState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? calendar = null,Object? settledYears = null,}) {
  return _then(_HolidayCalendarState(
calendar: null == calendar ? _self.calendar : calendar // ignore: cast_nullable_to_non_nullable
as HolidayCalendar,settledYears: null == settledYears ? _self._settledYears : settledYears // ignore: cast_nullable_to_non_nullable
as Set<int>,
  ));
}

/// Create a copy of HolidayCalendarState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HolidayCalendarCopyWith<$Res> get calendar {
  
  return $HolidayCalendarCopyWith<$Res>(_self.calendar, (value) {
    return _then(_self.copyWith(calendar: value));
  });
}
}

// dart format on
