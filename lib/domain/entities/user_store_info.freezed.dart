// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_store_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserStoreInfo {

 String get id;/// 점포 이름(관리자가 정한 이름)의 캐시. 점포 이름이 바뀌면 멤버 모두에게 동기화된다 (#26)
 String get name; UserRole get role; StoreColor get color; String get memo;/// 점포 별명. 없으면 null이며 화면에는 [name]이 보인다 (CONTEXT.md "점포 별명")
 String? get alias;/// 가입을 신청했지만 아직 관리자가 승인하지 않은 점포.
/// 멤버가 아니라 Rules가 점포·예약 읽기를 거부하므로 구독하면 안 된다.
 bool get isPending;/// 점포 삭제로 삭제 예정 점포가 된 시각(서버 시각). 점포 복구를 하면 지워진다 (ADR-0007)
 DateTime? get deletedAt;
/// Create a copy of UserStoreInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserStoreInfoCopyWith<UserStoreInfo> get copyWith => _$UserStoreInfoCopyWithImpl<UserStoreInfo>(this as UserStoreInfo, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UserStoreInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserStoreInfo&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.color, _this.color) || other.color == _this.color)&&(identical(other.memo, _this.memo) || other.memo == _this.memo)&&(identical(other.alias, _this.alias) || other.alias == _this.alias)&&(identical(other.isPending, _this.isPending) || other.isPending == _this.isPending)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt));
}


@override
int get hashCode {
  final _this = this as UserStoreInfo;
  return Object.hash(runtimeType,_this.id,_this.name,_this.role,_this.color,_this.memo,_this.alias,_this.isPending,_this.deletedAt);
}

@override
String toString() {
  final _this = this as UserStoreInfo;
  return 'UserStoreInfo(id: ${_this.id}, name: ${_this.name}, role: ${_this.role}, color: ${_this.color}, memo: ${_this.memo}, alias: ${_this.alias}, isPending: ${_this.isPending}, deletedAt: ${_this.deletedAt})';
}


}

/// @nodoc
abstract mixin class $UserStoreInfoCopyWith<$Res>  {
  factory $UserStoreInfoCopyWith(UserStoreInfo value, $Res Function(UserStoreInfo) _then) = _$UserStoreInfoCopyWithImpl;
@useResult
$Res call({
 String id, String name, UserRole role, StoreColor color, String memo, String? alias, bool isPending, DateTime? deletedAt
});




}
/// @nodoc
class _$UserStoreInfoCopyWithImpl<$Res>
    implements $UserStoreInfoCopyWith<$Res> {
  _$UserStoreInfoCopyWithImpl(this._self, this._then);

  final UserStoreInfo _self;
  final $Res Function(UserStoreInfo) _then;

/// Create a copy of UserStoreInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? role = null,Object? color = null,Object? memo = null,Object? alias = freezed,Object? isPending = null,Object? deletedAt = freezed,}) {
  return _then(UserStoreInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as StoreColor,memo: null == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String,alias: freezed == alias ? _self.alias : alias // ignore: cast_nullable_to_non_nullable
as String?,isPending: null == isPending ? _self.isPending : isPending // ignore: cast_nullable_to_non_nullable
as bool,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserStoreInfo].
extension UserStoreInfoPatterns on UserStoreInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserStoreInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserStoreInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserStoreInfo value)  $default,){
final _that = this;
switch (_that) {
case _UserStoreInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserStoreInfo value)?  $default,){
final _that = this;
switch (_that) {
case _UserStoreInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  UserRole role,  StoreColor color,  String memo,  String? alias,  bool isPending,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserStoreInfo() when $default != null:
return $default(_that.id,_that.name,_that.role,_that.color,_that.memo,_that.alias,_that.isPending,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  UserRole role,  StoreColor color,  String memo,  String? alias,  bool isPending,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _UserStoreInfo():
return $default(_that.id,_that.name,_that.role,_that.color,_that.memo,_that.alias,_that.isPending,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  UserRole role,  StoreColor color,  String memo,  String? alias,  bool isPending,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _UserStoreInfo() when $default != null:
return $default(_that.id,_that.name,_that.role,_that.color,_that.memo,_that.alias,_that.isPending,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _UserStoreInfo extends UserStoreInfo {
  const _UserStoreInfo({required this.id, required this.name, required this.role, required this.color, required this.memo, this.alias, this.isPending = false, this.deletedAt}): super._();
  

@override final  String id;
/// 점포 이름(관리자가 정한 이름)의 캐시. 점포 이름이 바뀌면 멤버 모두에게 동기화된다 (#26)
@override final  String name;
@override final  UserRole role;
@override final  StoreColor color;
@override final  String memo;
/// 점포 별명. 없으면 null이며 화면에는 [name]이 보인다 (CONTEXT.md "점포 별명")
@override final  String? alias;
/// 가입을 신청했지만 아직 관리자가 승인하지 않은 점포.
/// 멤버가 아니라 Rules가 점포·예약 읽기를 거부하므로 구독하면 안 된다.
@override@JsonKey() final  bool isPending;
/// 점포 삭제로 삭제 예정 점포가 된 시각(서버 시각). 점포 복구를 하면 지워진다 (ADR-0007)
@override final  DateTime? deletedAt;

/// Create a copy of UserStoreInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserStoreInfoCopyWith<_UserStoreInfo> get copyWith => __$UserStoreInfoCopyWithImpl<_UserStoreInfo>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserStoreInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.role, role) || other.role == role)&&(identical(other.color, color) || other.color == color)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.alias, alias) || other.alias == alias)&&(identical(other.isPending, isPending) || other.isPending == isPending)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,role,color,memo,alias,isPending,deletedAt);
}

@override
String toString() {
    return 'UserStoreInfo(id: $id, name: $name, role: $role, color: $color, memo: $memo, alias: $alias, isPending: $isPending, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$UserStoreInfoCopyWith<$Res> implements $UserStoreInfoCopyWith<$Res> {
  factory _$UserStoreInfoCopyWith(_UserStoreInfo value, $Res Function(_UserStoreInfo) _then) = __$UserStoreInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, UserRole role, StoreColor color, String memo, String? alias, bool isPending, DateTime? deletedAt
});




}
/// @nodoc
class __$UserStoreInfoCopyWithImpl<$Res>
    implements _$UserStoreInfoCopyWith<$Res> {
  __$UserStoreInfoCopyWithImpl(this._self, this._then);

  final _UserStoreInfo _self;
  final $Res Function(_UserStoreInfo) _then;

/// Create a copy of UserStoreInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? role = null,Object? color = null,Object? memo = null,Object? alias = freezed,Object? isPending = null,Object? deletedAt = freezed,}) {
  return _then(_UserStoreInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as StoreColor,memo: null == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String,alias: freezed == alias ? _self.alias : alias // ignore: cast_nullable_to_non_nullable
as String?,isPending: null == isPending ? _self.isPending : isPending // ignore: cast_nullable_to_non_nullable
as bool,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
