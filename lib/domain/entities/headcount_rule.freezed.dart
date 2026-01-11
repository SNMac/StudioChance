// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'headcount_rule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HeadcountRule {

 int get headcountBase; int get headcountExtraPrice; bool get isHeadcountHourly; bool get isHeadcountPerPerson;
/// Create a copy of HeadcountRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HeadcountRuleCopyWith<HeadcountRule> get copyWith => _$HeadcountRuleCopyWithImpl<HeadcountRule>(this as HeadcountRule, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HeadcountRule&&(identical(other.headcountBase, headcountBase) || other.headcountBase == headcountBase)&&(identical(other.headcountExtraPrice, headcountExtraPrice) || other.headcountExtraPrice == headcountExtraPrice)&&(identical(other.isHeadcountHourly, isHeadcountHourly) || other.isHeadcountHourly == isHeadcountHourly)&&(identical(other.isHeadcountPerPerson, isHeadcountPerPerson) || other.isHeadcountPerPerson == isHeadcountPerPerson));
}


@override
int get hashCode => Object.hash(runtimeType,headcountBase,headcountExtraPrice,isHeadcountHourly,isHeadcountPerPerson);

@override
String toString() {
  return 'HeadcountRule(headcountBase: $headcountBase, headcountExtraPrice: $headcountExtraPrice, isHeadcountHourly: $isHeadcountHourly, isHeadcountPerPerson: $isHeadcountPerPerson)';
}


}

/// @nodoc
abstract mixin class $HeadcountRuleCopyWith<$Res>  {
  factory $HeadcountRuleCopyWith(HeadcountRule value, $Res Function(HeadcountRule) _then) = _$HeadcountRuleCopyWithImpl;
@useResult
$Res call({
 int headcountBase, int headcountExtraPrice, bool isHeadcountHourly, bool isHeadcountPerPerson
});




}
/// @nodoc
class _$HeadcountRuleCopyWithImpl<$Res>
    implements $HeadcountRuleCopyWith<$Res> {
  _$HeadcountRuleCopyWithImpl(this._self, this._then);

  final HeadcountRule _self;
  final $Res Function(HeadcountRule) _then;

/// Create a copy of HeadcountRule
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


/// Adds pattern-matching-related methods to [HeadcountRule].
extension HeadcountRulePatterns on HeadcountRule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HeadcountRule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HeadcountRule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HeadcountRule value)  $default,){
final _that = this;
switch (_that) {
case _HeadcountRule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HeadcountRule value)?  $default,){
final _that = this;
switch (_that) {
case _HeadcountRule() when $default != null:
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
case _HeadcountRule() when $default != null:
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
case _HeadcountRule():
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
case _HeadcountRule() when $default != null:
return $default(_that.headcountBase,_that.headcountExtraPrice,_that.isHeadcountHourly,_that.isHeadcountPerPerson);case _:
  return null;

}
}

}

/// @nodoc


class _HeadcountRule implements HeadcountRule {
  const _HeadcountRule({required this.headcountBase, required this.headcountExtraPrice, required this.isHeadcountHourly, required this.isHeadcountPerPerson});
  

@override final  int headcountBase;
@override final  int headcountExtraPrice;
@override final  bool isHeadcountHourly;
@override final  bool isHeadcountPerPerson;

/// Create a copy of HeadcountRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HeadcountRuleCopyWith<_HeadcountRule> get copyWith => __$HeadcountRuleCopyWithImpl<_HeadcountRule>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HeadcountRule&&(identical(other.headcountBase, headcountBase) || other.headcountBase == headcountBase)&&(identical(other.headcountExtraPrice, headcountExtraPrice) || other.headcountExtraPrice == headcountExtraPrice)&&(identical(other.isHeadcountHourly, isHeadcountHourly) || other.isHeadcountHourly == isHeadcountHourly)&&(identical(other.isHeadcountPerPerson, isHeadcountPerPerson) || other.isHeadcountPerPerson == isHeadcountPerPerson));
}


@override
int get hashCode => Object.hash(runtimeType,headcountBase,headcountExtraPrice,isHeadcountHourly,isHeadcountPerPerson);

@override
String toString() {
  return 'HeadcountRule(headcountBase: $headcountBase, headcountExtraPrice: $headcountExtraPrice, isHeadcountHourly: $isHeadcountHourly, isHeadcountPerPerson: $isHeadcountPerPerson)';
}


}

/// @nodoc
abstract mixin class _$HeadcountRuleCopyWith<$Res> implements $HeadcountRuleCopyWith<$Res> {
  factory _$HeadcountRuleCopyWith(_HeadcountRule value, $Res Function(_HeadcountRule) _then) = __$HeadcountRuleCopyWithImpl;
@override @useResult
$Res call({
 int headcountBase, int headcountExtraPrice, bool isHeadcountHourly, bool isHeadcountPerPerson
});




}
/// @nodoc
class __$HeadcountRuleCopyWithImpl<$Res>
    implements _$HeadcountRuleCopyWith<$Res> {
  __$HeadcountRuleCopyWithImpl(this._self, this._then);

  final _HeadcountRule _self;
  final $Res Function(_HeadcountRule) _then;

/// Create a copy of HeadcountRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? headcountBase = null,Object? headcountExtraPrice = null,Object? isHeadcountHourly = null,Object? isHeadcountPerPerson = null,}) {
  return _then(_HeadcountRule(
headcountBase: null == headcountBase ? _self.headcountBase : headcountBase // ignore: cast_nullable_to_non_nullable
as int,headcountExtraPrice: null == headcountExtraPrice ? _self.headcountExtraPrice : headcountExtraPrice // ignore: cast_nullable_to_non_nullable
as int,isHeadcountHourly: null == isHeadcountHourly ? _self.isHeadcountHourly : isHeadcountHourly // ignore: cast_nullable_to_non_nullable
as bool,isHeadcountPerPerson: null == isHeadcountPerPerson ? _self.isHeadcountPerPerson : isHeadcountPerPerson // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
