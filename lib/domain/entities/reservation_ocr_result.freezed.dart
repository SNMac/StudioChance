// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reservation_ocr_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReservationOcrResult {

 ReservationPlatform? get platform; String? get customerName; String? get customerPhone; DateTime? get startTime; DateTime? get endTime; bool? get isAllDay; int? get headCount; String? get memo; String? get storeName; String? get spaceName;
/// Create a copy of ReservationOcrResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReservationOcrResultCopyWith<ReservationOcrResult> get copyWith => _$ReservationOcrResultCopyWithImpl<ReservationOcrResult>(this as ReservationOcrResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReservationOcrResult&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.isAllDay, isAllDay) || other.isAllDay == isAllDay)&&(identical(other.headCount, headCount) || other.headCount == headCount)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.spaceName, spaceName) || other.spaceName == spaceName));
}


@override
int get hashCode => Object.hash(runtimeType,platform,customerName,customerPhone,startTime,endTime,isAllDay,headCount,memo,storeName,spaceName);

@override
String toString() {
  return 'ReservationOcrResult(platform: $platform, customerName: $customerName, customerPhone: $customerPhone, startTime: $startTime, endTime: $endTime, isAllDay: $isAllDay, headCount: $headCount, memo: $memo, storeName: $storeName, spaceName: $spaceName)';
}


}

/// @nodoc
abstract mixin class $ReservationOcrResultCopyWith<$Res>  {
  factory $ReservationOcrResultCopyWith(ReservationOcrResult value, $Res Function(ReservationOcrResult) _then) = _$ReservationOcrResultCopyWithImpl;
@useResult
$Res call({
 ReservationPlatform? platform, String? customerName, String? customerPhone, DateTime? startTime, DateTime? endTime, bool? isAllDay, int? headCount, String? memo, String? storeName, String? spaceName
});




}
/// @nodoc
class _$ReservationOcrResultCopyWithImpl<$Res>
    implements $ReservationOcrResultCopyWith<$Res> {
  _$ReservationOcrResultCopyWithImpl(this._self, this._then);

  final ReservationOcrResult _self;
  final $Res Function(ReservationOcrResult) _then;

/// Create a copy of ReservationOcrResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? platform = freezed,Object? customerName = freezed,Object? customerPhone = freezed,Object? startTime = freezed,Object? endTime = freezed,Object? isAllDay = freezed,Object? headCount = freezed,Object? memo = freezed,Object? storeName = freezed,Object? spaceName = freezed,}) {
  return _then(_self.copyWith(
platform: freezed == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as ReservationPlatform?,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,isAllDay: freezed == isAllDay ? _self.isAllDay : isAllDay // ignore: cast_nullable_to_non_nullable
as bool?,headCount: freezed == headCount ? _self.headCount : headCount // ignore: cast_nullable_to_non_nullable
as int?,memo: freezed == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String?,storeName: freezed == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String?,spaceName: freezed == spaceName ? _self.spaceName : spaceName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReservationOcrResult].
extension ReservationOcrResultPatterns on ReservationOcrResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReservationOcrResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReservationOcrResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReservationOcrResult value)  $default,){
final _that = this;
switch (_that) {
case _ReservationOcrResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReservationOcrResult value)?  $default,){
final _that = this;
switch (_that) {
case _ReservationOcrResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ReservationPlatform? platform,  String? customerName,  String? customerPhone,  DateTime? startTime,  DateTime? endTime,  bool? isAllDay,  int? headCount,  String? memo,  String? storeName,  String? spaceName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReservationOcrResult() when $default != null:
return $default(_that.platform,_that.customerName,_that.customerPhone,_that.startTime,_that.endTime,_that.isAllDay,_that.headCount,_that.memo,_that.storeName,_that.spaceName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ReservationPlatform? platform,  String? customerName,  String? customerPhone,  DateTime? startTime,  DateTime? endTime,  bool? isAllDay,  int? headCount,  String? memo,  String? storeName,  String? spaceName)  $default,) {final _that = this;
switch (_that) {
case _ReservationOcrResult():
return $default(_that.platform,_that.customerName,_that.customerPhone,_that.startTime,_that.endTime,_that.isAllDay,_that.headCount,_that.memo,_that.storeName,_that.spaceName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ReservationPlatform? platform,  String? customerName,  String? customerPhone,  DateTime? startTime,  DateTime? endTime,  bool? isAllDay,  int? headCount,  String? memo,  String? storeName,  String? spaceName)?  $default,) {final _that = this;
switch (_that) {
case _ReservationOcrResult() when $default != null:
return $default(_that.platform,_that.customerName,_that.customerPhone,_that.startTime,_that.endTime,_that.isAllDay,_that.headCount,_that.memo,_that.storeName,_that.spaceName);case _:
  return null;

}
}

}

/// @nodoc


class _ReservationOcrResult implements ReservationOcrResult {
  const _ReservationOcrResult({this.platform, this.customerName, this.customerPhone, this.startTime, this.endTime, this.isAllDay, this.headCount, this.memo, this.storeName, this.spaceName});
  

@override final  ReservationPlatform? platform;
@override final  String? customerName;
@override final  String? customerPhone;
@override final  DateTime? startTime;
@override final  DateTime? endTime;
@override final  bool? isAllDay;
@override final  int? headCount;
@override final  String? memo;
@override final  String? storeName;
@override final  String? spaceName;

/// Create a copy of ReservationOcrResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReservationOcrResultCopyWith<_ReservationOcrResult> get copyWith => __$ReservationOcrResultCopyWithImpl<_ReservationOcrResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReservationOcrResult&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.isAllDay, isAllDay) || other.isAllDay == isAllDay)&&(identical(other.headCount, headCount) || other.headCount == headCount)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.spaceName, spaceName) || other.spaceName == spaceName));
}


@override
int get hashCode => Object.hash(runtimeType,platform,customerName,customerPhone,startTime,endTime,isAllDay,headCount,memo,storeName,spaceName);

@override
String toString() {
  return 'ReservationOcrResult(platform: $platform, customerName: $customerName, customerPhone: $customerPhone, startTime: $startTime, endTime: $endTime, isAllDay: $isAllDay, headCount: $headCount, memo: $memo, storeName: $storeName, spaceName: $spaceName)';
}


}

/// @nodoc
abstract mixin class _$ReservationOcrResultCopyWith<$Res> implements $ReservationOcrResultCopyWith<$Res> {
  factory _$ReservationOcrResultCopyWith(_ReservationOcrResult value, $Res Function(_ReservationOcrResult) _then) = __$ReservationOcrResultCopyWithImpl;
@override @useResult
$Res call({
 ReservationPlatform? platform, String? customerName, String? customerPhone, DateTime? startTime, DateTime? endTime, bool? isAllDay, int? headCount, String? memo, String? storeName, String? spaceName
});




}
/// @nodoc
class __$ReservationOcrResultCopyWithImpl<$Res>
    implements _$ReservationOcrResultCopyWith<$Res> {
  __$ReservationOcrResultCopyWithImpl(this._self, this._then);

  final _ReservationOcrResult _self;
  final $Res Function(_ReservationOcrResult) _then;

/// Create a copy of ReservationOcrResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? platform = freezed,Object? customerName = freezed,Object? customerPhone = freezed,Object? startTime = freezed,Object? endTime = freezed,Object? isAllDay = freezed,Object? headCount = freezed,Object? memo = freezed,Object? storeName = freezed,Object? spaceName = freezed,}) {
  return _then(_ReservationOcrResult(
platform: freezed == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as ReservationPlatform?,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,isAllDay: freezed == isAllDay ? _self.isAllDay : isAllDay // ignore: cast_nullable_to_non_nullable
as bool?,headCount: freezed == headCount ? _self.headCount : headCount // ignore: cast_nullable_to_non_nullable
as int?,memo: freezed == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String?,storeName: freezed == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String?,spaceName: freezed == spaceName ? _self.spaceName : spaceName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
