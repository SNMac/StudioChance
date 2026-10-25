// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store_membership.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StoreMembership {

 Map<String, UserRole> get roleByUid;
/// Create a copy of StoreMembership
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoreMembershipCopyWith<StoreMembership> get copyWith => _$StoreMembershipCopyWithImpl<StoreMembership>(this as StoreMembership, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoreMembership&&const DeepCollectionEquality().equals(other.roleByUid, roleByUid));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(roleByUid));

@override
String toString() {
  return 'StoreMembership(roleByUid: $roleByUid)';
}


}

/// @nodoc
abstract mixin class $StoreMembershipCopyWith<$Res>  {
  factory $StoreMembershipCopyWith(StoreMembership value, $Res Function(StoreMembership) _then) = _$StoreMembershipCopyWithImpl;
@useResult
$Res call({
 Map<String, UserRole> roleByUid
});




}
/// @nodoc
class _$StoreMembershipCopyWithImpl<$Res>
    implements $StoreMembershipCopyWith<$Res> {
  _$StoreMembershipCopyWithImpl(this._self, this._then);

  final StoreMembership _self;
  final $Res Function(StoreMembership) _then;

/// Create a copy of StoreMembership
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? roleByUid = null,}) {
  return _then(_self.copyWith(
roleByUid: null == roleByUid ? _self.roleByUid : roleByUid // ignore: cast_nullable_to_non_nullable
as Map<String, UserRole>,
  ));
}

}


/// Adds pattern-matching-related methods to [StoreMembership].
extension StoreMembershipPatterns on StoreMembership {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoreMembership value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoreMembership() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoreMembership value)  $default,){
final _that = this;
switch (_that) {
case _StoreMembership():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoreMembership value)?  $default,){
final _that = this;
switch (_that) {
case _StoreMembership() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, UserRole> roleByUid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoreMembership() when $default != null:
return $default(_that.roleByUid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, UserRole> roleByUid)  $default,) {final _that = this;
switch (_that) {
case _StoreMembership():
return $default(_that.roleByUid);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, UserRole> roleByUid)?  $default,) {final _that = this;
switch (_that) {
case _StoreMembership() when $default != null:
return $default(_that.roleByUid);case _:
  return null;

}
}

}

/// @nodoc


class _StoreMembership extends StoreMembership {
  const _StoreMembership({required final  Map<String, UserRole> roleByUid}): _roleByUid = roleByUid,super._();
  

 final  Map<String, UserRole> _roleByUid;
@override Map<String, UserRole> get roleByUid {
  if (_roleByUid is EqualUnmodifiableMapView) return _roleByUid;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_roleByUid);
}


/// Create a copy of StoreMembership
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoreMembershipCopyWith<_StoreMembership> get copyWith => __$StoreMembershipCopyWithImpl<_StoreMembership>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoreMembership&&const DeepCollectionEquality().equals(other._roleByUid, _roleByUid));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_roleByUid));

@override
String toString() {
  return 'StoreMembership(roleByUid: $roleByUid)';
}


}

/// @nodoc
abstract mixin class _$StoreMembershipCopyWith<$Res> implements $StoreMembershipCopyWith<$Res> {
  factory _$StoreMembershipCopyWith(_StoreMembership value, $Res Function(_StoreMembership) _then) = __$StoreMembershipCopyWithImpl;
@override @useResult
$Res call({
 Map<String, UserRole> roleByUid
});




}
/// @nodoc
class __$StoreMembershipCopyWithImpl<$Res>
    implements _$StoreMembershipCopyWith<$Res> {
  __$StoreMembershipCopyWithImpl(this._self, this._then);

  final _StoreMembership _self;
  final $Res Function(_StoreMembership) _then;

/// Create a copy of StoreMembership
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? roleByUid = null,}) {
  return _then(_StoreMembership(
roleByUid: null == roleByUid ? _self._roleByUid : roleByUid // ignore: cast_nullable_to_non_nullable
as Map<String, UserRole>,
  ));
}


}

// dart format on
