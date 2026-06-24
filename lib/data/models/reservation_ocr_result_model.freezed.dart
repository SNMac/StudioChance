// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reservation_ocr_result_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReservationOcrResultModel {

@JsonKey(name: 'platform', fromJson: _parsePlatform) ReservationPlatform? get platform; String? get customerName; String? get customerPhone;@JsonKey(fromJson: _parseDateTimeNullable) DateTime? get startTime;@JsonKey(fromJson: _parseDateTimeNullable) DateTime? get endTime; bool? get isAllDay; int? get headCount; String? get memo; String? get storeName; String? get spaceName;
/// Create a copy of ReservationOcrResultModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReservationOcrResultModelCopyWith<ReservationOcrResultModel> get copyWith => _$ReservationOcrResultModelCopyWithImpl<ReservationOcrResultModel>(this as ReservationOcrResultModel, _$identity);

  /// Serializes this ReservationOcrResultModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReservationOcrResultModel&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.isAllDay, isAllDay) || other.isAllDay == isAllDay)&&(identical(other.headCount, headCount) || other.headCount == headCount)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.spaceName, spaceName) || other.spaceName == spaceName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,platform,customerName,customerPhone,startTime,endTime,isAllDay,headCount,memo,storeName,spaceName);

@override
String toString() {
  return 'ReservationOcrResultModel(platform: $platform, customerName: $customerName, customerPhone: $customerPhone, startTime: $startTime, endTime: $endTime, isAllDay: $isAllDay, headCount: $headCount, memo: $memo, storeName: $storeName, spaceName: $spaceName)';
}


}

/// @nodoc
abstract mixin class $ReservationOcrResultModelCopyWith<$Res>  {
  factory $ReservationOcrResultModelCopyWith(ReservationOcrResultModel value, $Res Function(ReservationOcrResultModel) _then) = _$ReservationOcrResultModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'platform', fromJson: _parsePlatform) ReservationPlatform? platform, String? customerName, String? customerPhone,@JsonKey(fromJson: _parseDateTimeNullable) DateTime? startTime,@JsonKey(fromJson: _parseDateTimeNullable) DateTime? endTime, bool? isAllDay, int? headCount, String? memo, String? storeName, String? spaceName
});




}
/// @nodoc
class _$ReservationOcrResultModelCopyWithImpl<$Res>
    implements $ReservationOcrResultModelCopyWith<$Res> {
  _$ReservationOcrResultModelCopyWithImpl(this._self, this._then);

  final ReservationOcrResultModel _self;
  final $Res Function(ReservationOcrResultModel) _then;

/// Create a copy of ReservationOcrResultModel
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


/// Adds pattern-matching-related methods to [ReservationOcrResultModel].
extension ReservationOcrResultModelPatterns on ReservationOcrResultModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReservationOcrResultModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReservationOcrResultModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReservationOcrResultModel value)  $default,){
final _that = this;
switch (_that) {
case _ReservationOcrResultModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReservationOcrResultModel value)?  $default,){
final _that = this;
switch (_that) {
case _ReservationOcrResultModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'platform', fromJson: _parsePlatform)  ReservationPlatform? platform,  String? customerName,  String? customerPhone, @JsonKey(fromJson: _parseDateTimeNullable)  DateTime? startTime, @JsonKey(fromJson: _parseDateTimeNullable)  DateTime? endTime,  bool? isAllDay,  int? headCount,  String? memo,  String? storeName,  String? spaceName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReservationOcrResultModel() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'platform', fromJson: _parsePlatform)  ReservationPlatform? platform,  String? customerName,  String? customerPhone, @JsonKey(fromJson: _parseDateTimeNullable)  DateTime? startTime, @JsonKey(fromJson: _parseDateTimeNullable)  DateTime? endTime,  bool? isAllDay,  int? headCount,  String? memo,  String? storeName,  String? spaceName)  $default,) {final _that = this;
switch (_that) {
case _ReservationOcrResultModel():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'platform', fromJson: _parsePlatform)  ReservationPlatform? platform,  String? customerName,  String? customerPhone, @JsonKey(fromJson: _parseDateTimeNullable)  DateTime? startTime, @JsonKey(fromJson: _parseDateTimeNullable)  DateTime? endTime,  bool? isAllDay,  int? headCount,  String? memo,  String? storeName,  String? spaceName)?  $default,) {final _that = this;
switch (_that) {
case _ReservationOcrResultModel() when $default != null:
return $default(_that.platform,_that.customerName,_that.customerPhone,_that.startTime,_that.endTime,_that.isAllDay,_that.headCount,_that.memo,_that.storeName,_that.spaceName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReservationOcrResultModel extends ReservationOcrResultModel {
  const _ReservationOcrResultModel({@JsonKey(name: 'platform', fromJson: _parsePlatform) this.platform, this.customerName, this.customerPhone, @JsonKey(fromJson: _parseDateTimeNullable) this.startTime, @JsonKey(fromJson: _parseDateTimeNullable) this.endTime, this.isAllDay, this.headCount, this.memo, this.storeName, this.spaceName}): super._();
  factory _ReservationOcrResultModel.fromJson(Map<String, dynamic> json) => _$ReservationOcrResultModelFromJson(json);

@override@JsonKey(name: 'platform', fromJson: _parsePlatform) final  ReservationPlatform? platform;
@override final  String? customerName;
@override final  String? customerPhone;
@override@JsonKey(fromJson: _parseDateTimeNullable) final  DateTime? startTime;
@override@JsonKey(fromJson: _parseDateTimeNullable) final  DateTime? endTime;
@override final  bool? isAllDay;
@override final  int? headCount;
@override final  String? memo;
@override final  String? storeName;
@override final  String? spaceName;

/// Create a copy of ReservationOcrResultModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReservationOcrResultModelCopyWith<_ReservationOcrResultModel> get copyWith => __$ReservationOcrResultModelCopyWithImpl<_ReservationOcrResultModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReservationOcrResultModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReservationOcrResultModel&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.isAllDay, isAllDay) || other.isAllDay == isAllDay)&&(identical(other.headCount, headCount) || other.headCount == headCount)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.spaceName, spaceName) || other.spaceName == spaceName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,platform,customerName,customerPhone,startTime,endTime,isAllDay,headCount,memo,storeName,spaceName);

@override
String toString() {
  return 'ReservationOcrResultModel(platform: $platform, customerName: $customerName, customerPhone: $customerPhone, startTime: $startTime, endTime: $endTime, isAllDay: $isAllDay, headCount: $headCount, memo: $memo, storeName: $storeName, spaceName: $spaceName)';
}


}

/// @nodoc
abstract mixin class _$ReservationOcrResultModelCopyWith<$Res> implements $ReservationOcrResultModelCopyWith<$Res> {
  factory _$ReservationOcrResultModelCopyWith(_ReservationOcrResultModel value, $Res Function(_ReservationOcrResultModel) _then) = __$ReservationOcrResultModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'platform', fromJson: _parsePlatform) ReservationPlatform? platform, String? customerName, String? customerPhone,@JsonKey(fromJson: _parseDateTimeNullable) DateTime? startTime,@JsonKey(fromJson: _parseDateTimeNullable) DateTime? endTime, bool? isAllDay, int? headCount, String? memo, String? storeName, String? spaceName
});




}
/// @nodoc
class __$ReservationOcrResultModelCopyWithImpl<$Res>
    implements _$ReservationOcrResultModelCopyWith<$Res> {
  __$ReservationOcrResultModelCopyWithImpl(this._self, this._then);

  final _ReservationOcrResultModel _self;
  final $Res Function(_ReservationOcrResultModel) _then;

/// Create a copy of ReservationOcrResultModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? platform = freezed,Object? customerName = freezed,Object? customerPhone = freezed,Object? startTime = freezed,Object? endTime = freezed,Object? isAllDay = freezed,Object? headCount = freezed,Object? memo = freezed,Object? storeName = freezed,Object? spaceName = freezed,}) {
  return _then(_ReservationOcrResultModel(
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
