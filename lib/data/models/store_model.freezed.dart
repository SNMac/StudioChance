// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StoreModel {

@JsonKey(includeToJson: false) String get id; String get name; String get address; String get addressDetail; String get addressGuide; List<SpaceOptionModel> get spaceOptions; Map<String, StoreMemberInfoModel> get memberById; Map<String, StoreMemberInfoModel> get waitingMemberById; InviteInfoModel? get inviteInfoModel; String? get bankName; String? get bankAccountNumber; String? get bankAccountHolder; int? get paymentDeadlineMinutes; String? get confirmationNotes;
/// Create a copy of StoreModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoreModelCopyWith<StoreModel> get copyWith => _$StoreModelCopyWithImpl<StoreModel>(this as StoreModel, _$identity);

  /// Serializes this StoreModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoreModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.addressDetail, addressDetail) || other.addressDetail == addressDetail)&&(identical(other.addressGuide, addressGuide) || other.addressGuide == addressGuide)&&const DeepCollectionEquality().equals(other.spaceOptions, spaceOptions)&&const DeepCollectionEquality().equals(other.memberById, memberById)&&const DeepCollectionEquality().equals(other.waitingMemberById, waitingMemberById)&&(identical(other.inviteInfoModel, inviteInfoModel) || other.inviteInfoModel == inviteInfoModel)&&(identical(other.bankName, bankName) || other.bankName == bankName)&&(identical(other.bankAccountNumber, bankAccountNumber) || other.bankAccountNumber == bankAccountNumber)&&(identical(other.bankAccountHolder, bankAccountHolder) || other.bankAccountHolder == bankAccountHolder)&&(identical(other.paymentDeadlineMinutes, paymentDeadlineMinutes) || other.paymentDeadlineMinutes == paymentDeadlineMinutes)&&(identical(other.confirmationNotes, confirmationNotes) || other.confirmationNotes == confirmationNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,address,addressDetail,addressGuide,const DeepCollectionEquality().hash(spaceOptions),const DeepCollectionEquality().hash(memberById),const DeepCollectionEquality().hash(waitingMemberById),inviteInfoModel,bankName,bankAccountNumber,bankAccountHolder,paymentDeadlineMinutes,confirmationNotes);

@override
String toString() {
  return 'StoreModel(id: $id, name: $name, address: $address, addressDetail: $addressDetail, addressGuide: $addressGuide, spaceOptions: $spaceOptions, memberById: $memberById, waitingMemberById: $waitingMemberById, inviteInfoModel: $inviteInfoModel, bankName: $bankName, bankAccountNumber: $bankAccountNumber, bankAccountHolder: $bankAccountHolder, paymentDeadlineMinutes: $paymentDeadlineMinutes, confirmationNotes: $confirmationNotes)';
}


}

/// @nodoc
abstract mixin class $StoreModelCopyWith<$Res>  {
  factory $StoreModelCopyWith(StoreModel value, $Res Function(StoreModel) _then) = _$StoreModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) String id, String name, String address, String addressDetail, String addressGuide, List<SpaceOptionModel> spaceOptions, Map<String, StoreMemberInfoModel> memberById, Map<String, StoreMemberInfoModel> waitingMemberById, InviteInfoModel? inviteInfoModel, String? bankName, String? bankAccountNumber, String? bankAccountHolder, int? paymentDeadlineMinutes, String? confirmationNotes
});


$InviteInfoModelCopyWith<$Res>? get inviteInfoModel;

}
/// @nodoc
class _$StoreModelCopyWithImpl<$Res>
    implements $StoreModelCopyWith<$Res> {
  _$StoreModelCopyWithImpl(this._self, this._then);

  final StoreModel _self;
  final $Res Function(StoreModel) _then;

/// Create a copy of StoreModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? address = null,Object? addressDetail = null,Object? addressGuide = null,Object? spaceOptions = null,Object? memberById = null,Object? waitingMemberById = null,Object? inviteInfoModel = freezed,Object? bankName = freezed,Object? bankAccountNumber = freezed,Object? bankAccountHolder = freezed,Object? paymentDeadlineMinutes = freezed,Object? confirmationNotes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,addressDetail: null == addressDetail ? _self.addressDetail : addressDetail // ignore: cast_nullable_to_non_nullable
as String,addressGuide: null == addressGuide ? _self.addressGuide : addressGuide // ignore: cast_nullable_to_non_nullable
as String,spaceOptions: null == spaceOptions ? _self.spaceOptions : spaceOptions // ignore: cast_nullable_to_non_nullable
as List<SpaceOptionModel>,memberById: null == memberById ? _self.memberById : memberById // ignore: cast_nullable_to_non_nullable
as Map<String, StoreMemberInfoModel>,waitingMemberById: null == waitingMemberById ? _self.waitingMemberById : waitingMemberById // ignore: cast_nullable_to_non_nullable
as Map<String, StoreMemberInfoModel>,inviteInfoModel: freezed == inviteInfoModel ? _self.inviteInfoModel : inviteInfoModel // ignore: cast_nullable_to_non_nullable
as InviteInfoModel?,bankName: freezed == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String?,bankAccountNumber: freezed == bankAccountNumber ? _self.bankAccountNumber : bankAccountNumber // ignore: cast_nullable_to_non_nullable
as String?,bankAccountHolder: freezed == bankAccountHolder ? _self.bankAccountHolder : bankAccountHolder // ignore: cast_nullable_to_non_nullable
as String?,paymentDeadlineMinutes: freezed == paymentDeadlineMinutes ? _self.paymentDeadlineMinutes : paymentDeadlineMinutes // ignore: cast_nullable_to_non_nullable
as int?,confirmationNotes: freezed == confirmationNotes ? _self.confirmationNotes : confirmationNotes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of StoreModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InviteInfoModelCopyWith<$Res>? get inviteInfoModel {
    if (_self.inviteInfoModel == null) {
    return null;
  }

  return $InviteInfoModelCopyWith<$Res>(_self.inviteInfoModel!, (value) {
    return _then(_self.copyWith(inviteInfoModel: value));
  });
}
}


/// Adds pattern-matching-related methods to [StoreModel].
extension StoreModelPatterns on StoreModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoreModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoreModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoreModel value)  $default,){
final _that = this;
switch (_that) {
case _StoreModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoreModel value)?  $default,){
final _that = this;
switch (_that) {
case _StoreModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String name,  String address,  String addressDetail,  String addressGuide,  List<SpaceOptionModel> spaceOptions,  Map<String, StoreMemberInfoModel> memberById,  Map<String, StoreMemberInfoModel> waitingMemberById,  InviteInfoModel? inviteInfoModel,  String? bankName,  String? bankAccountNumber,  String? bankAccountHolder,  int? paymentDeadlineMinutes,  String? confirmationNotes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoreModel() when $default != null:
return $default(_that.id,_that.name,_that.address,_that.addressDetail,_that.addressGuide,_that.spaceOptions,_that.memberById,_that.waitingMemberById,_that.inviteInfoModel,_that.bankName,_that.bankAccountNumber,_that.bankAccountHolder,_that.paymentDeadlineMinutes,_that.confirmationNotes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String name,  String address,  String addressDetail,  String addressGuide,  List<SpaceOptionModel> spaceOptions,  Map<String, StoreMemberInfoModel> memberById,  Map<String, StoreMemberInfoModel> waitingMemberById,  InviteInfoModel? inviteInfoModel,  String? bankName,  String? bankAccountNumber,  String? bankAccountHolder,  int? paymentDeadlineMinutes,  String? confirmationNotes)  $default,) {final _that = this;
switch (_that) {
case _StoreModel():
return $default(_that.id,_that.name,_that.address,_that.addressDetail,_that.addressGuide,_that.spaceOptions,_that.memberById,_that.waitingMemberById,_that.inviteInfoModel,_that.bankName,_that.bankAccountNumber,_that.bankAccountHolder,_that.paymentDeadlineMinutes,_that.confirmationNotes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  String id,  String name,  String address,  String addressDetail,  String addressGuide,  List<SpaceOptionModel> spaceOptions,  Map<String, StoreMemberInfoModel> memberById,  Map<String, StoreMemberInfoModel> waitingMemberById,  InviteInfoModel? inviteInfoModel,  String? bankName,  String? bankAccountNumber,  String? bankAccountHolder,  int? paymentDeadlineMinutes,  String? confirmationNotes)?  $default,) {final _that = this;
switch (_that) {
case _StoreModel() when $default != null:
return $default(_that.id,_that.name,_that.address,_that.addressDetail,_that.addressGuide,_that.spaceOptions,_that.memberById,_that.waitingMemberById,_that.inviteInfoModel,_that.bankName,_that.bankAccountNumber,_that.bankAccountHolder,_that.paymentDeadlineMinutes,_that.confirmationNotes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StoreModel extends StoreModel {
  const _StoreModel({@JsonKey(includeToJson: false) required this.id, required this.name, required this.address, required this.addressDetail, required this.addressGuide, final  List<SpaceOptionModel> spaceOptions = const [], required final  Map<String, StoreMemberInfoModel> memberById, final  Map<String, StoreMemberInfoModel> waitingMemberById = const {}, this.inviteInfoModel, this.bankName, this.bankAccountNumber, this.bankAccountHolder, this.paymentDeadlineMinutes, this.confirmationNotes}): _spaceOptions = spaceOptions,_memberById = memberById,_waitingMemberById = waitingMemberById,super._();
  factory _StoreModel.fromJson(Map<String, dynamic> json) => _$StoreModelFromJson(json);

@override@JsonKey(includeToJson: false) final  String id;
@override final  String name;
@override final  String address;
@override final  String addressDetail;
@override final  String addressGuide;
 final  List<SpaceOptionModel> _spaceOptions;
@override@JsonKey() List<SpaceOptionModel> get spaceOptions {
  if (_spaceOptions is EqualUnmodifiableListView) return _spaceOptions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_spaceOptions);
}

 final  Map<String, StoreMemberInfoModel> _memberById;
@override Map<String, StoreMemberInfoModel> get memberById {
  if (_memberById is EqualUnmodifiableMapView) return _memberById;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_memberById);
}

 final  Map<String, StoreMemberInfoModel> _waitingMemberById;
@override@JsonKey() Map<String, StoreMemberInfoModel> get waitingMemberById {
  if (_waitingMemberById is EqualUnmodifiableMapView) return _waitingMemberById;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_waitingMemberById);
}

@override final  InviteInfoModel? inviteInfoModel;
@override final  String? bankName;
@override final  String? bankAccountNumber;
@override final  String? bankAccountHolder;
@override final  int? paymentDeadlineMinutes;
@override final  String? confirmationNotes;

/// Create a copy of StoreModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoreModelCopyWith<_StoreModel> get copyWith => __$StoreModelCopyWithImpl<_StoreModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StoreModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoreModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.addressDetail, addressDetail) || other.addressDetail == addressDetail)&&(identical(other.addressGuide, addressGuide) || other.addressGuide == addressGuide)&&const DeepCollectionEquality().equals(other._spaceOptions, _spaceOptions)&&const DeepCollectionEquality().equals(other._memberById, _memberById)&&const DeepCollectionEquality().equals(other._waitingMemberById, _waitingMemberById)&&(identical(other.inviteInfoModel, inviteInfoModel) || other.inviteInfoModel == inviteInfoModel)&&(identical(other.bankName, bankName) || other.bankName == bankName)&&(identical(other.bankAccountNumber, bankAccountNumber) || other.bankAccountNumber == bankAccountNumber)&&(identical(other.bankAccountHolder, bankAccountHolder) || other.bankAccountHolder == bankAccountHolder)&&(identical(other.paymentDeadlineMinutes, paymentDeadlineMinutes) || other.paymentDeadlineMinutes == paymentDeadlineMinutes)&&(identical(other.confirmationNotes, confirmationNotes) || other.confirmationNotes == confirmationNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,address,addressDetail,addressGuide,const DeepCollectionEquality().hash(_spaceOptions),const DeepCollectionEquality().hash(_memberById),const DeepCollectionEquality().hash(_waitingMemberById),inviteInfoModel,bankName,bankAccountNumber,bankAccountHolder,paymentDeadlineMinutes,confirmationNotes);

@override
String toString() {
  return 'StoreModel(id: $id, name: $name, address: $address, addressDetail: $addressDetail, addressGuide: $addressGuide, spaceOptions: $spaceOptions, memberById: $memberById, waitingMemberById: $waitingMemberById, inviteInfoModel: $inviteInfoModel, bankName: $bankName, bankAccountNumber: $bankAccountNumber, bankAccountHolder: $bankAccountHolder, paymentDeadlineMinutes: $paymentDeadlineMinutes, confirmationNotes: $confirmationNotes)';
}


}

/// @nodoc
abstract mixin class _$StoreModelCopyWith<$Res> implements $StoreModelCopyWith<$Res> {
  factory _$StoreModelCopyWith(_StoreModel value, $Res Function(_StoreModel) _then) = __$StoreModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) String id, String name, String address, String addressDetail, String addressGuide, List<SpaceOptionModel> spaceOptions, Map<String, StoreMemberInfoModel> memberById, Map<String, StoreMemberInfoModel> waitingMemberById, InviteInfoModel? inviteInfoModel, String? bankName, String? bankAccountNumber, String? bankAccountHolder, int? paymentDeadlineMinutes, String? confirmationNotes
});


@override $InviteInfoModelCopyWith<$Res>? get inviteInfoModel;

}
/// @nodoc
class __$StoreModelCopyWithImpl<$Res>
    implements _$StoreModelCopyWith<$Res> {
  __$StoreModelCopyWithImpl(this._self, this._then);

  final _StoreModel _self;
  final $Res Function(_StoreModel) _then;

/// Create a copy of StoreModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? address = null,Object? addressDetail = null,Object? addressGuide = null,Object? spaceOptions = null,Object? memberById = null,Object? waitingMemberById = null,Object? inviteInfoModel = freezed,Object? bankName = freezed,Object? bankAccountNumber = freezed,Object? bankAccountHolder = freezed,Object? paymentDeadlineMinutes = freezed,Object? confirmationNotes = freezed,}) {
  return _then(_StoreModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,addressDetail: null == addressDetail ? _self.addressDetail : addressDetail // ignore: cast_nullable_to_non_nullable
as String,addressGuide: null == addressGuide ? _self.addressGuide : addressGuide // ignore: cast_nullable_to_non_nullable
as String,spaceOptions: null == spaceOptions ? _self._spaceOptions : spaceOptions // ignore: cast_nullable_to_non_nullable
as List<SpaceOptionModel>,memberById: null == memberById ? _self._memberById : memberById // ignore: cast_nullable_to_non_nullable
as Map<String, StoreMemberInfoModel>,waitingMemberById: null == waitingMemberById ? _self._waitingMemberById : waitingMemberById // ignore: cast_nullable_to_non_nullable
as Map<String, StoreMemberInfoModel>,inviteInfoModel: freezed == inviteInfoModel ? _self.inviteInfoModel : inviteInfoModel // ignore: cast_nullable_to_non_nullable
as InviteInfoModel?,bankName: freezed == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String?,bankAccountNumber: freezed == bankAccountNumber ? _self.bankAccountNumber : bankAccountNumber // ignore: cast_nullable_to_non_nullable
as String?,bankAccountHolder: freezed == bankAccountHolder ? _self.bankAccountHolder : bankAccountHolder // ignore: cast_nullable_to_non_nullable
as String?,paymentDeadlineMinutes: freezed == paymentDeadlineMinutes ? _self.paymentDeadlineMinutes : paymentDeadlineMinutes // ignore: cast_nullable_to_non_nullable
as int?,confirmationNotes: freezed == confirmationNotes ? _self.confirmationNotes : confirmationNotes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of StoreModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InviteInfoModelCopyWith<$Res>? get inviteInfoModel {
    if (_self.inviteInfoModel == null) {
    return null;
  }

  return $InviteInfoModelCopyWith<$Res>(_self.inviteInfoModel!, (value) {
    return _then(_self.copyWith(inviteInfoModel: value));
  });
}
}

// dart format on
