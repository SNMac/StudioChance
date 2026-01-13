// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OnboardingState {

 String get nickname; UserRole get selectedRole;// --- 점포 생성용 필드 (Store 객체 대신 낱개로 관리) ---
 String get storeName; String get storeAddress; String get storeMemo; StoreColor? get selectedStoreColor;// 가격 설정 (기본값 필요 시 factory constructor에서 초기화 가능)
 PriceSetting? get tempPriceSettings;// --- 점포 참가용 필드 ---
 String? get invitedStoreId;
/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingStateCopyWith<OnboardingState> get copyWith => _$OnboardingStateCopyWithImpl<OnboardingState>(this as OnboardingState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingState&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.selectedRole, selectedRole) || other.selectedRole == selectedRole)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.storeAddress, storeAddress) || other.storeAddress == storeAddress)&&(identical(other.storeMemo, storeMemo) || other.storeMemo == storeMemo)&&(identical(other.selectedStoreColor, selectedStoreColor) || other.selectedStoreColor == selectedStoreColor)&&(identical(other.tempPriceSettings, tempPriceSettings) || other.tempPriceSettings == tempPriceSettings)&&(identical(other.invitedStoreId, invitedStoreId) || other.invitedStoreId == invitedStoreId));
}


@override
int get hashCode => Object.hash(runtimeType,nickname,selectedRole,storeName,storeAddress,storeMemo,selectedStoreColor,tempPriceSettings,invitedStoreId);

@override
String toString() {
  return 'OnboardingState(nickname: $nickname, selectedRole: $selectedRole, storeName: $storeName, storeAddress: $storeAddress, storeMemo: $storeMemo, selectedStoreColor: $selectedStoreColor, tempPriceSettings: $tempPriceSettings, invitedStoreId: $invitedStoreId)';
}


}

/// @nodoc
abstract mixin class $OnboardingStateCopyWith<$Res>  {
  factory $OnboardingStateCopyWith(OnboardingState value, $Res Function(OnboardingState) _then) = _$OnboardingStateCopyWithImpl;
@useResult
$Res call({
 String nickname, UserRole selectedRole, String storeName, String storeAddress, String storeMemo, StoreColor? selectedStoreColor, PriceSetting? tempPriceSettings, String? invitedStoreId
});


$PriceSettingCopyWith<$Res>? get tempPriceSettings;

}
/// @nodoc
class _$OnboardingStateCopyWithImpl<$Res>
    implements $OnboardingStateCopyWith<$Res> {
  _$OnboardingStateCopyWithImpl(this._self, this._then);

  final OnboardingState _self;
  final $Res Function(OnboardingState) _then;

/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nickname = null,Object? selectedRole = null,Object? storeName = null,Object? storeAddress = null,Object? storeMemo = null,Object? selectedStoreColor = freezed,Object? tempPriceSettings = freezed,Object? invitedStoreId = freezed,}) {
  return _then(_self.copyWith(
nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,selectedRole: null == selectedRole ? _self.selectedRole : selectedRole // ignore: cast_nullable_to_non_nullable
as UserRole,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,storeAddress: null == storeAddress ? _self.storeAddress : storeAddress // ignore: cast_nullable_to_non_nullable
as String,storeMemo: null == storeMemo ? _self.storeMemo : storeMemo // ignore: cast_nullable_to_non_nullable
as String,selectedStoreColor: freezed == selectedStoreColor ? _self.selectedStoreColor : selectedStoreColor // ignore: cast_nullable_to_non_nullable
as StoreColor?,tempPriceSettings: freezed == tempPriceSettings ? _self.tempPriceSettings : tempPriceSettings // ignore: cast_nullable_to_non_nullable
as PriceSetting?,invitedStoreId: freezed == invitedStoreId ? _self.invitedStoreId : invitedStoreId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceSettingCopyWith<$Res>? get tempPriceSettings {
    if (_self.tempPriceSettings == null) {
    return null;
  }

  return $PriceSettingCopyWith<$Res>(_self.tempPriceSettings!, (value) {
    return _then(_self.copyWith(tempPriceSettings: value));
  });
}
}


/// Adds pattern-matching-related methods to [OnboardingState].
extension OnboardingStatePatterns on OnboardingState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnboardingState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnboardingState value)  $default,){
final _that = this;
switch (_that) {
case _OnboardingState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnboardingState value)?  $default,){
final _that = this;
switch (_that) {
case _OnboardingState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String nickname,  UserRole selectedRole,  String storeName,  String storeAddress,  String storeMemo,  StoreColor? selectedStoreColor,  PriceSetting? tempPriceSettings,  String? invitedStoreId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingState() when $default != null:
return $default(_that.nickname,_that.selectedRole,_that.storeName,_that.storeAddress,_that.storeMemo,_that.selectedStoreColor,_that.tempPriceSettings,_that.invitedStoreId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String nickname,  UserRole selectedRole,  String storeName,  String storeAddress,  String storeMemo,  StoreColor? selectedStoreColor,  PriceSetting? tempPriceSettings,  String? invitedStoreId)  $default,) {final _that = this;
switch (_that) {
case _OnboardingState():
return $default(_that.nickname,_that.selectedRole,_that.storeName,_that.storeAddress,_that.storeMemo,_that.selectedStoreColor,_that.tempPriceSettings,_that.invitedStoreId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String nickname,  UserRole selectedRole,  String storeName,  String storeAddress,  String storeMemo,  StoreColor? selectedStoreColor,  PriceSetting? tempPriceSettings,  String? invitedStoreId)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingState() when $default != null:
return $default(_that.nickname,_that.selectedRole,_that.storeName,_that.storeAddress,_that.storeMemo,_that.selectedStoreColor,_that.tempPriceSettings,_that.invitedStoreId);case _:
  return null;

}
}

}

/// @nodoc


class _OnboardingState extends OnboardingState {
  const _OnboardingState({this.nickname = '', this.selectedRole = UserRole.none, this.storeName = '', this.storeAddress = '', this.storeMemo = '', this.selectedStoreColor, this.tempPriceSettings, this.invitedStoreId}): super._();
  

@override@JsonKey() final  String nickname;
@override@JsonKey() final  UserRole selectedRole;
// --- 점포 생성용 필드 (Store 객체 대신 낱개로 관리) ---
@override@JsonKey() final  String storeName;
@override@JsonKey() final  String storeAddress;
@override@JsonKey() final  String storeMemo;
@override final  StoreColor? selectedStoreColor;
// 가격 설정 (기본값 필요 시 factory constructor에서 초기화 가능)
@override final  PriceSetting? tempPriceSettings;
// --- 점포 참가용 필드 ---
@override final  String? invitedStoreId;

/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingStateCopyWith<_OnboardingState> get copyWith => __$OnboardingStateCopyWithImpl<_OnboardingState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingState&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.selectedRole, selectedRole) || other.selectedRole == selectedRole)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.storeAddress, storeAddress) || other.storeAddress == storeAddress)&&(identical(other.storeMemo, storeMemo) || other.storeMemo == storeMemo)&&(identical(other.selectedStoreColor, selectedStoreColor) || other.selectedStoreColor == selectedStoreColor)&&(identical(other.tempPriceSettings, tempPriceSettings) || other.tempPriceSettings == tempPriceSettings)&&(identical(other.invitedStoreId, invitedStoreId) || other.invitedStoreId == invitedStoreId));
}


@override
int get hashCode => Object.hash(runtimeType,nickname,selectedRole,storeName,storeAddress,storeMemo,selectedStoreColor,tempPriceSettings,invitedStoreId);

@override
String toString() {
  return 'OnboardingState(nickname: $nickname, selectedRole: $selectedRole, storeName: $storeName, storeAddress: $storeAddress, storeMemo: $storeMemo, selectedStoreColor: $selectedStoreColor, tempPriceSettings: $tempPriceSettings, invitedStoreId: $invitedStoreId)';
}


}

/// @nodoc
abstract mixin class _$OnboardingStateCopyWith<$Res> implements $OnboardingStateCopyWith<$Res> {
  factory _$OnboardingStateCopyWith(_OnboardingState value, $Res Function(_OnboardingState) _then) = __$OnboardingStateCopyWithImpl;
@override @useResult
$Res call({
 String nickname, UserRole selectedRole, String storeName, String storeAddress, String storeMemo, StoreColor? selectedStoreColor, PriceSetting? tempPriceSettings, String? invitedStoreId
});


@override $PriceSettingCopyWith<$Res>? get tempPriceSettings;

}
/// @nodoc
class __$OnboardingStateCopyWithImpl<$Res>
    implements _$OnboardingStateCopyWith<$Res> {
  __$OnboardingStateCopyWithImpl(this._self, this._then);

  final _OnboardingState _self;
  final $Res Function(_OnboardingState) _then;

/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nickname = null,Object? selectedRole = null,Object? storeName = null,Object? storeAddress = null,Object? storeMemo = null,Object? selectedStoreColor = freezed,Object? tempPriceSettings = freezed,Object? invitedStoreId = freezed,}) {
  return _then(_OnboardingState(
nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,selectedRole: null == selectedRole ? _self.selectedRole : selectedRole // ignore: cast_nullable_to_non_nullable
as UserRole,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,storeAddress: null == storeAddress ? _self.storeAddress : storeAddress // ignore: cast_nullable_to_non_nullable
as String,storeMemo: null == storeMemo ? _self.storeMemo : storeMemo // ignore: cast_nullable_to_non_nullable
as String,selectedStoreColor: freezed == selectedStoreColor ? _self.selectedStoreColor : selectedStoreColor // ignore: cast_nullable_to_non_nullable
as StoreColor?,tempPriceSettings: freezed == tempPriceSettings ? _self.tempPriceSettings : tempPriceSettings // ignore: cast_nullable_to_non_nullable
as PriceSetting?,invitedStoreId: freezed == invitedStoreId ? _self.invitedStoreId : invitedStoreId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceSettingCopyWith<$Res>? get tempPriceSettings {
    if (_self.tempPriceSettings == null) {
    return null;
  }

  return $PriceSettingCopyWith<$Res>(_self.tempPriceSettings!, (value) {
    return _then(_self.copyWith(tempPriceSettings: value));
  });
}
}

// dart format on
