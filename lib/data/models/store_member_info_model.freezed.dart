// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store_member_info_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StoreMemberInfoModel {

 UserRole get role;
/// Create a copy of StoreMemberInfoModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoreMemberInfoModelCopyWith<StoreMemberInfoModel> get copyWith => _$StoreMemberInfoModelCopyWithImpl<StoreMemberInfoModel>(this as StoreMemberInfoModel, _$identity);

  /// Serializes this StoreMemberInfoModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoreMemberInfoModel&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role);

@override
String toString() {
  return 'StoreMemberInfoModel(role: $role)';
}


}

/// @nodoc
abstract mixin class $StoreMemberInfoModelCopyWith<$Res>  {
  factory $StoreMemberInfoModelCopyWith(StoreMemberInfoModel value, $Res Function(StoreMemberInfoModel) _then) = _$StoreMemberInfoModelCopyWithImpl;
@useResult
$Res call({
 UserRole role
});




}
/// @nodoc
class _$StoreMemberInfoModelCopyWithImpl<$Res>
    implements $StoreMemberInfoModelCopyWith<$Res> {
  _$StoreMemberInfoModelCopyWithImpl(this._self, this._then);

  final StoreMemberInfoModel _self;
  final $Res Function(StoreMemberInfoModel) _then;

/// Create a copy of StoreMemberInfoModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? role = null,}) {
  return _then(_self.copyWith(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,
  ));
}

}


/// Adds pattern-matching-related methods to [StoreMemberInfoModel].
extension StoreMemberInfoModelPatterns on StoreMemberInfoModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoreMemberInfoModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoreMemberInfoModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoreMemberInfoModel value)  $default,){
final _that = this;
switch (_that) {
case _StoreMemberInfoModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoreMemberInfoModel value)?  $default,){
final _that = this;
switch (_that) {
case _StoreMemberInfoModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UserRole role)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoreMemberInfoModel() when $default != null:
return $default(_that.role);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UserRole role)  $default,) {final _that = this;
switch (_that) {
case _StoreMemberInfoModel():
return $default(_that.role);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UserRole role)?  $default,) {final _that = this;
switch (_that) {
case _StoreMemberInfoModel() when $default != null:
return $default(_that.role);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StoreMemberInfoModel extends StoreMemberInfoModel {
  const _StoreMemberInfoModel({required this.role}): super._();
  factory _StoreMemberInfoModel.fromJson(Map<String, dynamic> json) => _$StoreMemberInfoModelFromJson(json);

@override final  UserRole role;

/// Create a copy of StoreMemberInfoModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoreMemberInfoModelCopyWith<_StoreMemberInfoModel> get copyWith => __$StoreMemberInfoModelCopyWithImpl<_StoreMemberInfoModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StoreMemberInfoModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoreMemberInfoModel&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role);

@override
String toString() {
  return 'StoreMemberInfoModel(role: $role)';
}


}

/// @nodoc
abstract mixin class _$StoreMemberInfoModelCopyWith<$Res> implements $StoreMemberInfoModelCopyWith<$Res> {
  factory _$StoreMemberInfoModelCopyWith(_StoreMemberInfoModel value, $Res Function(_StoreMemberInfoModel) _then) = __$StoreMemberInfoModelCopyWithImpl;
@override @useResult
$Res call({
 UserRole role
});




}
/// @nodoc
class __$StoreMemberInfoModelCopyWithImpl<$Res>
    implements _$StoreMemberInfoModelCopyWith<$Res> {
  __$StoreMemberInfoModelCopyWithImpl(this._self, this._then);

  final _StoreMemberInfoModel _self;
  final $Res Function(_StoreMemberInfoModel) _then;

/// Create a copy of StoreMemberInfoModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? role = null,}) {
  return _then(_StoreMemberInfoModel(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,
  ));
}


}

// dart format on
