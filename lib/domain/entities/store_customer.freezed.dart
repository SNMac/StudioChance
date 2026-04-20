// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store_customer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StoreCustomer {

 String get id; StoreSummary get storeSummary; String get name; String get phone; int get totalSpent; int get visitCount; DateTime get lastReservationDate;
/// Create a copy of StoreCustomer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoreCustomerCopyWith<StoreCustomer> get copyWith => _$StoreCustomerCopyWithImpl<StoreCustomer>(this as StoreCustomer, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoreCustomer&&(identical(other.id, id) || other.id == id)&&(identical(other.storeSummary, storeSummary) || other.storeSummary == storeSummary)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.totalSpent, totalSpent) || other.totalSpent == totalSpent)&&(identical(other.visitCount, visitCount) || other.visitCount == visitCount)&&(identical(other.lastReservationDate, lastReservationDate) || other.lastReservationDate == lastReservationDate));
}


@override
int get hashCode => Object.hash(runtimeType,id,storeSummary,name,phone,totalSpent,visitCount,lastReservationDate);

@override
String toString() {
  return 'StoreCustomer(id: $id, storeSummary: $storeSummary, name: $name, phone: $phone, totalSpent: $totalSpent, visitCount: $visitCount, lastReservationDate: $lastReservationDate)';
}


}

/// @nodoc
abstract mixin class $StoreCustomerCopyWith<$Res>  {
  factory $StoreCustomerCopyWith(StoreCustomer value, $Res Function(StoreCustomer) _then) = _$StoreCustomerCopyWithImpl;
@useResult
$Res call({
 String id, StoreSummary storeSummary, String name, String phone, int totalSpent, int visitCount, DateTime lastReservationDate
});


$StoreSummaryCopyWith<$Res> get storeSummary;

}
/// @nodoc
class _$StoreCustomerCopyWithImpl<$Res>
    implements $StoreCustomerCopyWith<$Res> {
  _$StoreCustomerCopyWithImpl(this._self, this._then);

  final StoreCustomer _self;
  final $Res Function(StoreCustomer) _then;

/// Create a copy of StoreCustomer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? storeSummary = null,Object? name = null,Object? phone = null,Object? totalSpent = null,Object? visitCount = null,Object? lastReservationDate = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeSummary: null == storeSummary ? _self.storeSummary : storeSummary // ignore: cast_nullable_to_non_nullable
as StoreSummary,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,totalSpent: null == totalSpent ? _self.totalSpent : totalSpent // ignore: cast_nullable_to_non_nullable
as int,visitCount: null == visitCount ? _self.visitCount : visitCount // ignore: cast_nullable_to_non_nullable
as int,lastReservationDate: null == lastReservationDate ? _self.lastReservationDate : lastReservationDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of StoreCustomer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StoreSummaryCopyWith<$Res> get storeSummary {
  
  return $StoreSummaryCopyWith<$Res>(_self.storeSummary, (value) {
    return _then(_self.copyWith(storeSummary: value));
  });
}
}


/// Adds pattern-matching-related methods to [StoreCustomer].
extension StoreCustomerPatterns on StoreCustomer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoreCustomer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoreCustomer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoreCustomer value)  $default,){
final _that = this;
switch (_that) {
case _StoreCustomer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoreCustomer value)?  $default,){
final _that = this;
switch (_that) {
case _StoreCustomer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  StoreSummary storeSummary,  String name,  String phone,  int totalSpent,  int visitCount,  DateTime lastReservationDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoreCustomer() when $default != null:
return $default(_that.id,_that.storeSummary,_that.name,_that.phone,_that.totalSpent,_that.visitCount,_that.lastReservationDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  StoreSummary storeSummary,  String name,  String phone,  int totalSpent,  int visitCount,  DateTime lastReservationDate)  $default,) {final _that = this;
switch (_that) {
case _StoreCustomer():
return $default(_that.id,_that.storeSummary,_that.name,_that.phone,_that.totalSpent,_that.visitCount,_that.lastReservationDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  StoreSummary storeSummary,  String name,  String phone,  int totalSpent,  int visitCount,  DateTime lastReservationDate)?  $default,) {final _that = this;
switch (_that) {
case _StoreCustomer() when $default != null:
return $default(_that.id,_that.storeSummary,_that.name,_that.phone,_that.totalSpent,_that.visitCount,_that.lastReservationDate);case _:
  return null;

}
}

}

/// @nodoc


class _StoreCustomer implements StoreCustomer {
  const _StoreCustomer({required this.id, required this.storeSummary, required this.name, required this.phone, required this.totalSpent, required this.visitCount, required this.lastReservationDate});
  

@override final  String id;
@override final  StoreSummary storeSummary;
@override final  String name;
@override final  String phone;
@override final  int totalSpent;
@override final  int visitCount;
@override final  DateTime lastReservationDate;

/// Create a copy of StoreCustomer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoreCustomerCopyWith<_StoreCustomer> get copyWith => __$StoreCustomerCopyWithImpl<_StoreCustomer>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoreCustomer&&(identical(other.id, id) || other.id == id)&&(identical(other.storeSummary, storeSummary) || other.storeSummary == storeSummary)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.totalSpent, totalSpent) || other.totalSpent == totalSpent)&&(identical(other.visitCount, visitCount) || other.visitCount == visitCount)&&(identical(other.lastReservationDate, lastReservationDate) || other.lastReservationDate == lastReservationDate));
}


@override
int get hashCode => Object.hash(runtimeType,id,storeSummary,name,phone,totalSpent,visitCount,lastReservationDate);

@override
String toString() {
  return 'StoreCustomer(id: $id, storeSummary: $storeSummary, name: $name, phone: $phone, totalSpent: $totalSpent, visitCount: $visitCount, lastReservationDate: $lastReservationDate)';
}


}

/// @nodoc
abstract mixin class _$StoreCustomerCopyWith<$Res> implements $StoreCustomerCopyWith<$Res> {
  factory _$StoreCustomerCopyWith(_StoreCustomer value, $Res Function(_StoreCustomer) _then) = __$StoreCustomerCopyWithImpl;
@override @useResult
$Res call({
 String id, StoreSummary storeSummary, String name, String phone, int totalSpent, int visitCount, DateTime lastReservationDate
});


@override $StoreSummaryCopyWith<$Res> get storeSummary;

}
/// @nodoc
class __$StoreCustomerCopyWithImpl<$Res>
    implements _$StoreCustomerCopyWith<$Res> {
  __$StoreCustomerCopyWithImpl(this._self, this._then);

  final _StoreCustomer _self;
  final $Res Function(_StoreCustomer) _then;

/// Create a copy of StoreCustomer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? storeSummary = null,Object? name = null,Object? phone = null,Object? totalSpent = null,Object? visitCount = null,Object? lastReservationDate = null,}) {
  return _then(_StoreCustomer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeSummary: null == storeSummary ? _self.storeSummary : storeSummary // ignore: cast_nullable_to_non_nullable
as StoreSummary,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,totalSpent: null == totalSpent ? _self.totalSpent : totalSpent // ignore: cast_nullable_to_non_nullable
as int,visitCount: null == visitCount ? _self.visitCount : visitCount // ignore: cast_nullable_to_non_nullable
as int,lastReservationDate: null == lastReservationDate ? _self.lastReservationDate : lastReservationDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of StoreCustomer
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
