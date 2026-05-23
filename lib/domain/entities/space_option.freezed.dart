// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'space_option.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SpaceOption {

 String get id; String get name; PriceSetting get priceSetting;
/// Create a copy of SpaceOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpaceOptionCopyWith<SpaceOption> get copyWith => _$SpaceOptionCopyWithImpl<SpaceOption>(this as SpaceOption, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpaceOption&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.priceSetting, priceSetting) || other.priceSetting == priceSetting));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,priceSetting);

@override
String toString() {
  return 'SpaceOption(id: $id, name: $name, priceSetting: $priceSetting)';
}


}

/// @nodoc
abstract mixin class $SpaceOptionCopyWith<$Res>  {
  factory $SpaceOptionCopyWith(SpaceOption value, $Res Function(SpaceOption) _then) = _$SpaceOptionCopyWithImpl;
@useResult
$Res call({
 String id, String name, PriceSetting priceSetting
});


$PriceSettingCopyWith<$Res> get priceSetting;

}
/// @nodoc
class _$SpaceOptionCopyWithImpl<$Res>
    implements $SpaceOptionCopyWith<$Res> {
  _$SpaceOptionCopyWithImpl(this._self, this._then);

  final SpaceOption _self;
  final $Res Function(SpaceOption) _then;

/// Create a copy of SpaceOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? priceSetting = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,priceSetting: null == priceSetting ? _self.priceSetting : priceSetting // ignore: cast_nullable_to_non_nullable
as PriceSetting,
  ));
}
/// Create a copy of SpaceOption
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceSettingCopyWith<$Res> get priceSetting {
  
  return $PriceSettingCopyWith<$Res>(_self.priceSetting, (value) {
    return _then(_self.copyWith(priceSetting: value));
  });
}
}


/// Adds pattern-matching-related methods to [SpaceOption].
extension SpaceOptionPatterns on SpaceOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpaceOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpaceOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpaceOption value)  $default,){
final _that = this;
switch (_that) {
case _SpaceOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpaceOption value)?  $default,){
final _that = this;
switch (_that) {
case _SpaceOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  PriceSetting priceSetting)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpaceOption() when $default != null:
return $default(_that.id,_that.name,_that.priceSetting);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  PriceSetting priceSetting)  $default,) {final _that = this;
switch (_that) {
case _SpaceOption():
return $default(_that.id,_that.name,_that.priceSetting);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  PriceSetting priceSetting)?  $default,) {final _that = this;
switch (_that) {
case _SpaceOption() when $default != null:
return $default(_that.id,_that.name,_that.priceSetting);case _:
  return null;

}
}

}

/// @nodoc


class _SpaceOption implements SpaceOption {
  const _SpaceOption({required this.id, required this.name, required this.priceSetting});
  

@override final  String id;
@override final  String name;
@override final  PriceSetting priceSetting;

/// Create a copy of SpaceOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpaceOptionCopyWith<_SpaceOption> get copyWith => __$SpaceOptionCopyWithImpl<_SpaceOption>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpaceOption&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.priceSetting, priceSetting) || other.priceSetting == priceSetting));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,priceSetting);

@override
String toString() {
  return 'SpaceOption(id: $id, name: $name, priceSetting: $priceSetting)';
}


}

/// @nodoc
abstract mixin class _$SpaceOptionCopyWith<$Res> implements $SpaceOptionCopyWith<$Res> {
  factory _$SpaceOptionCopyWith(_SpaceOption value, $Res Function(_SpaceOption) _then) = __$SpaceOptionCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, PriceSetting priceSetting
});


@override $PriceSettingCopyWith<$Res> get priceSetting;

}
/// @nodoc
class __$SpaceOptionCopyWithImpl<$Res>
    implements _$SpaceOptionCopyWith<$Res> {
  __$SpaceOptionCopyWithImpl(this._self, this._then);

  final _SpaceOption _self;
  final $Res Function(_SpaceOption) _then;

/// Create a copy of SpaceOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? priceSetting = null,}) {
  return _then(_SpaceOption(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,priceSetting: null == priceSetting ? _self.priceSetting : priceSetting // ignore: cast_nullable_to_non_nullable
as PriceSetting,
  ));
}

/// Create a copy of SpaceOption
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceSettingCopyWith<$Res> get priceSetting {
  
  return $PriceSettingCopyWith<$Res>(_self.priceSetting, (value) {
    return _then(_self.copyWith(priceSetting: value));
  });
}
}

// dart format on
