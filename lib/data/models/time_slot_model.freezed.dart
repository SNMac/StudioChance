// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'time_slot_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TimeSlotModel {

 int get startTime;// 분 단위
 int get endTime;// 분 단위
 int get price; bool get isHourly; bool get isPerPerson;
/// Create a copy of TimeSlotModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimeSlotModelCopyWith<TimeSlotModel> get copyWith => _$TimeSlotModelCopyWithImpl<TimeSlotModel>(this as TimeSlotModel, _$identity);

  /// Serializes this TimeSlotModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimeSlotModel&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.price, price) || other.price == price)&&(identical(other.isHourly, isHourly) || other.isHourly == isHourly)&&(identical(other.isPerPerson, isPerPerson) || other.isPerPerson == isPerPerson));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startTime,endTime,price,isHourly,isPerPerson);

@override
String toString() {
  return 'TimeSlotModel(startTime: $startTime, endTime: $endTime, price: $price, isHourly: $isHourly, isPerPerson: $isPerPerson)';
}


}

/// @nodoc
abstract mixin class $TimeSlotModelCopyWith<$Res>  {
  factory $TimeSlotModelCopyWith(TimeSlotModel value, $Res Function(TimeSlotModel) _then) = _$TimeSlotModelCopyWithImpl;
@useResult
$Res call({
 int startTime, int endTime, int price, bool isHourly, bool isPerPerson
});




}
/// @nodoc
class _$TimeSlotModelCopyWithImpl<$Res>
    implements $TimeSlotModelCopyWith<$Res> {
  _$TimeSlotModelCopyWithImpl(this._self, this._then);

  final TimeSlotModel _self;
  final $Res Function(TimeSlotModel) _then;

/// Create a copy of TimeSlotModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startTime = null,Object? endTime = null,Object? price = null,Object? isHourly = null,Object? isPerPerson = null,}) {
  return _then(_self.copyWith(
startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as int,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as int,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int,isHourly: null == isHourly ? _self.isHourly : isHourly // ignore: cast_nullable_to_non_nullable
as bool,isPerPerson: null == isPerPerson ? _self.isPerPerson : isPerPerson // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TimeSlotModel].
extension TimeSlotModelPatterns on TimeSlotModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimeSlotModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimeSlotModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimeSlotModel value)  $default,){
final _that = this;
switch (_that) {
case _TimeSlotModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimeSlotModel value)?  $default,){
final _that = this;
switch (_that) {
case _TimeSlotModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int startTime,  int endTime,  int price,  bool isHourly,  bool isPerPerson)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimeSlotModel() when $default != null:
return $default(_that.startTime,_that.endTime,_that.price,_that.isHourly,_that.isPerPerson);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int startTime,  int endTime,  int price,  bool isHourly,  bool isPerPerson)  $default,) {final _that = this;
switch (_that) {
case _TimeSlotModel():
return $default(_that.startTime,_that.endTime,_that.price,_that.isHourly,_that.isPerPerson);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int startTime,  int endTime,  int price,  bool isHourly,  bool isPerPerson)?  $default,) {final _that = this;
switch (_that) {
case _TimeSlotModel() when $default != null:
return $default(_that.startTime,_that.endTime,_that.price,_that.isHourly,_that.isPerPerson);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TimeSlotModel implements TimeSlotModel {
  const _TimeSlotModel({required this.startTime, required this.endTime, required this.price, required this.isHourly, required this.isPerPerson});
  factory _TimeSlotModel.fromJson(Map<String, dynamic> json) => _$TimeSlotModelFromJson(json);

@override final  int startTime;
// 분 단위
@override final  int endTime;
// 분 단위
@override final  int price;
@override final  bool isHourly;
@override final  bool isPerPerson;

/// Create a copy of TimeSlotModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimeSlotModelCopyWith<_TimeSlotModel> get copyWith => __$TimeSlotModelCopyWithImpl<_TimeSlotModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimeSlotModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimeSlotModel&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.price, price) || other.price == price)&&(identical(other.isHourly, isHourly) || other.isHourly == isHourly)&&(identical(other.isPerPerson, isPerPerson) || other.isPerPerson == isPerPerson));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startTime,endTime,price,isHourly,isPerPerson);

@override
String toString() {
  return 'TimeSlotModel(startTime: $startTime, endTime: $endTime, price: $price, isHourly: $isHourly, isPerPerson: $isPerPerson)';
}


}

/// @nodoc
abstract mixin class _$TimeSlotModelCopyWith<$Res> implements $TimeSlotModelCopyWith<$Res> {
  factory _$TimeSlotModelCopyWith(_TimeSlotModel value, $Res Function(_TimeSlotModel) _then) = __$TimeSlotModelCopyWithImpl;
@override @useResult
$Res call({
 int startTime, int endTime, int price, bool isHourly, bool isPerPerson
});




}
/// @nodoc
class __$TimeSlotModelCopyWithImpl<$Res>
    implements _$TimeSlotModelCopyWith<$Res> {
  __$TimeSlotModelCopyWithImpl(this._self, this._then);

  final _TimeSlotModel _self;
  final $Res Function(_TimeSlotModel) _then;

/// Create a copy of TimeSlotModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startTime = null,Object? endTime = null,Object? price = null,Object? isHourly = null,Object? isPerPerson = null,}) {
  return _then(_TimeSlotModel(
startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as int,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as int,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int,isHourly: null == isHourly ? _self.isHourly : isHourly // ignore: cast_nullable_to_non_nullable
as bool,isPerPerson: null == isPerPerson ? _self.isPerPerson : isPerPerson // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
