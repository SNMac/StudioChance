// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'space_option_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SpaceOptionModel {

 String get id; String get name; PriceSettingsModel get priceSettings;
/// Create a copy of SpaceOptionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpaceOptionModelCopyWith<SpaceOptionModel> get copyWith => _$SpaceOptionModelCopyWithImpl<SpaceOptionModel>(this as SpaceOptionModel, _$identity);

  /// Serializes this SpaceOptionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpaceOptionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.priceSettings, priceSettings) || other.priceSettings == priceSettings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,priceSettings);

@override
String toString() {
  return 'SpaceOptionModel(id: $id, name: $name, priceSettings: $priceSettings)';
}


}

/// @nodoc
abstract mixin class $SpaceOptionModelCopyWith<$Res>  {
  factory $SpaceOptionModelCopyWith(SpaceOptionModel value, $Res Function(SpaceOptionModel) _then) = _$SpaceOptionModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, PriceSettingsModel priceSettings
});


$PriceSettingsModelCopyWith<$Res> get priceSettings;

}
/// @nodoc
class _$SpaceOptionModelCopyWithImpl<$Res>
    implements $SpaceOptionModelCopyWith<$Res> {
  _$SpaceOptionModelCopyWithImpl(this._self, this._then);

  final SpaceOptionModel _self;
  final $Res Function(SpaceOptionModel) _then;

/// Create a copy of SpaceOptionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? priceSettings = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,priceSettings: null == priceSettings ? _self.priceSettings : priceSettings // ignore: cast_nullable_to_non_nullable
as PriceSettingsModel,
  ));
}
/// Create a copy of SpaceOptionModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceSettingsModelCopyWith<$Res> get priceSettings {
  
  return $PriceSettingsModelCopyWith<$Res>(_self.priceSettings, (value) {
    return _then(_self.copyWith(priceSettings: value));
  });
}
}


/// Adds pattern-matching-related methods to [SpaceOptionModel].
extension SpaceOptionModelPatterns on SpaceOptionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpaceOptionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpaceOptionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpaceOptionModel value)  $default,){
final _that = this;
switch (_that) {
case _SpaceOptionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpaceOptionModel value)?  $default,){
final _that = this;
switch (_that) {
case _SpaceOptionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  PriceSettingsModel priceSettings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpaceOptionModel() when $default != null:
return $default(_that.id,_that.name,_that.priceSettings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  PriceSettingsModel priceSettings)  $default,) {final _that = this;
switch (_that) {
case _SpaceOptionModel():
return $default(_that.id,_that.name,_that.priceSettings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  PriceSettingsModel priceSettings)?  $default,) {final _that = this;
switch (_that) {
case _SpaceOptionModel() when $default != null:
return $default(_that.id,_that.name,_that.priceSettings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SpaceOptionModel extends SpaceOptionModel {
  const _SpaceOptionModel({required this.id, required this.name, required this.priceSettings}): super._();
  factory _SpaceOptionModel.fromJson(Map<String, dynamic> json) => _$SpaceOptionModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  PriceSettingsModel priceSettings;

/// Create a copy of SpaceOptionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpaceOptionModelCopyWith<_SpaceOptionModel> get copyWith => __$SpaceOptionModelCopyWithImpl<_SpaceOptionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SpaceOptionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpaceOptionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.priceSettings, priceSettings) || other.priceSettings == priceSettings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,priceSettings);

@override
String toString() {
  return 'SpaceOptionModel(id: $id, name: $name, priceSettings: $priceSettings)';
}


}

/// @nodoc
abstract mixin class _$SpaceOptionModelCopyWith<$Res> implements $SpaceOptionModelCopyWith<$Res> {
  factory _$SpaceOptionModelCopyWith(_SpaceOptionModel value, $Res Function(_SpaceOptionModel) _then) = __$SpaceOptionModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, PriceSettingsModel priceSettings
});


@override $PriceSettingsModelCopyWith<$Res> get priceSettings;

}
/// @nodoc
class __$SpaceOptionModelCopyWithImpl<$Res>
    implements _$SpaceOptionModelCopyWith<$Res> {
  __$SpaceOptionModelCopyWithImpl(this._self, this._then);

  final _SpaceOptionModel _self;
  final $Res Function(_SpaceOptionModel) _then;

/// Create a copy of SpaceOptionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? priceSettings = null,}) {
  return _then(_SpaceOptionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,priceSettings: null == priceSettings ? _self.priceSettings : priceSettings // ignore: cast_nullable_to_non_nullable
as PriceSettingsModel,
  ));
}

/// Create a copy of SpaceOptionModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceSettingsModelCopyWith<$Res> get priceSettings {
  
  return $PriceSettingsModelCopyWith<$Res>(_self.priceSettings, (value) {
    return _then(_self.copyWith(priceSettings: value));
  });
}
}

// dart format on
