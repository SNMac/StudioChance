// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reservation_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReservationSummary {

 String get id; StoreSummary get storeSummary; ReservationStatus get status; String get customerName; int get headCount; String get customerPhone; bool get isAllDay; DateTime get startTime; DateTime get endTime;
/// Create a copy of ReservationSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReservationSummaryCopyWith<ReservationSummary> get copyWith => _$ReservationSummaryCopyWithImpl<ReservationSummary>(this as ReservationSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReservationSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.storeSummary, storeSummary) || other.storeSummary == storeSummary)&&(identical(other.status, status) || other.status == status)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.headCount, headCount) || other.headCount == headCount)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.isAllDay, isAllDay) || other.isAllDay == isAllDay)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime));
}


@override
int get hashCode => Object.hash(runtimeType,id,storeSummary,status,customerName,headCount,customerPhone,isAllDay,startTime,endTime);

@override
String toString() {
  return 'ReservationSummary(id: $id, storeSummary: $storeSummary, status: $status, customerName: $customerName, headCount: $headCount, customerPhone: $customerPhone, isAllDay: $isAllDay, startTime: $startTime, endTime: $endTime)';
}


}

/// @nodoc
abstract mixin class $ReservationSummaryCopyWith<$Res>  {
  factory $ReservationSummaryCopyWith(ReservationSummary value, $Res Function(ReservationSummary) _then) = _$ReservationSummaryCopyWithImpl;
@useResult
$Res call({
 String id, StoreSummary storeSummary, ReservationStatus status, String customerName, int headCount, String customerPhone, bool isAllDay, DateTime startTime, DateTime endTime
});


$StoreSummaryCopyWith<$Res> get storeSummary;

}
/// @nodoc
class _$ReservationSummaryCopyWithImpl<$Res>
    implements $ReservationSummaryCopyWith<$Res> {
  _$ReservationSummaryCopyWithImpl(this._self, this._then);

  final ReservationSummary _self;
  final $Res Function(ReservationSummary) _then;

/// Create a copy of ReservationSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? storeSummary = null,Object? status = null,Object? customerName = null,Object? headCount = null,Object? customerPhone = null,Object? isAllDay = null,Object? startTime = null,Object? endTime = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeSummary: null == storeSummary ? _self.storeSummary : storeSummary // ignore: cast_nullable_to_non_nullable
as StoreSummary,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReservationStatus,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,headCount: null == headCount ? _self.headCount : headCount // ignore: cast_nullable_to_non_nullable
as int,customerPhone: null == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String,isAllDay: null == isAllDay ? _self.isAllDay : isAllDay // ignore: cast_nullable_to_non_nullable
as bool,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of ReservationSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StoreSummaryCopyWith<$Res> get storeSummary {
  
  return $StoreSummaryCopyWith<$Res>(_self.storeSummary, (value) {
    return _then(_self.copyWith(storeSummary: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReservationSummary].
extension ReservationSummaryPatterns on ReservationSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReservationSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReservationSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReservationSummary value)  $default,){
final _that = this;
switch (_that) {
case _ReservationSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReservationSummary value)?  $default,){
final _that = this;
switch (_that) {
case _ReservationSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  StoreSummary storeSummary,  ReservationStatus status,  String customerName,  int headCount,  String customerPhone,  bool isAllDay,  DateTime startTime,  DateTime endTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReservationSummary() when $default != null:
return $default(_that.id,_that.storeSummary,_that.status,_that.customerName,_that.headCount,_that.customerPhone,_that.isAllDay,_that.startTime,_that.endTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  StoreSummary storeSummary,  ReservationStatus status,  String customerName,  int headCount,  String customerPhone,  bool isAllDay,  DateTime startTime,  DateTime endTime)  $default,) {final _that = this;
switch (_that) {
case _ReservationSummary():
return $default(_that.id,_that.storeSummary,_that.status,_that.customerName,_that.headCount,_that.customerPhone,_that.isAllDay,_that.startTime,_that.endTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  StoreSummary storeSummary,  ReservationStatus status,  String customerName,  int headCount,  String customerPhone,  bool isAllDay,  DateTime startTime,  DateTime endTime)?  $default,) {final _that = this;
switch (_that) {
case _ReservationSummary() when $default != null:
return $default(_that.id,_that.storeSummary,_that.status,_that.customerName,_that.headCount,_that.customerPhone,_that.isAllDay,_that.startTime,_that.endTime);case _:
  return null;

}
}

}

/// @nodoc


class _ReservationSummary implements ReservationSummary {
  const _ReservationSummary({required this.id, required this.storeSummary, required this.status, required this.customerName, required this.headCount, required this.customerPhone, required this.isAllDay, required this.startTime, required this.endTime});
  

@override final  String id;
@override final  StoreSummary storeSummary;
@override final  ReservationStatus status;
@override final  String customerName;
@override final  int headCount;
@override final  String customerPhone;
@override final  bool isAllDay;
@override final  DateTime startTime;
@override final  DateTime endTime;

/// Create a copy of ReservationSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReservationSummaryCopyWith<_ReservationSummary> get copyWith => __$ReservationSummaryCopyWithImpl<_ReservationSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReservationSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.storeSummary, storeSummary) || other.storeSummary == storeSummary)&&(identical(other.status, status) || other.status == status)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.headCount, headCount) || other.headCount == headCount)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.isAllDay, isAllDay) || other.isAllDay == isAllDay)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime));
}


@override
int get hashCode => Object.hash(runtimeType,id,storeSummary,status,customerName,headCount,customerPhone,isAllDay,startTime,endTime);

@override
String toString() {
  return 'ReservationSummary(id: $id, storeSummary: $storeSummary, status: $status, customerName: $customerName, headCount: $headCount, customerPhone: $customerPhone, isAllDay: $isAllDay, startTime: $startTime, endTime: $endTime)';
}


}

/// @nodoc
abstract mixin class _$ReservationSummaryCopyWith<$Res> implements $ReservationSummaryCopyWith<$Res> {
  factory _$ReservationSummaryCopyWith(_ReservationSummary value, $Res Function(_ReservationSummary) _then) = __$ReservationSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, StoreSummary storeSummary, ReservationStatus status, String customerName, int headCount, String customerPhone, bool isAllDay, DateTime startTime, DateTime endTime
});


@override $StoreSummaryCopyWith<$Res> get storeSummary;

}
/// @nodoc
class __$ReservationSummaryCopyWithImpl<$Res>
    implements _$ReservationSummaryCopyWith<$Res> {
  __$ReservationSummaryCopyWithImpl(this._self, this._then);

  final _ReservationSummary _self;
  final $Res Function(_ReservationSummary) _then;

/// Create a copy of ReservationSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? storeSummary = null,Object? status = null,Object? customerName = null,Object? headCount = null,Object? customerPhone = null,Object? isAllDay = null,Object? startTime = null,Object? endTime = null,}) {
  return _then(_ReservationSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeSummary: null == storeSummary ? _self.storeSummary : storeSummary // ignore: cast_nullable_to_non_nullable
as StoreSummary,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReservationStatus,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,headCount: null == headCount ? _self.headCount : headCount // ignore: cast_nullable_to_non_nullable
as int,customerPhone: null == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String,isAllDay: null == isAllDay ? _self.isAllDay : isAllDay // ignore: cast_nullable_to_non_nullable
as bool,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of ReservationSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StoreSummaryCopyWith<$Res> get storeSummary {
  
  return $StoreSummaryCopyWith<$Res>(_self.storeSummary, (value) {
    return _then(_self.copyWith(storeSummary: value));
  });
}
}

// dart format on
