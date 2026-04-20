// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store_customer_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StoreCustomerModel {

@JsonKey(includeToJson: false) String get id; String get storeId; String get name; String get phone;// ⚠️ DataSource에서 FieldValue.increment()로만 업데이트. 직접 덮어쓰기 금지.
 int get totalSpent;// ⚠️ DataSource에서 FieldValue.increment()로만 업데이트. 직접 덮어쓰기 금지.
 int get visitCount;// ⚠️ DataSource에서 예약 startTime 기준으로만 업데이트.
@TimestampConverter() DateTime get lastReservationDate;
/// Create a copy of StoreCustomerModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoreCustomerModelCopyWith<StoreCustomerModel> get copyWith => _$StoreCustomerModelCopyWithImpl<StoreCustomerModel>(this as StoreCustomerModel, _$identity);

  /// Serializes this StoreCustomerModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoreCustomerModel&&(identical(other.id, id) || other.id == id)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.totalSpent, totalSpent) || other.totalSpent == totalSpent)&&(identical(other.visitCount, visitCount) || other.visitCount == visitCount)&&(identical(other.lastReservationDate, lastReservationDate) || other.lastReservationDate == lastReservationDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,storeId,name,phone,totalSpent,visitCount,lastReservationDate);

@override
String toString() {
  return 'StoreCustomerModel(id: $id, storeId: $storeId, name: $name, phone: $phone, totalSpent: $totalSpent, visitCount: $visitCount, lastReservationDate: $lastReservationDate)';
}


}

/// @nodoc
abstract mixin class $StoreCustomerModelCopyWith<$Res>  {
  factory $StoreCustomerModelCopyWith(StoreCustomerModel value, $Res Function(StoreCustomerModel) _then) = _$StoreCustomerModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) String id, String storeId, String name, String phone, int totalSpent, int visitCount,@TimestampConverter() DateTime lastReservationDate
});




}
/// @nodoc
class _$StoreCustomerModelCopyWithImpl<$Res>
    implements $StoreCustomerModelCopyWith<$Res> {
  _$StoreCustomerModelCopyWithImpl(this._self, this._then);

  final StoreCustomerModel _self;
  final $Res Function(StoreCustomerModel) _then;

/// Create a copy of StoreCustomerModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? storeId = null,Object? name = null,Object? phone = null,Object? totalSpent = null,Object? visitCount = null,Object? lastReservationDate = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,totalSpent: null == totalSpent ? _self.totalSpent : totalSpent // ignore: cast_nullable_to_non_nullable
as int,visitCount: null == visitCount ? _self.visitCount : visitCount // ignore: cast_nullable_to_non_nullable
as int,lastReservationDate: null == lastReservationDate ? _self.lastReservationDate : lastReservationDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [StoreCustomerModel].
extension StoreCustomerModelPatterns on StoreCustomerModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoreCustomerModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoreCustomerModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoreCustomerModel value)  $default,){
final _that = this;
switch (_that) {
case _StoreCustomerModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoreCustomerModel value)?  $default,){
final _that = this;
switch (_that) {
case _StoreCustomerModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String storeId,  String name,  String phone,  int totalSpent,  int visitCount, @TimestampConverter()  DateTime lastReservationDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoreCustomerModel() when $default != null:
return $default(_that.id,_that.storeId,_that.name,_that.phone,_that.totalSpent,_that.visitCount,_that.lastReservationDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String storeId,  String name,  String phone,  int totalSpent,  int visitCount, @TimestampConverter()  DateTime lastReservationDate)  $default,) {final _that = this;
switch (_that) {
case _StoreCustomerModel():
return $default(_that.id,_that.storeId,_that.name,_that.phone,_that.totalSpent,_that.visitCount,_that.lastReservationDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  String id,  String storeId,  String name,  String phone,  int totalSpent,  int visitCount, @TimestampConverter()  DateTime lastReservationDate)?  $default,) {final _that = this;
switch (_that) {
case _StoreCustomerModel() when $default != null:
return $default(_that.id,_that.storeId,_that.name,_that.phone,_that.totalSpent,_that.visitCount,_that.lastReservationDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StoreCustomerModel extends StoreCustomerModel {
  const _StoreCustomerModel({@JsonKey(includeToJson: false) required this.id, required this.storeId, required this.name, required this.phone, required this.totalSpent, required this.visitCount, @TimestampConverter() required this.lastReservationDate}): super._();
  factory _StoreCustomerModel.fromJson(Map<String, dynamic> json) => _$StoreCustomerModelFromJson(json);

@override@JsonKey(includeToJson: false) final  String id;
@override final  String storeId;
@override final  String name;
@override final  String phone;
// ⚠️ DataSource에서 FieldValue.increment()로만 업데이트. 직접 덮어쓰기 금지.
@override final  int totalSpent;
// ⚠️ DataSource에서 FieldValue.increment()로만 업데이트. 직접 덮어쓰기 금지.
@override final  int visitCount;
// ⚠️ DataSource에서 예약 startTime 기준으로만 업데이트.
@override@TimestampConverter() final  DateTime lastReservationDate;

/// Create a copy of StoreCustomerModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoreCustomerModelCopyWith<_StoreCustomerModel> get copyWith => __$StoreCustomerModelCopyWithImpl<_StoreCustomerModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StoreCustomerModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoreCustomerModel&&(identical(other.id, id) || other.id == id)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.totalSpent, totalSpent) || other.totalSpent == totalSpent)&&(identical(other.visitCount, visitCount) || other.visitCount == visitCount)&&(identical(other.lastReservationDate, lastReservationDate) || other.lastReservationDate == lastReservationDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,storeId,name,phone,totalSpent,visitCount,lastReservationDate);

@override
String toString() {
  return 'StoreCustomerModel(id: $id, storeId: $storeId, name: $name, phone: $phone, totalSpent: $totalSpent, visitCount: $visitCount, lastReservationDate: $lastReservationDate)';
}


}

/// @nodoc
abstract mixin class _$StoreCustomerModelCopyWith<$Res> implements $StoreCustomerModelCopyWith<$Res> {
  factory _$StoreCustomerModelCopyWith(_StoreCustomerModel value, $Res Function(_StoreCustomerModel) _then) = __$StoreCustomerModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) String id, String storeId, String name, String phone, int totalSpent, int visitCount,@TimestampConverter() DateTime lastReservationDate
});




}
/// @nodoc
class __$StoreCustomerModelCopyWithImpl<$Res>
    implements _$StoreCustomerModelCopyWith<$Res> {
  __$StoreCustomerModelCopyWithImpl(this._self, this._then);

  final _StoreCustomerModel _self;
  final $Res Function(_StoreCustomerModel) _then;

/// Create a copy of StoreCustomerModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? storeId = null,Object? name = null,Object? phone = null,Object? totalSpent = null,Object? visitCount = null,Object? lastReservationDate = null,}) {
  return _then(_StoreCustomerModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,totalSpent: null == totalSpent ? _self.totalSpent : totalSpent // ignore: cast_nullable_to_non_nullable
as int,visitCount: null == visitCount ? _self.visitCount : visitCount // ignore: cast_nullable_to_non_nullable
as int,lastReservationDate: null == lastReservationDate ? _self.lastReservationDate : lastReservationDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
