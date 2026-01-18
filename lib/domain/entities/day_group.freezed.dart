// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'day_group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DayGroup {

 List<int> get days;// 1~7: 요일, 8: 공휴일
 HeadcountRule get headcountRule; List<TimeSlot> get timeSlots;
/// Create a copy of DayGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DayGroupCopyWith<DayGroup> get copyWith => _$DayGroupCopyWithImpl<DayGroup>(this as DayGroup, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DayGroup&&const DeepCollectionEquality().equals(other.days, days)&&(identical(other.headcountRule, headcountRule) || other.headcountRule == headcountRule)&&const DeepCollectionEquality().equals(other.timeSlots, timeSlots));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(days),headcountRule,const DeepCollectionEquality().hash(timeSlots));

@override
String toString() {
  return 'DayGroup(days: $days, headcountRule: $headcountRule, timeSlots: $timeSlots)';
}


}

/// @nodoc
abstract mixin class $DayGroupCopyWith<$Res>  {
  factory $DayGroupCopyWith(DayGroup value, $Res Function(DayGroup) _then) = _$DayGroupCopyWithImpl;
@useResult
$Res call({
 List<int> days, HeadcountRule headcountRule, List<TimeSlot> timeSlots
});


$HeadcountRuleCopyWith<$Res> get headcountRule;

}
/// @nodoc
class _$DayGroupCopyWithImpl<$Res>
    implements $DayGroupCopyWith<$Res> {
  _$DayGroupCopyWithImpl(this._self, this._then);

  final DayGroup _self;
  final $Res Function(DayGroup) _then;

/// Create a copy of DayGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? days = null,Object? headcountRule = null,Object? timeSlots = null,}) {
  return _then(_self.copyWith(
days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as List<int>,headcountRule: null == headcountRule ? _self.headcountRule : headcountRule // ignore: cast_nullable_to_non_nullable
as HeadcountRule,timeSlots: null == timeSlots ? _self.timeSlots : timeSlots // ignore: cast_nullable_to_non_nullable
as List<TimeSlot>,
  ));
}
/// Create a copy of DayGroup
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HeadcountRuleCopyWith<$Res> get headcountRule {
  
  return $HeadcountRuleCopyWith<$Res>(_self.headcountRule, (value) {
    return _then(_self.copyWith(headcountRule: value));
  });
}
}


/// Adds pattern-matching-related methods to [DayGroup].
extension DayGroupPatterns on DayGroup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DayGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DayGroup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DayGroup value)  $default,){
final _that = this;
switch (_that) {
case _DayGroup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DayGroup value)?  $default,){
final _that = this;
switch (_that) {
case _DayGroup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<int> days,  HeadcountRule headcountRule,  List<TimeSlot> timeSlots)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DayGroup() when $default != null:
return $default(_that.days,_that.headcountRule,_that.timeSlots);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<int> days,  HeadcountRule headcountRule,  List<TimeSlot> timeSlots)  $default,) {final _that = this;
switch (_that) {
case _DayGroup():
return $default(_that.days,_that.headcountRule,_that.timeSlots);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<int> days,  HeadcountRule headcountRule,  List<TimeSlot> timeSlots)?  $default,) {final _that = this;
switch (_that) {
case _DayGroup() when $default != null:
return $default(_that.days,_that.headcountRule,_that.timeSlots);case _:
  return null;

}
}

}

/// @nodoc


class _DayGroup implements DayGroup {
  const _DayGroup({required final  List<int> days, required this.headcountRule, required final  List<TimeSlot> timeSlots}): _days = days,_timeSlots = timeSlots;
  

 final  List<int> _days;
@override List<int> get days {
  if (_days is EqualUnmodifiableListView) return _days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_days);
}

// 1~7: 요일, 8: 공휴일
@override final  HeadcountRule headcountRule;
 final  List<TimeSlot> _timeSlots;
@override List<TimeSlot> get timeSlots {
  if (_timeSlots is EqualUnmodifiableListView) return _timeSlots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_timeSlots);
}


/// Create a copy of DayGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DayGroupCopyWith<_DayGroup> get copyWith => __$DayGroupCopyWithImpl<_DayGroup>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DayGroup&&const DeepCollectionEquality().equals(other._days, _days)&&(identical(other.headcountRule, headcountRule) || other.headcountRule == headcountRule)&&const DeepCollectionEquality().equals(other._timeSlots, _timeSlots));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_days),headcountRule,const DeepCollectionEquality().hash(_timeSlots));

@override
String toString() {
  return 'DayGroup(days: $days, headcountRule: $headcountRule, timeSlots: $timeSlots)';
}


}

/// @nodoc
abstract mixin class _$DayGroupCopyWith<$Res> implements $DayGroupCopyWith<$Res> {
  factory _$DayGroupCopyWith(_DayGroup value, $Res Function(_DayGroup) _then) = __$DayGroupCopyWithImpl;
@override @useResult
$Res call({
 List<int> days, HeadcountRule headcountRule, List<TimeSlot> timeSlots
});


@override $HeadcountRuleCopyWith<$Res> get headcountRule;

}
/// @nodoc
class __$DayGroupCopyWithImpl<$Res>
    implements _$DayGroupCopyWith<$Res> {
  __$DayGroupCopyWithImpl(this._self, this._then);

  final _DayGroup _self;
  final $Res Function(_DayGroup) _then;

/// Create a copy of DayGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? days = null,Object? headcountRule = null,Object? timeSlots = null,}) {
  return _then(_DayGroup(
days: null == days ? _self._days : days // ignore: cast_nullable_to_non_nullable
as List<int>,headcountRule: null == headcountRule ? _self.headcountRule : headcountRule // ignore: cast_nullable_to_non_nullable
as HeadcountRule,timeSlots: null == timeSlots ? _self._timeSlots : timeSlots // ignore: cast_nullable_to_non_nullable
as List<TimeSlot>,
  ));
}

/// Create a copy of DayGroup
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HeadcountRuleCopyWith<$Res> get headcountRule {
  
  return $HeadcountRuleCopyWith<$Res>(_self.headcountRule, (value) {
    return _then(_self.copyWith(headcountRule: value));
  });
}
}

// dart format on
