// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reservation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Reservation {

 String get id; StoreSummary get storeSummary; StoreMemberInfo get writer; ReservationStatus get status; String get customerName; int get headCount; String get customerPhone; String get memo; bool get isAllDay; DateTime get startTime; DateTime get endTime; ReservationPlatform get platform; PaymentMethod get paymentMethod; int get calculatedPrice; int get priceAdjustment; int get totalPrice; String? get spaceOptionId;
/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReservationCopyWith<Reservation> get copyWith => _$ReservationCopyWithImpl<Reservation>(this as Reservation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Reservation&&(identical(other.id, id) || other.id == id)&&(identical(other.storeSummary, storeSummary) || other.storeSummary == storeSummary)&&(identical(other.writer, writer) || other.writer == writer)&&(identical(other.status, status) || other.status == status)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.headCount, headCount) || other.headCount == headCount)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.isAllDay, isAllDay) || other.isAllDay == isAllDay)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.calculatedPrice, calculatedPrice) || other.calculatedPrice == calculatedPrice)&&(identical(other.priceAdjustment, priceAdjustment) || other.priceAdjustment == priceAdjustment)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.spaceOptionId, spaceOptionId) || other.spaceOptionId == spaceOptionId));
}


@override
int get hashCode => Object.hash(runtimeType,id,storeSummary,writer,status,customerName,headCount,customerPhone,memo,isAllDay,startTime,endTime,platform,paymentMethod,calculatedPrice,priceAdjustment,totalPrice,spaceOptionId);

@override
String toString() {
  return 'Reservation(id: $id, storeSummary: $storeSummary, writer: $writer, status: $status, customerName: $customerName, headCount: $headCount, customerPhone: $customerPhone, memo: $memo, isAllDay: $isAllDay, startTime: $startTime, endTime: $endTime, platform: $platform, paymentMethod: $paymentMethod, calculatedPrice: $calculatedPrice, priceAdjustment: $priceAdjustment, totalPrice: $totalPrice, spaceOptionId: $spaceOptionId)';
}


}

/// @nodoc
abstract mixin class $ReservationCopyWith<$Res>  {
  factory $ReservationCopyWith(Reservation value, $Res Function(Reservation) _then) = _$ReservationCopyWithImpl;
@useResult
$Res call({
 String id, StoreSummary storeSummary, StoreMemberInfo writer, ReservationStatus status, String customerName, int headCount, String customerPhone, String memo, bool isAllDay, DateTime startTime, DateTime endTime, ReservationPlatform platform, PaymentMethod paymentMethod, int calculatedPrice, int priceAdjustment, int totalPrice, String? spaceOptionId
});


$StoreSummaryCopyWith<$Res> get storeSummary;$StoreMemberInfoCopyWith<$Res> get writer;

}
/// @nodoc
class _$ReservationCopyWithImpl<$Res>
    implements $ReservationCopyWith<$Res> {
  _$ReservationCopyWithImpl(this._self, this._then);

  final Reservation _self;
  final $Res Function(Reservation) _then;

/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? storeSummary = null,Object? writer = null,Object? status = null,Object? customerName = null,Object? headCount = null,Object? customerPhone = null,Object? memo = null,Object? isAllDay = null,Object? startTime = null,Object? endTime = null,Object? platform = null,Object? paymentMethod = null,Object? calculatedPrice = null,Object? priceAdjustment = null,Object? totalPrice = null,Object? spaceOptionId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeSummary: null == storeSummary ? _self.storeSummary : storeSummary // ignore: cast_nullable_to_non_nullable
as StoreSummary,writer: null == writer ? _self.writer : writer // ignore: cast_nullable_to_non_nullable
as StoreMemberInfo,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
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
as int,spaceOptionId: freezed == spaceOptionId ? _self.spaceOptionId : spaceOptionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StoreSummaryCopyWith<$Res> get storeSummary {
  
  return $StoreSummaryCopyWith<$Res>(_self.storeSummary, (value) {
    return _then(_self.copyWith(storeSummary: value));
  });
}/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StoreMemberInfoCopyWith<$Res> get writer {
  
  return $StoreMemberInfoCopyWith<$Res>(_self.writer, (value) {
    return _then(_self.copyWith(writer: value));
  });
}
}


/// Adds pattern-matching-related methods to [Reservation].
extension ReservationPatterns on Reservation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Reservation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Reservation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Reservation value)  $default,){
final _that = this;
switch (_that) {
case _Reservation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Reservation value)?  $default,){
final _that = this;
switch (_that) {
case _Reservation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  StoreSummary storeSummary,  StoreMemberInfo writer,  ReservationStatus status,  String customerName,  int headCount,  String customerPhone,  String memo,  bool isAllDay,  DateTime startTime,  DateTime endTime,  ReservationPlatform platform,  PaymentMethod paymentMethod,  int calculatedPrice,  int priceAdjustment,  int totalPrice,  String? spaceOptionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Reservation() when $default != null:
return $default(_that.id,_that.storeSummary,_that.writer,_that.status,_that.customerName,_that.headCount,_that.customerPhone,_that.memo,_that.isAllDay,_that.startTime,_that.endTime,_that.platform,_that.paymentMethod,_that.calculatedPrice,_that.priceAdjustment,_that.totalPrice,_that.spaceOptionId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  StoreSummary storeSummary,  StoreMemberInfo writer,  ReservationStatus status,  String customerName,  int headCount,  String customerPhone,  String memo,  bool isAllDay,  DateTime startTime,  DateTime endTime,  ReservationPlatform platform,  PaymentMethod paymentMethod,  int calculatedPrice,  int priceAdjustment,  int totalPrice,  String? spaceOptionId)  $default,) {final _that = this;
switch (_that) {
case _Reservation():
return $default(_that.id,_that.storeSummary,_that.writer,_that.status,_that.customerName,_that.headCount,_that.customerPhone,_that.memo,_that.isAllDay,_that.startTime,_that.endTime,_that.platform,_that.paymentMethod,_that.calculatedPrice,_that.priceAdjustment,_that.totalPrice,_that.spaceOptionId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  StoreSummary storeSummary,  StoreMemberInfo writer,  ReservationStatus status,  String customerName,  int headCount,  String customerPhone,  String memo,  bool isAllDay,  DateTime startTime,  DateTime endTime,  ReservationPlatform platform,  PaymentMethod paymentMethod,  int calculatedPrice,  int priceAdjustment,  int totalPrice,  String? spaceOptionId)?  $default,) {final _that = this;
switch (_that) {
case _Reservation() when $default != null:
return $default(_that.id,_that.storeSummary,_that.writer,_that.status,_that.customerName,_that.headCount,_that.customerPhone,_that.memo,_that.isAllDay,_that.startTime,_that.endTime,_that.platform,_that.paymentMethod,_that.calculatedPrice,_that.priceAdjustment,_that.totalPrice,_that.spaceOptionId);case _:
  return null;

}
}

}

/// @nodoc


class _Reservation implements Reservation {
  const _Reservation({required this.id, required this.storeSummary, required this.writer, required this.status, required this.customerName, required this.headCount, required this.customerPhone, required this.memo, required this.isAllDay, required this.startTime, required this.endTime, required this.platform, required this.paymentMethod, required this.calculatedPrice, required this.priceAdjustment, required this.totalPrice, this.spaceOptionId});
  

@override final  String id;
@override final  StoreSummary storeSummary;
@override final  StoreMemberInfo writer;
@override final  ReservationStatus status;
@override final  String customerName;
@override final  int headCount;
@override final  String customerPhone;
@override final  String memo;
@override final  bool isAllDay;
@override final  DateTime startTime;
@override final  DateTime endTime;
@override final  ReservationPlatform platform;
@override final  PaymentMethod paymentMethod;
@override final  int calculatedPrice;
@override final  int priceAdjustment;
@override final  int totalPrice;
@override final  String? spaceOptionId;

/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReservationCopyWith<_Reservation> get copyWith => __$ReservationCopyWithImpl<_Reservation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Reservation&&(identical(other.id, id) || other.id == id)&&(identical(other.storeSummary, storeSummary) || other.storeSummary == storeSummary)&&(identical(other.writer, writer) || other.writer == writer)&&(identical(other.status, status) || other.status == status)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.headCount, headCount) || other.headCount == headCount)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.isAllDay, isAllDay) || other.isAllDay == isAllDay)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.calculatedPrice, calculatedPrice) || other.calculatedPrice == calculatedPrice)&&(identical(other.priceAdjustment, priceAdjustment) || other.priceAdjustment == priceAdjustment)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.spaceOptionId, spaceOptionId) || other.spaceOptionId == spaceOptionId));
}


@override
int get hashCode => Object.hash(runtimeType,id,storeSummary,writer,status,customerName,headCount,customerPhone,memo,isAllDay,startTime,endTime,platform,paymentMethod,calculatedPrice,priceAdjustment,totalPrice,spaceOptionId);

@override
String toString() {
  return 'Reservation(id: $id, storeSummary: $storeSummary, writer: $writer, status: $status, customerName: $customerName, headCount: $headCount, customerPhone: $customerPhone, memo: $memo, isAllDay: $isAllDay, startTime: $startTime, endTime: $endTime, platform: $platform, paymentMethod: $paymentMethod, calculatedPrice: $calculatedPrice, priceAdjustment: $priceAdjustment, totalPrice: $totalPrice, spaceOptionId: $spaceOptionId)';
}


}

/// @nodoc
abstract mixin class _$ReservationCopyWith<$Res> implements $ReservationCopyWith<$Res> {
  factory _$ReservationCopyWith(_Reservation value, $Res Function(_Reservation) _then) = __$ReservationCopyWithImpl;
@override @useResult
$Res call({
 String id, StoreSummary storeSummary, StoreMemberInfo writer, ReservationStatus status, String customerName, int headCount, String customerPhone, String memo, bool isAllDay, DateTime startTime, DateTime endTime, ReservationPlatform platform, PaymentMethod paymentMethod, int calculatedPrice, int priceAdjustment, int totalPrice, String? spaceOptionId
});


@override $StoreSummaryCopyWith<$Res> get storeSummary;@override $StoreMemberInfoCopyWith<$Res> get writer;

}
/// @nodoc
class __$ReservationCopyWithImpl<$Res>
    implements _$ReservationCopyWith<$Res> {
  __$ReservationCopyWithImpl(this._self, this._then);

  final _Reservation _self;
  final $Res Function(_Reservation) _then;

/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? storeSummary = null,Object? writer = null,Object? status = null,Object? customerName = null,Object? headCount = null,Object? customerPhone = null,Object? memo = null,Object? isAllDay = null,Object? startTime = null,Object? endTime = null,Object? platform = null,Object? paymentMethod = null,Object? calculatedPrice = null,Object? priceAdjustment = null,Object? totalPrice = null,Object? spaceOptionId = freezed,}) {
  return _then(_Reservation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeSummary: null == storeSummary ? _self.storeSummary : storeSummary // ignore: cast_nullable_to_non_nullable
as StoreSummary,writer: null == writer ? _self.writer : writer // ignore: cast_nullable_to_non_nullable
as StoreMemberInfo,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
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
as int,spaceOptionId: freezed == spaceOptionId ? _self.spaceOptionId : spaceOptionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StoreSummaryCopyWith<$Res> get storeSummary {
  
  return $StoreSummaryCopyWith<$Res>(_self.storeSummary, (value) {
    return _then(_self.copyWith(storeSummary: value));
  });
}/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StoreMemberInfoCopyWith<$Res> get writer {
  
  return $StoreMemberInfoCopyWith<$Res>(_self.writer, (value) {
    return _then(_self.copyWith(writer: value));
  });
}
}

// dart format on
