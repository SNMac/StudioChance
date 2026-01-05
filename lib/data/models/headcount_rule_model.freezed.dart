// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'headcount_rule_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HeadcountRuleModel {

 int get headcountBase; int get headcountExtraPrice; bool get isHeadcountHourly; bool get isHeadcountPerPerson;
/// Create a copy of HeadcountRuleModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HeadcountRuleModelCopyWith<HeadcountRuleModel> get copyWith => _$HeadcountRuleModelCopyWithImpl<HeadcountRuleModel>(this as HeadcountRuleModel, _$identity);

  /// Serializes this HeadcountRuleModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HeadcountRuleModel&&(identical(other.headcountBase, headcountBase) || other.headcountBase == headcountBase)&&(identical(other.headcountExtraPrice, headcountExtraPrice) || other.headcountExtraPrice == headcountExtraPrice)&&(identical(other.isHeadcountHourly, isHeadcountHourly) || other.isHeadcountHourly == isHeadcountHourly)&&(identical(other.isHeadcountPerPerson, isHeadcountPerPerson) || other.isHeadcountPerPerson == isHeadcountPerPerson));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,headcountBase,headcountExtraPrice,isHeadcountHourly,isHeadcountPerPerson);

@override
String toString() {
  return 'HeadcountRuleModel(headcountBase: $headcountBase, headcountExtraPrice: $headcountExtraPrice, isHeadcountHourly: $isHeadcountHourly, isHeadcountPerPerson: $isHeadcountPerPerson)';
}


}

/// @nodoc
abstract mixin class $HeadcountRuleModelCopyWith<$Res>  {
  factory $HeadcountRuleModelCopyWith(HeadcountRuleModel value, $Res Function(HeadcountRuleModel) _then) = _$HeadcountRuleModelCopyWithImpl;
@useResult
$Res call({
 int headcountBase, int headcountExtraPrice, bool isHeadcountHourly, bool isHeadcountPerPerson
});




}
/// @nodoc
class _$HeadcountRuleModelCopyWithImpl<$Res>
    implements $HeadcountRuleModelCopyWith<$Res> {
  _$HeadcountRuleModelCopyWithImpl(this._self, this._then);

  final HeadcountRuleModel _self;
  final $Res Function(HeadcountRuleModel) _then;

/// Create a copy of HeadcountRuleModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? headcountBase = null,Object? headcountExtraPrice = null,Object? isHeadcountHourly = null,Object? isHeadcountPerPerson = null,}) {
  return _then(_self.copyWith(
headcountBase: null == headcountBase ? _self.headcountBase : headcountBase // ignore: cast_nullable_to_non_nullable
as int,headcountExtraPrice: null == headcountExtraPrice ? _self.headcountExtraPrice : headcountExtraPrice // ignore: cast_nullable_to_non_nullable
as int,isHeadcountHourly: null == isHeadcountHourly ? _self.isHeadcountHourly : isHeadcountHourly // ignore: cast_nullable_to_non_nullable
as bool,isHeadcountPerPerson: null == isHeadcountPerPerson ? _self.isHeadcountPerPerson : isHeadcountPerPerson // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [HeadcountRuleModel].
extension HeadcountRuleModelPatterns on HeadcountRuleModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HeadcountRuleModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HeadcountRuleModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HeadcountRuleModel value)  $default,){
final _that = this;
switch (_that) {
case _HeadcountRuleModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HeadcountRuleModel value)?  $default,){
final _that = this;
switch (_that) {
case _HeadcountRuleModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int headcountBase,  int headcountExtraPrice,  bool isHeadcountHourly,  bool isHeadcountPerPerson)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HeadcountRuleModel() when $default != null:
return $default(_that.headcountBase,_that.headcountExtraPrice,_that.isHeadcountHourly,_that.isHeadcountPerPerson);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int headcountBase,  int headcountExtraPrice,  bool isHeadcountHourly,  bool isHeadcountPerPerson)  $default,) {final _that = this;
switch (_that) {
case _HeadcountRuleModel():
return $default(_that.headcountBase,_that.headcountExtraPrice,_that.isHeadcountHourly,_that.isHeadcountPerPerson);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int headcountBase,  int headcountExtraPrice,  bool isHeadcountHourly,  bool isHeadcountPerPerson)?  $default,) {final _that = this;
switch (_that) {
case _HeadcountRuleModel() when $default != null:
return $default(_that.headcountBase,_that.headcountExtraPrice,_that.isHeadcountHourly,_that.isHeadcountPerPerson);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HeadcountRuleModel implements HeadcountRuleModel {
  const _HeadcountRuleModel({required this.headcountBase, required this.headcountExtraPrice, required this.isHeadcountHourly, required this.isHeadcountPerPerson});
  factory _HeadcountRuleModel.fromJson(Map<String, dynamic> json) => _$HeadcountRuleModelFromJson(json);

@override final  int headcountBase;
@override final  int headcountExtraPrice;
@override final  bool isHeadcountHourly;
@override final  bool isHeadcountPerPerson;

/// Create a copy of HeadcountRuleModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HeadcountRuleModelCopyWith<_HeadcountRuleModel> get copyWith => __$HeadcountRuleModelCopyWithImpl<_HeadcountRuleModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HeadcountRuleModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HeadcountRuleModel&&(identical(other.headcountBase, headcountBase) || other.headcountBase == headcountBase)&&(identical(other.headcountExtraPrice, headcountExtraPrice) || other.headcountExtraPrice == headcountExtraPrice)&&(identical(other.isHeadcountHourly, isHeadcountHourly) || other.isHeadcountHourly == isHeadcountHourly)&&(identical(other.isHeadcountPerPerson, isHeadcountPerPerson) || other.isHeadcountPerPerson == isHeadcountPerPerson));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,headcountBase,headcountExtraPrice,isHeadcountHourly,isHeadcountPerPerson);

@override
String toString() {
  return 'HeadcountRuleModel(headcountBase: $headcountBase, headcountExtraPrice: $headcountExtraPrice, isHeadcountHourly: $isHeadcountHourly, isHeadcountPerPerson: $isHeadcountPerPerson)';
}


}

/// @nodoc
abstract mixin class _$HeadcountRuleModelCopyWith<$Res> implements $HeadcountRuleModelCopyWith<$Res> {
  factory _$HeadcountRuleModelCopyWith(_HeadcountRuleModel value, $Res Function(_HeadcountRuleModel) _then) = __$HeadcountRuleModelCopyWithImpl;
@override @useResult
$Res call({
 int headcountBase, int headcountExtraPrice, bool isHeadcountHourly, bool isHeadcountPerPerson
});




}
/// @nodoc
class __$HeadcountRuleModelCopyWithImpl<$Res>
    implements _$HeadcountRuleModelCopyWith<$Res> {
  __$HeadcountRuleModelCopyWithImpl(this._self, this._then);

  final _HeadcountRuleModel _self;
  final $Res Function(_HeadcountRuleModel) _then;

/// Create a copy of HeadcountRuleModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? headcountBase = null,Object? headcountExtraPrice = null,Object? isHeadcountHourly = null,Object? isHeadcountPerPerson = null,}) {
  return _then(_HeadcountRuleModel(
headcountBase: null == headcountBase ? _self.headcountBase : headcountBase // ignore: cast_nullable_to_non_nullable
as int,headcountExtraPrice: null == headcountExtraPrice ? _self.headcountExtraPrice : headcountExtraPrice // ignore: cast_nullable_to_non_nullable
as int,isHeadcountHourly: null == isHeadcountHourly ? _self.isHeadcountHourly : isHeadcountHourly // ignore: cast_nullable_to_non_nullable
as bool,isHeadcountPerPerson: null == isHeadcountPerPerson ? _self.isHeadcountPerPerson : isHeadcountPerPerson // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
