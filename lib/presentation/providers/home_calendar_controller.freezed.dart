// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_calendar_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeCalendarState {

/// 3일 캘린더의 첫 번째 날짜
 DateTime get selectedStartDate;/// 월간 캘린더 표시 여부
 bool get isMonthlyCalendarVisible;/// 시간 행 높이 (확대/축소 기준값)
 double get hourHeight;/// 네비게이션 바에 표시되는 연월 (day=1 고정)
 DateTime get displayedMonth;
/// Create a copy of HomeCalendarState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeCalendarStateCopyWith<HomeCalendarState> get copyWith => _$HomeCalendarStateCopyWithImpl<HomeCalendarState>(this as HomeCalendarState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeCalendarState&&(identical(other.selectedStartDate, selectedStartDate) || other.selectedStartDate == selectedStartDate)&&(identical(other.isMonthlyCalendarVisible, isMonthlyCalendarVisible) || other.isMonthlyCalendarVisible == isMonthlyCalendarVisible)&&(identical(other.hourHeight, hourHeight) || other.hourHeight == hourHeight)&&(identical(other.displayedMonth, displayedMonth) || other.displayedMonth == displayedMonth));
}


@override
int get hashCode => Object.hash(runtimeType,selectedStartDate,isMonthlyCalendarVisible,hourHeight,displayedMonth);

@override
String toString() {
  return 'HomeCalendarState(selectedStartDate: $selectedStartDate, isMonthlyCalendarVisible: $isMonthlyCalendarVisible, hourHeight: $hourHeight, displayedMonth: $displayedMonth)';
}


}

/// @nodoc
abstract mixin class $HomeCalendarStateCopyWith<$Res>  {
  factory $HomeCalendarStateCopyWith(HomeCalendarState value, $Res Function(HomeCalendarState) _then) = _$HomeCalendarStateCopyWithImpl;
@useResult
$Res call({
 DateTime selectedStartDate, bool isMonthlyCalendarVisible, double hourHeight, DateTime displayedMonth
});




}
/// @nodoc
class _$HomeCalendarStateCopyWithImpl<$Res>
    implements $HomeCalendarStateCopyWith<$Res> {
  _$HomeCalendarStateCopyWithImpl(this._self, this._then);

  final HomeCalendarState _self;
  final $Res Function(HomeCalendarState) _then;

/// Create a copy of HomeCalendarState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedStartDate = null,Object? isMonthlyCalendarVisible = null,Object? hourHeight = null,Object? displayedMonth = null,}) {
  return _then(_self.copyWith(
selectedStartDate: null == selectedStartDate ? _self.selectedStartDate : selectedStartDate // ignore: cast_nullable_to_non_nullable
as DateTime,isMonthlyCalendarVisible: null == isMonthlyCalendarVisible ? _self.isMonthlyCalendarVisible : isMonthlyCalendarVisible // ignore: cast_nullable_to_non_nullable
as bool,hourHeight: null == hourHeight ? _self.hourHeight : hourHeight // ignore: cast_nullable_to_non_nullable
as double,displayedMonth: null == displayedMonth ? _self.displayedMonth : displayedMonth // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeCalendarState].
extension HomeCalendarStatePatterns on HomeCalendarState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeCalendarState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeCalendarState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeCalendarState value)  $default,){
final _that = this;
switch (_that) {
case _HomeCalendarState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeCalendarState value)?  $default,){
final _that = this;
switch (_that) {
case _HomeCalendarState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime selectedStartDate,  bool isMonthlyCalendarVisible,  double hourHeight,  DateTime displayedMonth)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeCalendarState() when $default != null:
return $default(_that.selectedStartDate,_that.isMonthlyCalendarVisible,_that.hourHeight,_that.displayedMonth);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime selectedStartDate,  bool isMonthlyCalendarVisible,  double hourHeight,  DateTime displayedMonth)  $default,) {final _that = this;
switch (_that) {
case _HomeCalendarState():
return $default(_that.selectedStartDate,_that.isMonthlyCalendarVisible,_that.hourHeight,_that.displayedMonth);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime selectedStartDate,  bool isMonthlyCalendarVisible,  double hourHeight,  DateTime displayedMonth)?  $default,) {final _that = this;
switch (_that) {
case _HomeCalendarState() when $default != null:
return $default(_that.selectedStartDate,_that.isMonthlyCalendarVisible,_that.hourHeight,_that.displayedMonth);case _:
  return null;

}
}

}

/// @nodoc


class _HomeCalendarState implements HomeCalendarState {
  const _HomeCalendarState({required this.selectedStartDate, required this.isMonthlyCalendarVisible, required this.hourHeight, required this.displayedMonth});
  

/// 3일 캘린더의 첫 번째 날짜
@override final  DateTime selectedStartDate;
/// 월간 캘린더 표시 여부
@override final  bool isMonthlyCalendarVisible;
/// 시간 행 높이 (확대/축소 기준값)
@override final  double hourHeight;
/// 네비게이션 바에 표시되는 연월 (day=1 고정)
@override final  DateTime displayedMonth;

/// Create a copy of HomeCalendarState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeCalendarStateCopyWith<_HomeCalendarState> get copyWith => __$HomeCalendarStateCopyWithImpl<_HomeCalendarState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeCalendarState&&(identical(other.selectedStartDate, selectedStartDate) || other.selectedStartDate == selectedStartDate)&&(identical(other.isMonthlyCalendarVisible, isMonthlyCalendarVisible) || other.isMonthlyCalendarVisible == isMonthlyCalendarVisible)&&(identical(other.hourHeight, hourHeight) || other.hourHeight == hourHeight)&&(identical(other.displayedMonth, displayedMonth) || other.displayedMonth == displayedMonth));
}


@override
int get hashCode => Object.hash(runtimeType,selectedStartDate,isMonthlyCalendarVisible,hourHeight,displayedMonth);

@override
String toString() {
  return 'HomeCalendarState(selectedStartDate: $selectedStartDate, isMonthlyCalendarVisible: $isMonthlyCalendarVisible, hourHeight: $hourHeight, displayedMonth: $displayedMonth)';
}


}

/// @nodoc
abstract mixin class _$HomeCalendarStateCopyWith<$Res> implements $HomeCalendarStateCopyWith<$Res> {
  factory _$HomeCalendarStateCopyWith(_HomeCalendarState value, $Res Function(_HomeCalendarState) _then) = __$HomeCalendarStateCopyWithImpl;
@override @useResult
$Res call({
 DateTime selectedStartDate, bool isMonthlyCalendarVisible, double hourHeight, DateTime displayedMonth
});




}
/// @nodoc
class __$HomeCalendarStateCopyWithImpl<$Res>
    implements _$HomeCalendarStateCopyWith<$Res> {
  __$HomeCalendarStateCopyWithImpl(this._self, this._then);

  final _HomeCalendarState _self;
  final $Res Function(_HomeCalendarState) _then;

/// Create a copy of HomeCalendarState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedStartDate = null,Object? isMonthlyCalendarVisible = null,Object? hourHeight = null,Object? displayedMonth = null,}) {
  return _then(_HomeCalendarState(
selectedStartDate: null == selectedStartDate ? _self.selectedStartDate : selectedStartDate // ignore: cast_nullable_to_non_nullable
as DateTime,isMonthlyCalendarVisible: null == isMonthlyCalendarVisible ? _self.isMonthlyCalendarVisible : isMonthlyCalendarVisible // ignore: cast_nullable_to_non_nullable
as bool,hourHeight: null == hourHeight ? _self.hourHeight : hourHeight // ignore: cast_nullable_to_non_nullable
as double,displayedMonth: null == displayedMonth ? _self.displayedMonth : displayedMonth // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
