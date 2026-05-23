// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Store {

 String get id; String get name; String get address; String get addressDetail; String get addressGuide; List<StoreMemberInfo> get memberInfos; List<StoreMemberInfo> get waitingMemberInfos; List<SpaceOption> get spaceOptions; InviteInfo? get inviteInfo; String? get bankName; String? get bankAccountNumber; String? get bankAccountHolder; int? get paymentDeadlineMinutes; String? get infoNotes; String? get cautionNotes;
/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoreCopyWith<Store> get copyWith => _$StoreCopyWithImpl<Store>(this as Store, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Store&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.addressDetail, addressDetail) || other.addressDetail == addressDetail)&&(identical(other.addressGuide, addressGuide) || other.addressGuide == addressGuide)&&const DeepCollectionEquality().equals(other.memberInfos, memberInfos)&&const DeepCollectionEquality().equals(other.waitingMemberInfos, waitingMemberInfos)&&const DeepCollectionEquality().equals(other.spaceOptions, spaceOptions)&&(identical(other.inviteInfo, inviteInfo) || other.inviteInfo == inviteInfo)&&(identical(other.bankName, bankName) || other.bankName == bankName)&&(identical(other.bankAccountNumber, bankAccountNumber) || other.bankAccountNumber == bankAccountNumber)&&(identical(other.bankAccountHolder, bankAccountHolder) || other.bankAccountHolder == bankAccountHolder)&&(identical(other.paymentDeadlineMinutes, paymentDeadlineMinutes) || other.paymentDeadlineMinutes == paymentDeadlineMinutes)&&(identical(other.infoNotes, infoNotes) || other.infoNotes == infoNotes)&&(identical(other.cautionNotes, cautionNotes) || other.cautionNotes == cautionNotes));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,address,addressDetail,addressGuide,const DeepCollectionEquality().hash(memberInfos),const DeepCollectionEquality().hash(waitingMemberInfos),const DeepCollectionEquality().hash(spaceOptions),inviteInfo,bankName,bankAccountNumber,bankAccountHolder,paymentDeadlineMinutes,infoNotes,cautionNotes);

@override
String toString() {
  return 'Store(id: $id, name: $name, address: $address, addressDetail: $addressDetail, addressGuide: $addressGuide, memberInfos: $memberInfos, waitingMemberInfos: $waitingMemberInfos, spaceOptions: $spaceOptions, inviteInfo: $inviteInfo, bankName: $bankName, bankAccountNumber: $bankAccountNumber, bankAccountHolder: $bankAccountHolder, paymentDeadlineMinutes: $paymentDeadlineMinutes, infoNotes: $infoNotes, cautionNotes: $cautionNotes)';
}


}

/// @nodoc
abstract mixin class $StoreCopyWith<$Res>  {
  factory $StoreCopyWith(Store value, $Res Function(Store) _then) = _$StoreCopyWithImpl;
@useResult
$Res call({
 String id, String name, String address, String addressDetail, String addressGuide, List<StoreMemberInfo> memberInfos, List<StoreMemberInfo> waitingMemberInfos, List<SpaceOption> spaceOptions, InviteInfo? inviteInfo, String? bankName, String? bankAccountNumber, String? bankAccountHolder, int? paymentDeadlineMinutes, String? infoNotes, String? cautionNotes
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? address = null,Object? addressDetail = null,Object? addressGuide = null,Object? memberInfos = null,Object? waitingMemberInfos = null,Object? spaceOptions = null,Object? inviteInfo = freezed,Object? bankName = freezed,Object? bankAccountNumber = freezed,Object? bankAccountHolder = freezed,Object? paymentDeadlineMinutes = freezed,Object? infoNotes = freezed,Object? cautionNotes = freezed,}) {
  return _then(_self.copyWith(
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
as String?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String address,  String addressDetail,  String addressGuide,  List<StoreMemberInfo> memberInfos,  List<StoreMemberInfo> waitingMemberInfos,  List<SpaceOption> spaceOptions,  InviteInfo? inviteInfo,  String? bankName,  String? bankAccountNumber,  String? bankAccountHolder,  int? paymentDeadlineMinutes,  String? infoNotes,  String? cautionNotes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Store() when $default != null:
return $default(_that.id,_that.name,_that.address,_that.addressDetail,_that.addressGuide,_that.memberInfos,_that.waitingMemberInfos,_that.spaceOptions,_that.inviteInfo,_that.bankName,_that.bankAccountNumber,_that.bankAccountHolder,_that.paymentDeadlineMinutes,_that.infoNotes,_that.cautionNotes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String address,  String addressDetail,  String addressGuide,  List<StoreMemberInfo> memberInfos,  List<StoreMemberInfo> waitingMemberInfos,  List<SpaceOption> spaceOptions,  InviteInfo? inviteInfo,  String? bankName,  String? bankAccountNumber,  String? bankAccountHolder,  int? paymentDeadlineMinutes,  String? infoNotes,  String? cautionNotes)  $default,) {final _that = this;
switch (_that) {
case _Store():
return $default(_that.id,_that.name,_that.address,_that.addressDetail,_that.addressGuide,_that.memberInfos,_that.waitingMemberInfos,_that.spaceOptions,_that.inviteInfo,_that.bankName,_that.bankAccountNumber,_that.bankAccountHolder,_that.paymentDeadlineMinutes,_that.infoNotes,_that.cautionNotes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String address,  String addressDetail,  String addressGuide,  List<StoreMemberInfo> memberInfos,  List<StoreMemberInfo> waitingMemberInfos,  List<SpaceOption> spaceOptions,  InviteInfo? inviteInfo,  String? bankName,  String? bankAccountNumber,  String? bankAccountHolder,  int? paymentDeadlineMinutes,  String? infoNotes,  String? cautionNotes)?  $default,) {final _that = this;
switch (_that) {
case _Store() when $default != null:
return $default(_that.id,_that.name,_that.address,_that.addressDetail,_that.addressGuide,_that.memberInfos,_that.waitingMemberInfos,_that.spaceOptions,_that.inviteInfo,_that.bankName,_that.bankAccountNumber,_that.bankAccountHolder,_that.paymentDeadlineMinutes,_that.infoNotes,_that.cautionNotes);case _:
  return null;

}
}

}

/// @nodoc


class _Store extends Store {
  const _Store({required this.id, required this.name, required this.address, required this.addressDetail, required this.addressGuide, required final  List<StoreMemberInfo> memberInfos, required final  List<StoreMemberInfo> waitingMemberInfos, required final  List<SpaceOption> spaceOptions, required this.inviteInfo, this.bankName, this.bankAccountNumber, this.bankAccountHolder, this.paymentDeadlineMinutes, this.infoNotes, this.cautionNotes}): _memberInfos = memberInfos,_waitingMemberInfos = waitingMemberInfos,_spaceOptions = spaceOptions,super._();
  

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

/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoreCopyWith<_Store> get copyWith => __$StoreCopyWithImpl<_Store>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Store&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.addressDetail, addressDetail) || other.addressDetail == addressDetail)&&(identical(other.addressGuide, addressGuide) || other.addressGuide == addressGuide)&&const DeepCollectionEquality().equals(other._memberInfos, _memberInfos)&&const DeepCollectionEquality().equals(other._waitingMemberInfos, _waitingMemberInfos)&&const DeepCollectionEquality().equals(other._spaceOptions, _spaceOptions)&&(identical(other.inviteInfo, inviteInfo) || other.inviteInfo == inviteInfo)&&(identical(other.bankName, bankName) || other.bankName == bankName)&&(identical(other.bankAccountNumber, bankAccountNumber) || other.bankAccountNumber == bankAccountNumber)&&(identical(other.bankAccountHolder, bankAccountHolder) || other.bankAccountHolder == bankAccountHolder)&&(identical(other.paymentDeadlineMinutes, paymentDeadlineMinutes) || other.paymentDeadlineMinutes == paymentDeadlineMinutes)&&(identical(other.infoNotes, infoNotes) || other.infoNotes == infoNotes)&&(identical(other.cautionNotes, cautionNotes) || other.cautionNotes == cautionNotes));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,address,addressDetail,addressGuide,const DeepCollectionEquality().hash(_memberInfos),const DeepCollectionEquality().hash(_waitingMemberInfos),const DeepCollectionEquality().hash(_spaceOptions),inviteInfo,bankName,bankAccountNumber,bankAccountHolder,paymentDeadlineMinutes,infoNotes,cautionNotes);

@override
String toString() {
  return 'Store(id: $id, name: $name, address: $address, addressDetail: $addressDetail, addressGuide: $addressGuide, memberInfos: $memberInfos, waitingMemberInfos: $waitingMemberInfos, spaceOptions: $spaceOptions, inviteInfo: $inviteInfo, bankName: $bankName, bankAccountNumber: $bankAccountNumber, bankAccountHolder: $bankAccountHolder, paymentDeadlineMinutes: $paymentDeadlineMinutes, infoNotes: $infoNotes, cautionNotes: $cautionNotes)';
}


}

/// @nodoc
abstract mixin class _$StoreCopyWith<$Res> implements $StoreCopyWith<$Res> {
  factory _$StoreCopyWith(_Store value, $Res Function(_Store) _then) = __$StoreCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String address, String addressDetail, String addressGuide, List<StoreMemberInfo> memberInfos, List<StoreMemberInfo> waitingMemberInfos, List<SpaceOption> spaceOptions, InviteInfo? inviteInfo, String? bankName, String? bankAccountNumber, String? bankAccountHolder, int? paymentDeadlineMinutes, String? infoNotes, String? cautionNotes
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? address = null,Object? addressDetail = null,Object? addressGuide = null,Object? memberInfos = null,Object? waitingMemberInfos = null,Object? spaceOptions = null,Object? inviteInfo = freezed,Object? bankName = freezed,Object? bankAccountNumber = freezed,Object? bankAccountHolder = freezed,Object? paymentDeadlineMinutes = freezed,Object? infoNotes = freezed,Object? cautionNotes = freezed,}) {
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
as String?,
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
