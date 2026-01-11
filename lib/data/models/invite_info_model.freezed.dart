// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invite_info_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InviteInfoModel {

 String get inviteCode;@TimestampConverter() DateTime get createdAt;
/// Create a copy of InviteInfoModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InviteInfoModelCopyWith<InviteInfoModel> get copyWith => _$InviteInfoModelCopyWithImpl<InviteInfoModel>(this as InviteInfoModel, _$identity);

  /// Serializes this InviteInfoModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InviteInfoModel&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,inviteCode,createdAt);

@override
String toString() {
  return 'InviteInfoModel(inviteCode: $inviteCode, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $InviteInfoModelCopyWith<$Res>  {
  factory $InviteInfoModelCopyWith(InviteInfoModel value, $Res Function(InviteInfoModel) _then) = _$InviteInfoModelCopyWithImpl;
@useResult
$Res call({
 String inviteCode,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class _$InviteInfoModelCopyWithImpl<$Res>
    implements $InviteInfoModelCopyWith<$Res> {
  _$InviteInfoModelCopyWithImpl(this._self, this._then);

  final InviteInfoModel _self;
  final $Res Function(InviteInfoModel) _then;

/// Create a copy of InviteInfoModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? inviteCode = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [InviteInfoModel].
extension InviteInfoModelPatterns on InviteInfoModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InviteInfoModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InviteInfoModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InviteInfoModel value)  $default,){
final _that = this;
switch (_that) {
case _InviteInfoModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InviteInfoModel value)?  $default,){
final _that = this;
switch (_that) {
case _InviteInfoModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String inviteCode, @TimestampConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InviteInfoModel() when $default != null:
return $default(_that.inviteCode,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String inviteCode, @TimestampConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _InviteInfoModel():
return $default(_that.inviteCode,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String inviteCode, @TimestampConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _InviteInfoModel() when $default != null:
return $default(_that.inviteCode,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InviteInfoModel extends InviteInfoModel {
  const _InviteInfoModel({required this.inviteCode, @TimestampConverter() required this.createdAt}): super._();
  factory _InviteInfoModel.fromJson(Map<String, dynamic> json) => _$InviteInfoModelFromJson(json);

@override final  String inviteCode;
@override@TimestampConverter() final  DateTime createdAt;

/// Create a copy of InviteInfoModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InviteInfoModelCopyWith<_InviteInfoModel> get copyWith => __$InviteInfoModelCopyWithImpl<_InviteInfoModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InviteInfoModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InviteInfoModel&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,inviteCode,createdAt);

@override
String toString() {
  return 'InviteInfoModel(inviteCode: $inviteCode, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$InviteInfoModelCopyWith<$Res> implements $InviteInfoModelCopyWith<$Res> {
  factory _$InviteInfoModelCopyWith(_InviteInfoModel value, $Res Function(_InviteInfoModel) _then) = __$InviteInfoModelCopyWithImpl;
@override @useResult
$Res call({
 String inviteCode,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class __$InviteInfoModelCopyWithImpl<$Res>
    implements _$InviteInfoModelCopyWith<$Res> {
  __$InviteInfoModelCopyWithImpl(this._self, this._then);

  final _InviteInfoModel _self;
  final $Res Function(_InviteInfoModel) _then;

/// Create a copy of InviteInfoModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? inviteCode = null,Object? createdAt = null,}) {
  return _then(_InviteInfoModel(
inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
