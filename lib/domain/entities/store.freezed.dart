// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Store {

 String get id; String get name; String get address; String get addressDetail; String get addressGuide; List<StoreMemberInfo> get memberInfos; List<StoreMemberInfo> get waitingMemberInfos; List<SpaceOption> get spaceOptions; InviteInfo? get inviteInfo; String? get bankName; String? get bankAccountNumber; String? get bankAccountHolder; int? get paymentDeadlineMinutes; String? get infoNotes; String? get cautionNotes;/// 점포 삭제로 삭제 예정 점포가 된 시각(서버 시각). 없으면 삭제 예정이 아니다 (ADR-0007)
 DateTime? get deletedAt;
/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoreCopyWith<Store> get copyWith => _$StoreCopyWithImpl<Store>(this as Store, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Store;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Store&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.addressDetail, _this.addressDetail) || other.addressDetail == _this.addressDetail)&&(identical(other.addressGuide, _this.addressGuide) || other.addressGuide == _this.addressGuide)&&const DeepCollectionEquality().equals(other.memberInfos, _this.memberInfos)&&const DeepCollectionEquality().equals(other.waitingMemberInfos, _this.waitingMemberInfos)&&const DeepCollectionEquality().equals(other.spaceOptions, _this.spaceOptions)&&(identical(other.inviteInfo, _this.inviteInfo) || other.inviteInfo == _this.inviteInfo)&&(identical(other.bankName, _this.bankName) || other.bankName == _this.bankName)&&(identical(other.bankAccountNumber, _this.bankAccountNumber) || other.bankAccountNumber == _this.bankAccountNumber)&&(identical(other.bankAccountHolder, _this.bankAccountHolder) || other.bankAccountHolder == _this.bankAccountHolder)&&(identical(other.paymentDeadlineMinutes, _this.paymentDeadlineMinutes) || other.paymentDeadlineMinutes == _this.paymentDeadlineMinutes)&&(identical(other.infoNotes, _this.infoNotes) || other.infoNotes == _this.infoNotes)&&(identical(other.cautionNotes, _this.cautionNotes) || other.cautionNotes == _this.cautionNotes)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt));
}


@override
int get hashCode {
  final _this = this as Store;
  return Object.hash(runtimeType,_this.id,_this.name,_this.address,_this.addressDetail,_this.addressGuide,const DeepCollectionEquality().hash(_this.memberInfos),const DeepCollectionEquality().hash(_this.waitingMemberInfos),const DeepCollectionEquality().hash(_this.spaceOptions),_this.inviteInfo,_this.bankName,_this.bankAccountNumber,_this.bankAccountHolder,_this.paymentDeadlineMinutes,_this.infoNotes,_this.cautionNotes,_this.deletedAt);
}

@override
String toString() {
  final _this = this as Store;
  return 'Store(id: ${_this.id}, name: ${_this.name}, address: ${_this.address}, addressDetail: ${_this.addressDetail}, addressGuide: ${_this.addressGuide}, memberInfos: ${_this.memberInfos}, waitingMemberInfos: ${_this.waitingMemberInfos}, spaceOptions: ${_this.spaceOptions}, inviteInfo: ${_this.inviteInfo}, bankName: ${_this.bankName}, bankAccountNumber: ${_this.bankAccountNumber}, bankAccountHolder: ${_this.bankAccountHolder}, paymentDeadlineMinutes: ${_this.paymentDeadlineMinutes}, infoNotes: ${_this.infoNotes}, cautionNotes: ${_this.cautionNotes}, deletedAt: ${_this.deletedAt})';
}


}

/// @nodoc
abstract mixin class $StoreCopyWith<$Res>  {
  factory $StoreCopyWith(Store value, $Res Function(Store) _then) = _$StoreCopyWithImpl;
@useResult
$Res call({
 String id, String name, String address, String addressDetail, String addressGuide, List<StoreMemberInfo> memberInfos, List<StoreMemberInfo> waitingMemberInfos, List<SpaceOption> spaceOptions, InviteInfo? inviteInfo, String? bankName, String? bankAccountNumber, String? bankAccountHolder, int? paymentDeadlineMinutes, String? infoNotes, String? cautionNotes, DateTime? deletedAt
});


$InviteInfoCopyWith<$Res>? get inviteInfo;

}
/// @nodoc
class _$StoreCopyWithImpl<$Res>
    implements $StoreCopyWith<$Res> {
  _$StoreCopyWithImpl(this._self, this._then);

  final Store _self;
  final $Res Function(Store) _then;

/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? address = null,Object? addressDetail = null,Object? addressGuide = null,Object? memberInfos = null,Object? waitingMemberInfos = null,Object? spaceOptions = null,Object? inviteInfo = freezed,Object? bankName = freezed,Object? bankAccountNumber = freezed,Object? bankAccountHolder = freezed,Object? paymentDeadlineMinutes = freezed,Object? infoNotes = freezed,Object? cautionNotes = freezed,Object? deletedAt = freezed,}) {
  return _then(Store(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,addressDetail: null == addressDetail ? _self.addressDetail : addressDetail // ignore: cast_nullable_to_non_nullable
as String,addressGuide: null == addressGuide ? _self.addressGuide : addressGuide // ignore: cast_nullable_to_non_nullable
as String,memberInfos: null == memberInfos ? _self.memberInfos : memberInfos // ignore: cast_nullable_to_non_nullable
as List<StoreMemberInfo>,waitingMemberInfos: null == waitingMemberInfos ? _self.waitingMemberInfos : waitingMemberInfos // ignore: cast_nullable_to_non_nullable
as List<StoreMemberInfo>,spaceOptions: null == spaceOptions ? _self.spaceOptions : spaceOptions // ignore: cast_nullable_to_non_nullable
as List<SpaceOption>,inviteInfo: freezed == inviteInfo ? _self.inviteInfo : inviteInfo // ignore: cast_nullable_to_non_nullable
as InviteInfo?,bankName: freezed == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String?,bankAccountNumber: freezed == bankAccountNumber ? _self.bankAccountNumber : bankAccountNumber // ignore: cast_nullable_to_non_nullable
as String?,bankAccountHolder: freezed == bankAccountHolder ? _self.bankAccountHolder : bankAccountHolder // ignore: cast_nullable_to_non_nullable
as String?,paymentDeadlineMinutes: freezed == paymentDeadlineMinutes ? _self.paymentDeadlineMinutes : paymentDeadlineMinutes // ignore: cast_nullable_to_non_nullable
as int?,infoNotes: freezed == infoNotes ? _self.infoNotes : infoNotes // ignore: cast_nullable_to_non_nullable
as String?,cautionNotes: freezed == cautionNotes ? _self.cautionNotes : cautionNotes // ignore: cast_nullable_to_non_nullable
as String?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InviteInfoCopyWith<$Res>? get inviteInfo {
    if (_self.inviteInfo == null) {
    return null;
  }

  return $InviteInfoCopyWith<$Res>(_self.inviteInfo!, (value) {
    return _then(_self.copyWith(inviteInfo: value));
  });
}
}


/// Adds pattern-matching-related methods to [Store].
extension StorePatterns on Store {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Store value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Store() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Store value)  $default,){
final _that = this;
switch (_that) {
case _Store():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Store value)?  $default,){
final _that = this;
switch (_that) {
case _Store() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String address,  String addressDetail,  String addressGuide,  List<StoreMemberInfo> memberInfos,  List<StoreMemberInfo> waitingMemberInfos,  List<SpaceOption> spaceOptions,  InviteInfo? inviteInfo,  String? bankName,  String? bankAccountNumber,  String? bankAccountHolder,  int? paymentDeadlineMinutes,  String? infoNotes,  String? cautionNotes,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Store() when $default != null:
return $default(_that.id,_that.name,_that.address,_that.addressDetail,_that.addressGuide,_that.memberInfos,_that.waitingMemberInfos,_that.spaceOptions,_that.inviteInfo,_that.bankName,_that.bankAccountNumber,_that.bankAccountHolder,_that.paymentDeadlineMinutes,_that.infoNotes,_that.cautionNotes,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String address,  String addressDetail,  String addressGuide,  List<StoreMemberInfo> memberInfos,  List<StoreMemberInfo> waitingMemberInfos,  List<SpaceOption> spaceOptions,  InviteInfo? inviteInfo,  String? bankName,  String? bankAccountNumber,  String? bankAccountHolder,  int? paymentDeadlineMinutes,  String? infoNotes,  String? cautionNotes,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _Store():
return $default(_that.id,_that.name,_that.address,_that.addressDetail,_that.addressGuide,_that.memberInfos,_that.waitingMemberInfos,_that.spaceOptions,_that.inviteInfo,_that.bankName,_that.bankAccountNumber,_that.bankAccountHolder,_that.paymentDeadlineMinutes,_that.infoNotes,_that.cautionNotes,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String address,  String addressDetail,  String addressGuide,  List<StoreMemberInfo> memberInfos,  List<StoreMemberInfo> waitingMemberInfos,  List<SpaceOption> spaceOptions,  InviteInfo? inviteInfo,  String? bankName,  String? bankAccountNumber,  String? bankAccountHolder,  int? paymentDeadlineMinutes,  String? infoNotes,  String? cautionNotes,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _Store() when $default != null:
return $default(_that.id,_that.name,_that.address,_that.addressDetail,_that.addressGuide,_that.memberInfos,_that.waitingMemberInfos,_that.spaceOptions,_that.inviteInfo,_that.bankName,_that.bankAccountNumber,_that.bankAccountHolder,_that.paymentDeadlineMinutes,_that.infoNotes,_that.cautionNotes,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Store extends Store {
  const _Store({required this.id, required this.name, required this.address, required this.addressDetail, required this.addressGuide, required  List<StoreMemberInfo> memberInfos, required  List<StoreMemberInfo> waitingMemberInfos, required  List<SpaceOption> spaceOptions, required this.inviteInfo, this.bankName, this.bankAccountNumber, this.bankAccountHolder, this.paymentDeadlineMinutes, this.infoNotes, this.cautionNotes, this.deletedAt}): _memberInfos = memberInfos,_waitingMemberInfos = waitingMemberInfos,_spaceOptions = spaceOptions,super._();
  

@override final  String id;
@override final  String name;
@override final  String address;
@override final  String addressDetail;
@override final  String addressGuide;
 final  List<StoreMemberInfo> _memberInfos;
@override List<StoreMemberInfo> get memberInfos {
  if (_memberInfos is EqualUnmodifiableListView) return _memberInfos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_memberInfos);
}

 final  List<StoreMemberInfo> _waitingMemberInfos;
@override List<StoreMemberInfo> get waitingMemberInfos {
  if (_waitingMemberInfos is EqualUnmodifiableListView) return _waitingMemberInfos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_waitingMemberInfos);
}

 final  List<SpaceOption> _spaceOptions;
@override List<SpaceOption> get spaceOptions {
  if (_spaceOptions is EqualUnmodifiableListView) return _spaceOptions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_spaceOptions);
}

@override final  InviteInfo? inviteInfo;
@override final  String? bankName;
@override final  String? bankAccountNumber;
@override final  String? bankAccountHolder;
@override final  int? paymentDeadlineMinutes;
@override final  String? infoNotes;
@override final  String? cautionNotes;
/// 점포 삭제로 삭제 예정 점포가 된 시각(서버 시각). 없으면 삭제 예정이 아니다 (ADR-0007)
@override final  DateTime? deletedAt;

/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoreCopyWith<_Store> get copyWith => __$StoreCopyWithImpl<_Store>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Store&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.addressDetail, addressDetail) || other.addressDetail == addressDetail)&&(identical(other.addressGuide, addressGuide) || other.addressGuide == addressGuide)&&const DeepCollectionEquality().equals(other.memberInfos, _memberInfos)&&const DeepCollectionEquality().equals(other.waitingMemberInfos, _waitingMemberInfos)&&const DeepCollectionEquality().equals(other.spaceOptions, _spaceOptions)&&(identical(other.inviteInfo, inviteInfo) || other.inviteInfo == inviteInfo)&&(identical(other.bankName, bankName) || other.bankName == bankName)&&(identical(other.bankAccountNumber, bankAccountNumber) || other.bankAccountNumber == bankAccountNumber)&&(identical(other.bankAccountHolder, bankAccountHolder) || other.bankAccountHolder == bankAccountHolder)&&(identical(other.paymentDeadlineMinutes, paymentDeadlineMinutes) || other.paymentDeadlineMinutes == paymentDeadlineMinutes)&&(identical(other.infoNotes, infoNotes) || other.infoNotes == infoNotes)&&(identical(other.cautionNotes, cautionNotes) || other.cautionNotes == cautionNotes)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,address,addressDetail,addressGuide,const DeepCollectionEquality().hash(_memberInfos),const DeepCollectionEquality().hash(_waitingMemberInfos),const DeepCollectionEquality().hash(_spaceOptions),inviteInfo,bankName,bankAccountNumber,bankAccountHolder,paymentDeadlineMinutes,infoNotes,cautionNotes,deletedAt);
}

@override
String toString() {
    return 'Store(id: $id, name: $name, address: $address, addressDetail: $addressDetail, addressGuide: $addressGuide, memberInfos: $memberInfos, waitingMemberInfos: $waitingMemberInfos, spaceOptions: $spaceOptions, inviteInfo: $inviteInfo, bankName: $bankName, bankAccountNumber: $bankAccountNumber, bankAccountHolder: $bankAccountHolder, paymentDeadlineMinutes: $paymentDeadlineMinutes, infoNotes: $infoNotes, cautionNotes: $cautionNotes, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$StoreCopyWith<$Res> implements $StoreCopyWith<$Res> {
  factory _$StoreCopyWith(_Store value, $Res Function(_Store) _then) = __$StoreCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String address, String addressDetail, String addressGuide, List<StoreMemberInfo> memberInfos, List<StoreMemberInfo> waitingMemberInfos, List<SpaceOption> spaceOptions, InviteInfo? inviteInfo, String? bankName, String? bankAccountNumber, String? bankAccountHolder, int? paymentDeadlineMinutes, String? infoNotes, String? cautionNotes, DateTime? deletedAt
});


@override $InviteInfoCopyWith<$Res>? get inviteInfo;

}
/// @nodoc
class __$StoreCopyWithImpl<$Res>
    implements _$StoreCopyWith<$Res> {
  __$StoreCopyWithImpl(this._self, this._then);

  final _Store _self;
  final $Res Function(_Store) _then;

/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? address = null,Object? addressDetail = null,Object? addressGuide = null,Object? memberInfos = null,Object? waitingMemberInfos = null,Object? spaceOptions = null,Object? inviteInfo = freezed,Object? bankName = freezed,Object? bankAccountNumber = freezed,Object? bankAccountHolder = freezed,Object? paymentDeadlineMinutes = freezed,Object? infoNotes = freezed,Object? cautionNotes = freezed,Object? deletedAt = freezed,}) {
  return _then(_Store(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,addressDetail: null == addressDetail ? _self.addressDetail : addressDetail // ignore: cast_nullable_to_non_nullable
as String,addressGuide: null == addressGuide ? _self.addressGuide : addressGuide // ignore: cast_nullable_to_non_nullable
as String,memberInfos: null == memberInfos ? _self._memberInfos : memberInfos // ignore: cast_nullable_to_non_nullable
as List<StoreMemberInfo>,waitingMemberInfos: null == waitingMemberInfos ? _self._waitingMemberInfos : waitingMemberInfos // ignore: cast_nullable_to_non_nullable
as List<StoreMemberInfo>,spaceOptions: null == spaceOptions ? _self._spaceOptions : spaceOptions // ignore: cast_nullable_to_non_nullable
as List<SpaceOption>,inviteInfo: freezed == inviteInfo ? _self.inviteInfo : inviteInfo // ignore: cast_nullable_to_non_nullable
as InviteInfo?,bankName: freezed == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String?,bankAccountNumber: freezed == bankAccountNumber ? _self.bankAccountNumber : bankAccountNumber // ignore: cast_nullable_to_non_nullable
as String?,bankAccountHolder: freezed == bankAccountHolder ? _self.bankAccountHolder : bankAccountHolder // ignore: cast_nullable_to_non_nullable
as String?,paymentDeadlineMinutes: freezed == paymentDeadlineMinutes ? _self.paymentDeadlineMinutes : paymentDeadlineMinutes // ignore: cast_nullable_to_non_nullable
as int?,infoNotes: freezed == infoNotes ? _self.infoNotes : infoNotes // ignore: cast_nullable_to_non_nullable
as String?,cautionNotes: freezed == cautionNotes ? _self.cautionNotes : cautionNotes // ignore: cast_nullable_to_non_nullable
as String?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InviteInfoCopyWith<$Res>? get inviteInfo {
    if (_self.inviteInfo == null) {
    return null;
  }

  return $InviteInfoCopyWith<$Res>(_self.inviteInfo!, (value) {
    return _then(_self.copyWith(inviteInfo: value));
  });
}
}

// dart format on
