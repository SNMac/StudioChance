// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reservation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReservationModel {

@JsonKey(includeToJson: false) String get id; String get storeId; String get writerId; ReservationStatus get status; String get customerName; int get headCount; String get customerPhone; String get memo; bool get isAllDay;@TimestampConverter() DateTime get startTime;@TimestampConverter() DateTime get endTime; ReservationPlatform get platform; PaymentMethod get paymentMethod; int get calculatedPrice; int get priceAdjustment; int get totalPrice; UserRole? get writerRole;
/// Create a copy of ReservationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReservationModelCopyWith<ReservationModel> get copyWith => _$ReservationModelCopyWithImpl<ReservationModel>(this as ReservationModel, _$identity);

  /// Serializes this ReservationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReservationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.writerId, writerId) || other.writerId == writerId)&&(identical(other.status, status) || other.status == status)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.headCount, headCount) || other.headCount == headCount)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.isAllDay, isAllDay) || other.isAllDay == isAllDay)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.calculatedPrice, calculatedPrice) || other.calculatedPrice == calculatedPrice)&&(identical(other.priceAdjustment, priceAdjustment) || other.priceAdjustment == priceAdjustment)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.writerRole, writerRole) || other.writerRole == writerRole));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,storeId,writerId,status,customerName,headCount,customerPhone,memo,isAllDay,startTime,endTime,platform,paymentMethod,calculatedPrice,priceAdjustment,totalPrice,writerRole);

@override
String toString() {
  return 'ReservationModel(id: $id, storeId: $storeId, writerId: $writerId, status: $status, customerName: $customerName, headCount: $headCount, customerPhone: $customerPhone, memo: $memo, isAllDay: $isAllDay, startTime: $startTime, endTime: $endTime, platform: $platform, paymentMethod: $paymentMethod, calculatedPrice: $calculatedPrice, priceAdjustment: $priceAdjustment, totalPrice: $totalPrice, writerRole: $writerRole)';
}


}

/// @nodoc
abstract mixin class $ReservationModelCopyWith<$Res>  {
  factory $ReservationModelCopyWith(ReservationModel value, $Res Function(ReservationModel) _then) = _$ReservationModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) String id, String storeId, String writerId, ReservationStatus status, String customerName, int headCount, String customerPhone, String memo, bool isAllDay,@TimestampConverter() DateTime startTime,@TimestampConverter() DateTime endTime, ReservationPlatform platform, PaymentMethod paymentMethod, int calculatedPrice, int priceAdjustment, int totalPrice, UserRole? writerRole
});




}
/// @nodoc
class _$ReservationModelCopyWithImpl<$Res>
    implements $ReservationModelCopyWith<$Res> {
  _$ReservationModelCopyWithImpl(this._self, this._then);

  final ReservationModel _self;
  final $Res Function(ReservationModel) _then;

/// Create a copy of ReservationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? storeId = null,Object? writerId = null,Object? status = null,Object? customerName = null,Object? headCount = null,Object? customerPhone = null,Object? memo = null,Object? isAllDay = null,Object? startTime = null,Object? endTime = null,Object? platform = null,Object? paymentMethod = null,Object? calculatedPrice = null,Object? priceAdjustment = null,Object? totalPrice = null,Object? writerRole = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,writerId: null == writerId ? _self.writerId : writerId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReservationStatus,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,headCount: null == headCount ? _self.headCount : headCount // ignore: cast_nullable_to_non_nullable
as int,customerPhone: null == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String,memo: null == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String,isAllDay: null == isAllDay ? _self.isAllDay : isAllDay // ignore: cast_nullable_to_non_nullable
as bool,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as ReservationPlatform,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod,calculatedPrice: null == calculatedPrice ? _self.calculatedPrice : calculatedPrice // ignore: cast_nullable_to_non_nullable
as int,priceAdjustment: null == priceAdjustment ? _self.priceAdjustment : priceAdjustment // ignore: cast_nullable_to_non_nullable
as int,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as int,writerRole: freezed == writerRole ? _self.writerRole : writerRole // ignore: cast_nullable_to_non_nullable
as UserRole?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReservationModel].
extension ReservationModelPatterns on ReservationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReservationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReservationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReservationModel value)  $default,){
final _that = this;
switch (_that) {
case _ReservationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReservationModel value)?  $default,){
final _that = this;
switch (_that) {
case _ReservationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String storeId,  String writerId,  ReservationStatus status,  String customerName,  int headCount,  String customerPhone,  String memo,  bool isAllDay, @TimestampConverter()  DateTime startTime, @TimestampConverter()  DateTime endTime,  ReservationPlatform platform,  PaymentMethod paymentMethod,  int calculatedPrice,  int priceAdjustment,  int totalPrice,  UserRole? writerRole)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReservationModel() when $default != null:
return $default(_that.id,_that.storeId,_that.writerId,_that.status,_that.customerName,_that.headCount,_that.customerPhone,_that.memo,_that.isAllDay,_that.startTime,_that.endTime,_that.platform,_that.paymentMethod,_that.calculatedPrice,_that.priceAdjustment,_that.totalPrice,_that.writerRole);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String storeId,  String writerId,  ReservationStatus status,  String customerName,  int headCount,  String customerPhone,  String memo,  bool isAllDay, @TimestampConverter()  DateTime startTime, @TimestampConverter()  DateTime endTime,  ReservationPlatform platform,  PaymentMethod paymentMethod,  int calculatedPrice,  int priceAdjustment,  int totalPrice,  UserRole? writerRole)  $default,) {final _that = this;
switch (_that) {
case _ReservationModel():
return $default(_that.id,_that.storeId,_that.writerId,_that.status,_that.customerName,_that.headCount,_that.customerPhone,_that.memo,_that.isAllDay,_that.startTime,_that.endTime,_that.platform,_that.paymentMethod,_that.calculatedPrice,_that.priceAdjustment,_that.totalPrice,_that.writerRole);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  String id,  String storeId,  String writerId,  ReservationStatus status,  String customerName,  int headCount,  String customerPhone,  String memo,  bool isAllDay, @TimestampConverter()  DateTime startTime, @TimestampConverter()  DateTime endTime,  ReservationPlatform platform,  PaymentMethod paymentMethod,  int calculatedPrice,  int priceAdjustment,  int totalPrice,  UserRole? writerRole)?  $default,) {final _that = this;
switch (_that) {
case _ReservationModel() when $default != null:
return $default(_that.id,_that.storeId,_that.writerId,_that.status,_that.customerName,_that.headCount,_that.customerPhone,_that.memo,_that.isAllDay,_that.startTime,_that.endTime,_that.platform,_that.paymentMethod,_that.calculatedPrice,_that.priceAdjustment,_that.totalPrice,_that.writerRole);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReservationModel extends ReservationModel {
  const _ReservationModel({@JsonKey(includeToJson: false) required this.id, required this.storeId, required this.writerId, required this.status, required this.customerName, required this.headCount, required this.customerPhone, required this.memo, required this.isAllDay, @TimestampConverter() required this.startTime, @TimestampConverter() required this.endTime, required this.platform, required this.paymentMethod, required this.calculatedPrice, required this.priceAdjustment, required this.totalPrice, this.writerRole}): super._();
  factory _ReservationModel.fromJson(Map<String, dynamic> json) => _$ReservationModelFromJson(json);

@override@JsonKey(includeToJson: false) final  String id;
@override final  String storeId;
@override final  String writerId;
@override final  ReservationStatus status;
@override final  String customerName;
@override final  int headCount;
@override final  String customerPhone;
@override final  String memo;
@override final  bool isAllDay;
@override@TimestampConverter() final  DateTime startTime;
@override@TimestampConverter() final  DateTime endTime;
@override final  ReservationPlatform platform;
@override final  PaymentMethod paymentMethod;
@override final  int calculatedPrice;
@override final  int priceAdjustment;
@override final  int totalPrice;
@override final  UserRole? writerRole;

/// Create a copy of ReservationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReservationModelCopyWith<_ReservationModel> get copyWith => __$ReservationModelCopyWithImpl<_ReservationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReservationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReservationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.writerId, writerId) || other.writerId == writerId)&&(identical(other.status, status) || other.status == status)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.headCount, headCount) || other.headCount == headCount)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.isAllDay, isAllDay) || other.isAllDay == isAllDay)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.calculatedPrice, calculatedPrice) || other.calculatedPrice == calculatedPrice)&&(identical(other.priceAdjustment, priceAdjustment) || other.priceAdjustment == priceAdjustment)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.writerRole, writerRole) || other.writerRole == writerRole));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,storeId,writerId,status,customerName,headCount,customerPhone,memo,isAllDay,startTime,endTime,platform,paymentMethod,calculatedPrice,priceAdjustment,totalPrice,writerRole);

@override
String toString() {
  return 'ReservationModel(id: $id, storeId: $storeId, writerId: $writerId, status: $status, customerName: $customerName, headCount: $headCount, customerPhone: $customerPhone, memo: $memo, isAllDay: $isAllDay, startTime: $startTime, endTime: $endTime, platform: $platform, paymentMethod: $paymentMethod, calculatedPrice: $calculatedPrice, priceAdjustment: $priceAdjustment, totalPrice: $totalPrice, writerRole: $writerRole)';
}


}

/// @nodoc
abstract mixin class _$ReservationModelCopyWith<$Res> implements $ReservationModelCopyWith<$Res> {
  factory _$ReservationModelCopyWith(_ReservationModel value, $Res Function(_ReservationModel) _then) = __$ReservationModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) String id, String storeId, String writerId, ReservationStatus status, String customerName, int headCount, String customerPhone, String memo, bool isAllDay,@TimestampConverter() DateTime startTime,@TimestampConverter() DateTime endTime, ReservationPlatform platform, PaymentMethod paymentMethod, int calculatedPrice, int priceAdjustment, int totalPrice, UserRole? writerRole
});




}
/// @nodoc
class __$ReservationModelCopyWithImpl<$Res>
    implements _$ReservationModelCopyWith<$Res> {
  __$ReservationModelCopyWithImpl(this._self, this._then);

  final _ReservationModel _self;
  final $Res Function(_ReservationModel) _then;

/// Create a copy of ReservationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? storeId = null,Object? writerId = null,Object? status = null,Object? customerName = null,Object? headCount = null,Object? customerPhone = null,Object? memo = null,Object? isAllDay = null,Object? startTime = null,Object? endTime = null,Object? platform = null,Object? paymentMethod = null,Object? calculatedPrice = null,Object? priceAdjustment = null,Object? totalPrice = null,Object? writerRole = freezed,}) {
  return _then(_ReservationModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,writerId: null == writerId ? _self.writerId : writerId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReservationStatus,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,headCount: null == headCount ? _self.headCount : headCount // ignore: cast_nullable_to_non_nullable
as int,customerPhone: null == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String,memo: null == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String,isAllDay: null == isAllDay ? _self.isAllDay : isAllDay // ignore: cast_nullable_to_non_nullable
as bool,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as ReservationPlatform,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod,calculatedPrice: null == calculatedPrice ? _self.calculatedPrice : calculatedPrice // ignore: cast_nullable_to_non_nullable
as int,priceAdjustment: null == priceAdjustment ? _self.priceAdjustment : priceAdjustment // ignore: cast_nullable_to_non_nullable
as int,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as int,writerRole: freezed == writerRole ? _self.writerRole : writerRole // ignore: cast_nullable_to_non_nullable
as UserRole?,
  ));
}


}

// dart format on
