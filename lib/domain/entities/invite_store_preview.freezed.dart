// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invite_store_preview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InviteStorePreview {

 String get storeId; String get storeName; String get address; String get addressDetail; String get adminName;
/// Create a copy of InviteStorePreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InviteStorePreviewCopyWith<InviteStorePreview> get copyWith => _$InviteStorePreviewCopyWithImpl<InviteStorePreview>(this as InviteStorePreview, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InviteStorePreview&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.address, address) || other.address == address)&&(identical(other.addressDetail, addressDetail) || other.addressDetail == addressDetail)&&(identical(other.adminName, adminName) || other.adminName == adminName));
}


@override
int get hashCode => Object.hash(runtimeType,storeId,storeName,address,addressDetail,adminName);

@override
String toString() {
  return 'InviteStorePreview(storeId: $storeId, storeName: $storeName, address: $address, addressDetail: $addressDetail, adminName: $adminName)';
}


}

/// @nodoc
abstract mixin class $InviteStorePreviewCopyWith<$Res>  {
  factory $InviteStorePreviewCopyWith(InviteStorePreview value, $Res Function(InviteStorePreview) _then) = _$InviteStorePreviewCopyWithImpl;
@useResult
$Res call({
 String storeId, String storeName, String address, String addressDetail, String adminName
});




}
/// @nodoc
class _$InviteStorePreviewCopyWithImpl<$Res>
    implements $InviteStorePreviewCopyWith<$Res> {
  _$InviteStorePreviewCopyWithImpl(this._self, this._then);

  final InviteStorePreview _self;
  final $Res Function(InviteStorePreview) _then;

/// Create a copy of InviteStorePreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? storeId = null,Object? storeName = null,Object? address = null,Object? addressDetail = null,Object? adminName = null,}) {
  return _then(_self.copyWith(
storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,addressDetail: null == addressDetail ? _self.addressDetail : addressDetail // ignore: cast_nullable_to_non_nullable
as String,adminName: null == adminName ? _self.adminName : adminName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [InviteStorePreview].
extension InviteStorePreviewPatterns on InviteStorePreview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InviteStorePreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InviteStorePreview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InviteStorePreview value)  $default,){
final _that = this;
switch (_that) {
case _InviteStorePreview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InviteStorePreview value)?  $default,){
final _that = this;
switch (_that) {
case _InviteStorePreview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String storeId,  String storeName,  String address,  String addressDetail,  String adminName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InviteStorePreview() when $default != null:
return $default(_that.storeId,_that.storeName,_that.address,_that.addressDetail,_that.adminName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String storeId,  String storeName,  String address,  String addressDetail,  String adminName)  $default,) {final _that = this;
switch (_that) {
case _InviteStorePreview():
return $default(_that.storeId,_that.storeName,_that.address,_that.addressDetail,_that.adminName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String storeId,  String storeName,  String address,  String addressDetail,  String adminName)?  $default,) {final _that = this;
switch (_that) {
case _InviteStorePreview() when $default != null:
return $default(_that.storeId,_that.storeName,_that.address,_that.addressDetail,_that.adminName);case _:
  return null;

}
}

}

/// @nodoc


class _InviteStorePreview implements InviteStorePreview {
  const _InviteStorePreview({required this.storeId, required this.storeName, required this.address, required this.addressDetail, required this.adminName});
  

@override final  String storeId;
@override final  String storeName;
@override final  String address;
@override final  String addressDetail;
@override final  String adminName;

/// Create a copy of InviteStorePreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InviteStorePreviewCopyWith<_InviteStorePreview> get copyWith => __$InviteStorePreviewCopyWithImpl<_InviteStorePreview>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InviteStorePreview&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.address, address) || other.address == address)&&(identical(other.addressDetail, addressDetail) || other.addressDetail == addressDetail)&&(identical(other.adminName, adminName) || other.adminName == adminName));
}


@override
int get hashCode => Object.hash(runtimeType,storeId,storeName,address,addressDetail,adminName);

@override
String toString() {
  return 'InviteStorePreview(storeId: $storeId, storeName: $storeName, address: $address, addressDetail: $addressDetail, adminName: $adminName)';
}


}

/// @nodoc
abstract mixin class _$InviteStorePreviewCopyWith<$Res> implements $InviteStorePreviewCopyWith<$Res> {
  factory _$InviteStorePreviewCopyWith(_InviteStorePreview value, $Res Function(_InviteStorePreview) _then) = __$InviteStorePreviewCopyWithImpl;
@override @useResult
$Res call({
 String storeId, String storeName, String address, String addressDetail, String adminName
});




}
/// @nodoc
class __$InviteStorePreviewCopyWithImpl<$Res>
    implements _$InviteStorePreviewCopyWith<$Res> {
  __$InviteStorePreviewCopyWithImpl(this._self, this._then);

  final _InviteStorePreview _self;
  final $Res Function(_InviteStorePreview) _then;

/// Create a copy of InviteStorePreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? storeId = null,Object? storeName = null,Object? address = null,Object? addressDetail = null,Object? adminName = null,}) {
  return _then(_InviteStorePreview(
storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,addressDetail: null == addressDetail ? _self.addressDetail : addressDetail // ignore: cast_nullable_to_non_nullable
as String,adminName: null == adminName ? _self.adminName : adminName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
