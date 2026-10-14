// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'price_breakdown.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PriceBreakdown {

 List<PricedDay> get days;
/// Create a copy of PriceBreakdown
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PriceBreakdownCopyWith<PriceBreakdown> get copyWith => _$PriceBreakdownCopyWithImpl<PriceBreakdown>(this as PriceBreakdown, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PriceBreakdown&&const DeepCollectionEquality().equals(other.days, days));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(days));

@override
String toString() {
  return 'PriceBreakdown(days: $days)';
}


}

/// @nodoc
abstract mixin class $PriceBreakdownCopyWith<$Res>  {
  factory $PriceBreakdownCopyWith(PriceBreakdown value, $Res Function(PriceBreakdown) _then) = _$PriceBreakdownCopyWithImpl;
@useResult
$Res call({
 List<PricedDay> days
});




}
/// @nodoc
class _$PriceBreakdownCopyWithImpl<$Res>
    implements $PriceBreakdownCopyWith<$Res> {
  _$PriceBreakdownCopyWithImpl(this._self, this._then);

  final PriceBreakdown _self;
  final $Res Function(PriceBreakdown) _then;

/// Create a copy of PriceBreakdown
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? days = null,}) {
  return _then(_self.copyWith(
days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as List<PricedDay>,
  ));
}

}


/// Adds pattern-matching-related methods to [PriceBreakdown].
extension PriceBreakdownPatterns on PriceBreakdown {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PriceBreakdown value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PriceBreakdown() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PriceBreakdown value)  $default,){
final _that = this;
switch (_that) {
case _PriceBreakdown():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PriceBreakdown value)?  $default,){
final _that = this;
switch (_that) {
case _PriceBreakdown() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PricedDay> days)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PriceBreakdown() when $default != null:
return $default(_that.days);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PricedDay> days)  $default,) {final _that = this;
switch (_that) {
case _PriceBreakdown():
return $default(_that.days);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PricedDay> days)?  $default,) {final _that = this;
switch (_that) {
case _PriceBreakdown() when $default != null:
return $default(_that.days);case _:
  return null;

}
}

}

/// @nodoc


class _PriceBreakdown extends PriceBreakdown {
  const _PriceBreakdown({required final  List<PricedDay> days}): _days = days,super._();
  

 final  List<PricedDay> _days;
@override List<PricedDay> get days {
  if (_days is EqualUnmodifiableListView) return _days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_days);
}


/// Create a copy of PriceBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PriceBreakdownCopyWith<_PriceBreakdown> get copyWith => __$PriceBreakdownCopyWithImpl<_PriceBreakdown>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PriceBreakdown&&const DeepCollectionEquality().equals(other._days, _days));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_days));

@override
String toString() {
  return 'PriceBreakdown(days: $days)';
}


}

/// @nodoc
abstract mixin class _$PriceBreakdownCopyWith<$Res> implements $PriceBreakdownCopyWith<$Res> {
  factory _$PriceBreakdownCopyWith(_PriceBreakdown value, $Res Function(_PriceBreakdown) _then) = __$PriceBreakdownCopyWithImpl;
@override @useResult
$Res call({
 List<PricedDay> days
});




}
/// @nodoc
class __$PriceBreakdownCopyWithImpl<$Res>
    implements _$PriceBreakdownCopyWith<$Res> {
  __$PriceBreakdownCopyWithImpl(this._self, this._then);

  final _PriceBreakdown _self;
  final $Res Function(_PriceBreakdown) _then;

/// Create a copy of PriceBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? days = null,}) {
  return _then(_PriceBreakdown(
days: null == days ? _self._days : days // ignore: cast_nullable_to_non_nullable
as List<PricedDay>,
  ));
}


}

/// @nodoc
mixin _$PricedDay {

 DateTime get date;/// 공휴일 요일 그룹의 요금을 적용했는지 여부. 공휴일이어도 공휴일 요일 그룹이 없어
/// 실제 요일 요금을 받았으면 false다.
 bool get holidayRateApplied; List<PriceItem> get items;
/// Create a copy of PricedDay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PricedDayCopyWith<PricedDay> get copyWith => _$PricedDayCopyWithImpl<PricedDay>(this as PricedDay, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PricedDay&&(identical(other.date, date) || other.date == date)&&(identical(other.holidayRateApplied, holidayRateApplied) || other.holidayRateApplied == holidayRateApplied)&&const DeepCollectionEquality().equals(other.items, items));
}


@override
int get hashCode => Object.hash(runtimeType,date,holidayRateApplied,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'PricedDay(date: $date, holidayRateApplied: $holidayRateApplied, items: $items)';
}


}

/// @nodoc
abstract mixin class $PricedDayCopyWith<$Res>  {
  factory $PricedDayCopyWith(PricedDay value, $Res Function(PricedDay) _then) = _$PricedDayCopyWithImpl;
@useResult
$Res call({
 DateTime date, bool holidayRateApplied, List<PriceItem> items
});




}
/// @nodoc
class _$PricedDayCopyWithImpl<$Res>
    implements $PricedDayCopyWith<$Res> {
  _$PricedDayCopyWithImpl(this._self, this._then);

  final PricedDay _self;
  final $Res Function(PricedDay) _then;

/// Create a copy of PricedDay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? holidayRateApplied = null,Object? items = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,holidayRateApplied: null == holidayRateApplied ? _self.holidayRateApplied : holidayRateApplied // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<PriceItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [PricedDay].
extension PricedDayPatterns on PricedDay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PricedDay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PricedDay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PricedDay value)  $default,){
final _that = this;
switch (_that) {
case _PricedDay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PricedDay value)?  $default,){
final _that = this;
switch (_that) {
case _PricedDay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  bool holidayRateApplied,  List<PriceItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PricedDay() when $default != null:
return $default(_that.date,_that.holidayRateApplied,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  bool holidayRateApplied,  List<PriceItem> items)  $default,) {final _that = this;
switch (_that) {
case _PricedDay():
return $default(_that.date,_that.holidayRateApplied,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  bool holidayRateApplied,  List<PriceItem> items)?  $default,) {final _that = this;
switch (_that) {
case _PricedDay() when $default != null:
return $default(_that.date,_that.holidayRateApplied,_that.items);case _:
  return null;

}
}

}

/// @nodoc


class _PricedDay extends PricedDay {
  const _PricedDay({required this.date, required this.holidayRateApplied, required final  List<PriceItem> items}): _items = items,super._();
  

@override final  DateTime date;
/// 공휴일 요일 그룹의 요금을 적용했는지 여부. 공휴일이어도 공휴일 요일 그룹이 없어
/// 실제 요일 요금을 받았으면 false다.
@override final  bool holidayRateApplied;
 final  List<PriceItem> _items;
@override List<PriceItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of PricedDay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PricedDayCopyWith<_PricedDay> get copyWith => __$PricedDayCopyWithImpl<_PricedDay>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PricedDay&&(identical(other.date, date) || other.date == date)&&(identical(other.holidayRateApplied, holidayRateApplied) || other.holidayRateApplied == holidayRateApplied)&&const DeepCollectionEquality().equals(other._items, _items));
}


@override
int get hashCode => Object.hash(runtimeType,date,holidayRateApplied,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'PricedDay(date: $date, holidayRateApplied: $holidayRateApplied, items: $items)';
}


}

/// @nodoc
abstract mixin class _$PricedDayCopyWith<$Res> implements $PricedDayCopyWith<$Res> {
  factory _$PricedDayCopyWith(_PricedDay value, $Res Function(_PricedDay) _then) = __$PricedDayCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, bool holidayRateApplied, List<PriceItem> items
});




}
/// @nodoc
class __$PricedDayCopyWithImpl<$Res>
    implements _$PricedDayCopyWith<$Res> {
  __$PricedDayCopyWithImpl(this._self, this._then);

  final _PricedDay _self;
  final $Res Function(_PricedDay) _then;

/// Create a copy of PricedDay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? holidayRateApplied = null,Object? items = null,}) {
  return _then(_PricedDay(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,holidayRateApplied: null == holidayRateApplied ? _self.holidayRateApplied : holidayRateApplied // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<PriceItem>,
  ));
}


}

/// @nodoc
mixin _$PriceItem {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PriceItem);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PriceItem()';
}


}

/// @nodoc
class $PriceItemCopyWith<$Res>  {
$PriceItemCopyWith(PriceItem _, $Res Function(PriceItem) __);
}


/// Adds pattern-matching-related methods to [PriceItem].
extension PriceItemPatterns on PriceItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SlotCharge value)?  slot,TResult Function( HeadcountCharge value)?  headcount,TResult Function( UnpricedRange value)?  unpriced,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SlotCharge() when slot != null:
return slot(_that);case HeadcountCharge() when headcount != null:
return headcount(_that);case UnpricedRange() when unpriced != null:
return unpriced(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SlotCharge value)  slot,required TResult Function( HeadcountCharge value)  headcount,required TResult Function( UnpricedRange value)  unpriced,}){
final _that = this;
switch (_that) {
case SlotCharge():
return slot(_that);case HeadcountCharge():
return headcount(_that);case UnpricedRange():
return unpriced(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SlotCharge value)?  slot,TResult? Function( HeadcountCharge value)?  headcount,TResult? Function( UnpricedRange value)?  unpriced,}){
final _that = this;
switch (_that) {
case SlotCharge() when slot != null:
return slot(_that);case HeadcountCharge() when headcount != null:
return headcount(_that);case UnpricedRange() when unpriced != null:
return unpriced(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int startMinute,  int endMinute,  int unitPrice,  bool isHourly,  int? perPersonCount,  int amount)?  slot,TResult Function( int headcountBase,  int extraPeople,  int unitPrice,  bool isPerPerson,  int? minutes,  int amount)?  headcount,TResult Function( int startMinute,  int endMinute)?  unpriced,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SlotCharge() when slot != null:
return slot(_that.startMinute,_that.endMinute,_that.unitPrice,_that.isHourly,_that.perPersonCount,_that.amount);case HeadcountCharge() when headcount != null:
return headcount(_that.headcountBase,_that.extraPeople,_that.unitPrice,_that.isPerPerson,_that.minutes,_that.amount);case UnpricedRange() when unpriced != null:
return unpriced(_that.startMinute,_that.endMinute);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int startMinute,  int endMinute,  int unitPrice,  bool isHourly,  int? perPersonCount,  int amount)  slot,required TResult Function( int headcountBase,  int extraPeople,  int unitPrice,  bool isPerPerson,  int? minutes,  int amount)  headcount,required TResult Function( int startMinute,  int endMinute)  unpriced,}) {final _that = this;
switch (_that) {
case SlotCharge():
return slot(_that.startMinute,_that.endMinute,_that.unitPrice,_that.isHourly,_that.perPersonCount,_that.amount);case HeadcountCharge():
return headcount(_that.headcountBase,_that.extraPeople,_that.unitPrice,_that.isPerPerson,_that.minutes,_that.amount);case UnpricedRange():
return unpriced(_that.startMinute,_that.endMinute);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int startMinute,  int endMinute,  int unitPrice,  bool isHourly,  int? perPersonCount,  int amount)?  slot,TResult? Function( int headcountBase,  int extraPeople,  int unitPrice,  bool isPerPerson,  int? minutes,  int amount)?  headcount,TResult? Function( int startMinute,  int endMinute)?  unpriced,}) {final _that = this;
switch (_that) {
case SlotCharge() when slot != null:
return slot(_that.startMinute,_that.endMinute,_that.unitPrice,_that.isHourly,_that.perPersonCount,_that.amount);case HeadcountCharge() when headcount != null:
return headcount(_that.headcountBase,_that.extraPeople,_that.unitPrice,_that.isPerPerson,_that.minutes,_that.amount);case UnpricedRange() when unpriced != null:
return unpriced(_that.startMinute,_that.endMinute);case _:
  return null;

}
}

}

/// @nodoc


class SlotCharge extends PriceItem {
  const SlotCharge({required this.startMinute, required this.endMinute, required this.unitPrice, required this.isHourly, this.perPersonCount, required this.amount}): super._();
  

 final  int startMinute;
 final  int endMinute;
 final  int unitPrice;
 final  bool isHourly;
 final  int? perPersonCount;
 final  int amount;

/// Create a copy of PriceItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SlotChargeCopyWith<SlotCharge> get copyWith => _$SlotChargeCopyWithImpl<SlotCharge>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SlotCharge&&(identical(other.startMinute, startMinute) || other.startMinute == startMinute)&&(identical(other.endMinute, endMinute) || other.endMinute == endMinute)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.isHourly, isHourly) || other.isHourly == isHourly)&&(identical(other.perPersonCount, perPersonCount) || other.perPersonCount == perPersonCount)&&(identical(other.amount, amount) || other.amount == amount));
}


@override
int get hashCode => Object.hash(runtimeType,startMinute,endMinute,unitPrice,isHourly,perPersonCount,amount);

@override
String toString() {
  return 'PriceItem.slot(startMinute: $startMinute, endMinute: $endMinute, unitPrice: $unitPrice, isHourly: $isHourly, perPersonCount: $perPersonCount, amount: $amount)';
}


}

/// @nodoc
abstract mixin class $SlotChargeCopyWith<$Res> implements $PriceItemCopyWith<$Res> {
  factory $SlotChargeCopyWith(SlotCharge value, $Res Function(SlotCharge) _then) = _$SlotChargeCopyWithImpl;
@useResult
$Res call({
 int startMinute, int endMinute, int unitPrice, bool isHourly, int? perPersonCount, int amount
});




}
/// @nodoc
class _$SlotChargeCopyWithImpl<$Res>
    implements $SlotChargeCopyWith<$Res> {
  _$SlotChargeCopyWithImpl(this._self, this._then);

  final SlotCharge _self;
  final $Res Function(SlotCharge) _then;

/// Create a copy of PriceItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? startMinute = null,Object? endMinute = null,Object? unitPrice = null,Object? isHourly = null,Object? perPersonCount = freezed,Object? amount = null,}) {
  return _then(SlotCharge(
startMinute: null == startMinute ? _self.startMinute : startMinute // ignore: cast_nullable_to_non_nullable
as int,endMinute: null == endMinute ? _self.endMinute : endMinute // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as int,isHourly: null == isHourly ? _self.isHourly : isHourly // ignore: cast_nullable_to_non_nullable
as bool,perPersonCount: freezed == perPersonCount ? _self.perPersonCount : perPersonCount // ignore: cast_nullable_to_non_nullable
as int?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class HeadcountCharge extends PriceItem {
  const HeadcountCharge({required this.headcountBase, required this.extraPeople, required this.unitPrice, required this.isPerPerson, this.minutes, required this.amount}): super._();
  

 final  int headcountBase;
 final  int extraPeople;
 final  int unitPrice;
 final  bool isPerPerson;
 final  int? minutes;
 final  int amount;

/// Create a copy of PriceItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HeadcountChargeCopyWith<HeadcountCharge> get copyWith => _$HeadcountChargeCopyWithImpl<HeadcountCharge>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HeadcountCharge&&(identical(other.headcountBase, headcountBase) || other.headcountBase == headcountBase)&&(identical(other.extraPeople, extraPeople) || other.extraPeople == extraPeople)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.isPerPerson, isPerPerson) || other.isPerPerson == isPerPerson)&&(identical(other.minutes, minutes) || other.minutes == minutes)&&(identical(other.amount, amount) || other.amount == amount));
}


@override
int get hashCode => Object.hash(runtimeType,headcountBase,extraPeople,unitPrice,isPerPerson,minutes,amount);

@override
String toString() {
  return 'PriceItem.headcount(headcountBase: $headcountBase, extraPeople: $extraPeople, unitPrice: $unitPrice, isPerPerson: $isPerPerson, minutes: $minutes, amount: $amount)';
}


}

/// @nodoc
abstract mixin class $HeadcountChargeCopyWith<$Res> implements $PriceItemCopyWith<$Res> {
  factory $HeadcountChargeCopyWith(HeadcountCharge value, $Res Function(HeadcountCharge) _then) = _$HeadcountChargeCopyWithImpl;
@useResult
$Res call({
 int headcountBase, int extraPeople, int unitPrice, bool isPerPerson, int? minutes, int amount
});




}
/// @nodoc
class _$HeadcountChargeCopyWithImpl<$Res>
    implements $HeadcountChargeCopyWith<$Res> {
  _$HeadcountChargeCopyWithImpl(this._self, this._then);

  final HeadcountCharge _self;
  final $Res Function(HeadcountCharge) _then;

/// Create a copy of PriceItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? headcountBase = null,Object? extraPeople = null,Object? unitPrice = null,Object? isPerPerson = null,Object? minutes = freezed,Object? amount = null,}) {
  return _then(HeadcountCharge(
headcountBase: null == headcountBase ? _self.headcountBase : headcountBase // ignore: cast_nullable_to_non_nullable
as int,extraPeople: null == extraPeople ? _self.extraPeople : extraPeople // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as int,isPerPerson: null == isPerPerson ? _self.isPerPerson : isPerPerson // ignore: cast_nullable_to_non_nullable
as bool,minutes: freezed == minutes ? _self.minutes : minutes // ignore: cast_nullable_to_non_nullable
as int?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class UnpricedRange extends PriceItem {
  const UnpricedRange({required this.startMinute, required this.endMinute}): super._();
  

 final  int startMinute;
 final  int endMinute;

/// Create a copy of PriceItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnpricedRangeCopyWith<UnpricedRange> get copyWith => _$UnpricedRangeCopyWithImpl<UnpricedRange>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnpricedRange&&(identical(other.startMinute, startMinute) || other.startMinute == startMinute)&&(identical(other.endMinute, endMinute) || other.endMinute == endMinute));
}


@override
int get hashCode => Object.hash(runtimeType,startMinute,endMinute);

@override
String toString() {
  return 'PriceItem.unpriced(startMinute: $startMinute, endMinute: $endMinute)';
}


}

/// @nodoc
abstract mixin class $UnpricedRangeCopyWith<$Res> implements $PriceItemCopyWith<$Res> {
  factory $UnpricedRangeCopyWith(UnpricedRange value, $Res Function(UnpricedRange) _then) = _$UnpricedRangeCopyWithImpl;
@useResult
$Res call({
 int startMinute, int endMinute
});




}
/// @nodoc
class _$UnpricedRangeCopyWithImpl<$Res>
    implements $UnpricedRangeCopyWith<$Res> {
  _$UnpricedRangeCopyWithImpl(this._self, this._then);

  final UnpricedRange _self;
  final $Res Function(UnpricedRange) _then;

/// Create a copy of PriceItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? startMinute = null,Object? endMinute = null,}) {
  return _then(UnpricedRange(
startMinute: null == startMinute ? _self.startMinute : startMinute // ignore: cast_nullable_to_non_nullable
as int,endMinute: null == endMinute ? _self.endMinute : endMinute // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
