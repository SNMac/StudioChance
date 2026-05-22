// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StoreSummary {

 String get id; String get name; StoreColor get color;
/// Create a copy of StoreSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoreSummaryCopyWith<StoreSummary> get copyWith => _$StoreSummaryCopyWithImpl<StoreSummary>(this as StoreSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoreSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,color);

@override
String toString() {
  return 'StoreSummary(id: $id, name: $name, color: $color)';
}


}

/// @nodoc
abstract mixin class $StoreSummaryCopyWith<$Res>  {
  factory $StoreSummaryCopyWith(StoreSummary value, $Res Function(StoreSummary) _then) = _$StoreSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String name, StoreColor color
});




}
/// @nodoc
class _$StoreSummaryCopyWithImpl<$Res>
    implements $StoreSummaryCopyWith<$Res> {
  _$StoreSummaryCopyWithImpl(this._self, this._then);

  final StoreSummary _self;
  final $Res Function(StoreSummary) _then;

/// Create a copy of StoreSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? color = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as StoreColor,
  ));
}

}


/// Adds pattern-matching-related methods to [StoreSummary].
extension StoreSummaryPatterns on StoreSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoreSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoreSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoreSummary value)  $default,){
final _that = this;
switch (_that) {
case _StoreSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoreSummary value)?  $default,){
final _that = this;
switch (_that) {
case _StoreSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  StoreColor color)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoreSummary() when $default != null:
return $default(_that.id,_that.name,_that.color);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  StoreColor color)  $default,) {final _that = this;
switch (_that) {
case _StoreSummary():
return $default(_that.id,_that.name,_that.color);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  StoreColor color)?  $default,) {final _that = this;
switch (_that) {
case _StoreSummary() when $default != null:
return $default(_that.id,_that.name,_that.color);case _:
  return null;

}
}

}

/// @nodoc


class _StoreSummary implements StoreSummary {
  const _StoreSummary({required this.id, required this.name, required this.color});
  

@override final  String id;
@override final  String name;
@override final  StoreColor color;

/// Create a copy of StoreSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoreSummaryCopyWith<_StoreSummary> get copyWith => __$StoreSummaryCopyWithImpl<_StoreSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoreSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,color);

@override
String toString() {
  return 'StoreSummary(id: $id, name: $name, color: $color)';
}


}

/// @nodoc
abstract mixin class _$StoreSummaryCopyWith<$Res> implements $StoreSummaryCopyWith<$Res> {
  factory _$StoreSummaryCopyWith(_StoreSummary value, $Res Function(_StoreSummary) _then) = __$StoreSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, StoreColor color
});




}
/// @nodoc
class __$StoreSummaryCopyWithImpl<$Res>
    implements _$StoreSummaryCopyWith<$Res> {
  __$StoreSummaryCopyWithImpl(this._self, this._then);

  final _StoreSummary _self;
  final $Res Function(_StoreSummary) _then;

/// Create a copy of StoreSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? color = null,}) {
  return _then(_StoreSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as StoreColor,
  ));
}


}

// dart format on
