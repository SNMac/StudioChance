// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_store_info_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserStoreInfoModel {

 String get name; UserRole get role; StoreColor get color; String get memo;/// 승인 전이면 true. 승인할 때 필드를 지우므로 없으면 승인된 점포다.
 bool get isPending;
/// Create a copy of UserStoreInfoModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserStoreInfoModelCopyWith<UserStoreInfoModel> get copyWith => _$UserStoreInfoModelCopyWithImpl<UserStoreInfoModel>(this as UserStoreInfoModel, _$identity);

  /// Serializes this UserStoreInfoModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UserStoreInfoModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserStoreInfoModel&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.color, _this.color) || other.color == _this.color)&&(identical(other.memo, _this.memo) || other.memo == _this.memo)&&(identical(other.isPending, _this.isPending) || other.isPending == _this.isPending));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UserStoreInfoModel;
  return Object.hash(runtimeType,_this.name,_this.role,_this.color,_this.memo,_this.isPending);
}

@override
String toString() {
  final _this = this as UserStoreInfoModel;
  return 'UserStoreInfoModel(name: ${_this.name}, role: ${_this.role}, color: ${_this.color}, memo: ${_this.memo}, isPending: ${_this.isPending})';
}


}

/// @nodoc
abstract mixin class $UserStoreInfoModelCopyWith<$Res>  {
  factory $UserStoreInfoModelCopyWith(UserStoreInfoModel value, $Res Function(UserStoreInfoModel) _then) = _$UserStoreInfoModelCopyWithImpl;
@useResult
$Res call({
 String name, UserRole role, StoreColor color, String memo, bool isPending
});




}
/// @nodoc
class _$UserStoreInfoModelCopyWithImpl<$Res>
    implements $UserStoreInfoModelCopyWith<$Res> {
  _$UserStoreInfoModelCopyWithImpl(this._self, this._then);

  final UserStoreInfoModel _self;
  final $Res Function(UserStoreInfoModel) _then;

/// Create a copy of UserStoreInfoModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? role = null,Object? color = null,Object? memo = null,Object? isPending = null,}) {
  return _then(UserStoreInfoModel(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as StoreColor,memo: null == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String,isPending: null == isPending ? _self.isPending : isPending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UserStoreInfoModel].
extension UserStoreInfoModelPatterns on UserStoreInfoModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserStoreInfoModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserStoreInfoModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserStoreInfoModel value)  $default,){
final _that = this;
switch (_that) {
case _UserStoreInfoModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserStoreInfoModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserStoreInfoModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  UserRole role,  StoreColor color,  String memo,  bool isPending)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserStoreInfoModel() when $default != null:
return $default(_that.name,_that.role,_that.color,_that.memo,_that.isPending);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  UserRole role,  StoreColor color,  String memo,  bool isPending)  $default,) {final _that = this;
switch (_that) {
case _UserStoreInfoModel():
return $default(_that.name,_that.role,_that.color,_that.memo,_that.isPending);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  UserRole role,  StoreColor color,  String memo,  bool isPending)?  $default,) {final _that = this;
switch (_that) {
case _UserStoreInfoModel() when $default != null:
return $default(_that.name,_that.role,_that.color,_that.memo,_that.isPending);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserStoreInfoModel extends UserStoreInfoModel {
  const _UserStoreInfoModel({required this.name, required this.role, required this.color, required this.memo, this.isPending = false}): super._();
  factory _UserStoreInfoModel.fromJson(Map<String, dynamic> json) => _$UserStoreInfoModelFromJson(json);

@override final  String name;
@override final  UserRole role;
@override final  StoreColor color;
@override final  String memo;
/// 승인 전이면 true. 승인할 때 필드를 지우므로 없으면 승인된 점포다.
@override@JsonKey() final  bool isPending;

/// Create a copy of UserStoreInfoModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserStoreInfoModelCopyWith<_UserStoreInfoModel> get copyWith => __$UserStoreInfoModelCopyWithImpl<_UserStoreInfoModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserStoreInfoModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserStoreInfoModel&&(identical(other.name, name) || other.name == name)&&(identical(other.role, role) || other.role == role)&&(identical(other.color, color) || other.color == color)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.isPending, isPending) || other.isPending == isPending));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,role,color,memo,isPending);
}

@override
String toString() {
    return 'UserStoreInfoModel(name: $name, role: $role, color: $color, memo: $memo, isPending: $isPending)';
}


}

/// @nodoc
abstract mixin class _$UserStoreInfoModelCopyWith<$Res> implements $UserStoreInfoModelCopyWith<$Res> {
  factory _$UserStoreInfoModelCopyWith(_UserStoreInfoModel value, $Res Function(_UserStoreInfoModel) _then) = __$UserStoreInfoModelCopyWithImpl;
@override @useResult
$Res call({
 String name, UserRole role, StoreColor color, String memo, bool isPending
});




}
/// @nodoc
class __$UserStoreInfoModelCopyWithImpl<$Res>
    implements _$UserStoreInfoModelCopyWith<$Res> {
  __$UserStoreInfoModelCopyWithImpl(this._self, this._then);

  final _UserStoreInfoModel _self;
  final $Res Function(_UserStoreInfoModel) _then;

/// Create a copy of UserStoreInfoModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? role = null,Object? color = null,Object? memo = null,Object? isPending = null,}) {
  return _then(_UserStoreInfoModel(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as StoreColor,memo: null == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String,isPending: null == isPending ? _self.isPending : isPending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
