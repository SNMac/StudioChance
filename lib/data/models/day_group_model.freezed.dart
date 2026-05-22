// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'day_group_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DayGroupModel {

 List<Weekday> get days; HeadcountRuleModel get headcountRuleModel; List<TimeSlotModel> get timeSlots;
/// Create a copy of DayGroupModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DayGroupModelCopyWith<DayGroupModel> get copyWith => _$DayGroupModelCopyWithImpl<DayGroupModel>(this as DayGroupModel, _$identity);

  /// Serializes this DayGroupModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DayGroupModel&&const DeepCollectionEquality().equals(other.days, days)&&(identical(other.headcountRuleModel, headcountRuleModel) || other.headcountRuleModel == headcountRuleModel)&&const DeepCollectionEquality().equals(other.timeSlots, timeSlots));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(days),headcountRuleModel,const DeepCollectionEquality().hash(timeSlots));

@override
String toString() {
  return 'DayGroupModel(days: $days, headcountRuleModel: $headcountRuleModel, timeSlots: $timeSlots)';
}


}

/// @nodoc
abstract mixin class $DayGroupModelCopyWith<$Res>  {
  factory $DayGroupModelCopyWith(DayGroupModel value, $Res Function(DayGroupModel) _then) = _$DayGroupModelCopyWithImpl;
@useResult
$Res call({
 List<Weekday> days, HeadcountRuleModel headcountRuleModel, List<TimeSlotModel> timeSlots
});


$HeadcountRuleModelCopyWith<$Res> get headcountRuleModel;

}
/// @nodoc
class _$DayGroupModelCopyWithImpl<$Res>
    implements $DayGroupModelCopyWith<$Res> {
  _$DayGroupModelCopyWithImpl(this._self, this._then);

  final DayGroupModel _self;
  final $Res Function(DayGroupModel) _then;

/// Create a copy of DayGroupModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? days = null,Object? headcountRuleModel = null,Object? timeSlots = null,}) {
  return _then(_self.copyWith(
days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as List<Weekday>,headcountRuleModel: null == headcountRuleModel ? _self.headcountRuleModel : headcountRuleModel // ignore: cast_nullable_to_non_nullable
as HeadcountRuleModel,timeSlots: null == timeSlots ? _self.timeSlots : timeSlots // ignore: cast_nullable_to_non_nullable
as List<TimeSlotModel>,
  ));
}
/// Create a copy of DayGroupModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HeadcountRuleModelCopyWith<$Res> get headcountRuleModel {
  
  return $HeadcountRuleModelCopyWith<$Res>(_self.headcountRuleModel, (value) {
    return _then(_self.copyWith(headcountRuleModel: value));
  });
}
}


/// Adds pattern-matching-related methods to [DayGroupModel].
extension DayGroupModelPatterns on DayGroupModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DayGroupModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DayGroupModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DayGroupModel value)  $default,){
final _that = this;
switch (_that) {
case _DayGroupModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DayGroupModel value)?  $default,){
final _that = this;
switch (_that) {
case _DayGroupModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Weekday> days,  HeadcountRuleModel headcountRuleModel,  List<TimeSlotModel> timeSlots)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DayGroupModel() when $default != null:
return $default(_that.days,_that.headcountRuleModel,_that.timeSlots);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Weekday> days,  HeadcountRuleModel headcountRuleModel,  List<TimeSlotModel> timeSlots)  $default,) {final _that = this;
switch (_that) {
case _DayGroupModel():
return $default(_that.days,_that.headcountRuleModel,_that.timeSlots);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Weekday> days,  HeadcountRuleModel headcountRuleModel,  List<TimeSlotModel> timeSlots)?  $default,) {final _that = this;
switch (_that) {
case _DayGroupModel() when $default != null:
return $default(_that.days,_that.headcountRuleModel,_that.timeSlots);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DayGroupModel extends DayGroupModel {
  const _DayGroupModel({final  List<Weekday> days = const [], required this.headcountRuleModel, final  List<TimeSlotModel> timeSlots = const []}): _days = days,_timeSlots = timeSlots,super._();
  factory _DayGroupModel.fromJson(Map<String, dynamic> json) => _$DayGroupModelFromJson(json);

 final  List<Weekday> _days;
@override@JsonKey() List<Weekday> get days {
  if (_days is EqualUnmodifiableListView) return _days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_days);
}

@override final  HeadcountRuleModel headcountRuleModel;
 final  List<TimeSlotModel> _timeSlots;
@override@JsonKey() List<TimeSlotModel> get timeSlots {
  if (_timeSlots is EqualUnmodifiableListView) return _timeSlots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_timeSlots);
}


/// Create a copy of DayGroupModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DayGroupModelCopyWith<_DayGroupModel> get copyWith => __$DayGroupModelCopyWithImpl<_DayGroupModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DayGroupModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DayGroupModel&&const DeepCollectionEquality().equals(other._days, _days)&&(identical(other.headcountRuleModel, headcountRuleModel) || other.headcountRuleModel == headcountRuleModel)&&const DeepCollectionEquality().equals(other._timeSlots, _timeSlots));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_days),headcountRuleModel,const DeepCollectionEquality().hash(_timeSlots));

@override
String toString() {
  return 'DayGroupModel(days: $days, headcountRuleModel: $headcountRuleModel, timeSlots: $timeSlots)';
}


}

/// @nodoc
abstract mixin class _$DayGroupModelCopyWith<$Res> implements $DayGroupModelCopyWith<$Res> {
  factory _$DayGroupModelCopyWith(_DayGroupModel value, $Res Function(_DayGroupModel) _then) = __$DayGroupModelCopyWithImpl;
@override @useResult
$Res call({
 List<Weekday> days, HeadcountRuleModel headcountRuleModel, List<TimeSlotModel> timeSlots
});


@override $HeadcountRuleModelCopyWith<$Res> get headcountRuleModel;

}
/// @nodoc
class __$DayGroupModelCopyWithImpl<$Res>
    implements _$DayGroupModelCopyWith<$Res> {
  __$DayGroupModelCopyWithImpl(this._self, this._then);

  final _DayGroupModel _self;
  final $Res Function(_DayGroupModel) _then;

/// Create a copy of DayGroupModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? days = null,Object? headcountRuleModel = null,Object? timeSlots = null,}) {
  return _then(_DayGroupModel(
days: null == days ? _self._days : days // ignore: cast_nullable_to_non_nullable
as List<Weekday>,headcountRuleModel: null == headcountRuleModel ? _self.headcountRuleModel : headcountRuleModel // ignore: cast_nullable_to_non_nullable
as HeadcountRuleModel,timeSlots: null == timeSlots ? _self._timeSlots : timeSlots // ignore: cast_nullable_to_non_nullable
as List<TimeSlotModel>,
  ));
}

/// Create a copy of DayGroupModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HeadcountRuleModelCopyWith<$Res> get headcountRuleModel {
  
  return $HeadcountRuleModelCopyWith<$Res>(_self.headcountRuleModel, (value) {
    return _then(_self.copyWith(headcountRuleModel: value));
  });
}
}

// dart format on
