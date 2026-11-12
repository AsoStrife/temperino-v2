// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'partner_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PartnerInfo {

 String get name; Gender get gender;
/// Create a copy of PartnerInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PartnerInfoCopyWith<PartnerInfo> get copyWith => _$PartnerInfoCopyWithImpl<PartnerInfo>(this as PartnerInfo, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PartnerInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PartnerInfo&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.gender, _this.gender) || other.gender == _this.gender));
}


@override
int get hashCode {
  final _this = this as PartnerInfo;
  return Object.hash(runtimeType,_this.name,_this.gender);
}

@override
String toString() {
  final _this = this as PartnerInfo;
  return 'PartnerInfo(name: ${_this.name}, gender: ${_this.gender})';
}


}

/// @nodoc
abstract mixin class $PartnerInfoCopyWith<$Res>  {
  factory $PartnerInfoCopyWith(PartnerInfo value, $Res Function(PartnerInfo) _then) = _$PartnerInfoCopyWithImpl;
@useResult
$Res call({
 String name, Gender gender
});




}
/// @nodoc
class _$PartnerInfoCopyWithImpl<$Res>
    implements $PartnerInfoCopyWith<$Res> {
  _$PartnerInfoCopyWithImpl(this._self, this._then);

  final PartnerInfo _self;
  final $Res Function(PartnerInfo) _then;

/// Create a copy of PartnerInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? gender = null,}) {
  return _then(PartnerInfo(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender,
  ));
}

}


/// Adds pattern-matching-related methods to [PartnerInfo].
extension PartnerInfoPatterns on PartnerInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PartnerInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PartnerInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PartnerInfo value)  $default,){
final _that = this;
switch (_that) {
case _PartnerInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PartnerInfo value)?  $default,){
final _that = this;
switch (_that) {
case _PartnerInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  Gender gender)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PartnerInfo() when $default != null:
return $default(_that.name,_that.gender);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  Gender gender)  $default,) {final _that = this;
switch (_that) {
case _PartnerInfo():
return $default(_that.name,_that.gender);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  Gender gender)?  $default,) {final _that = this;
switch (_that) {
case _PartnerInfo() when $default != null:
return $default(_that.name,_that.gender);case _:
  return null;

}
}

}

/// @nodoc


class _PartnerInfo implements PartnerInfo {
  const _PartnerInfo({required this.name, required this.gender});
  

@override final  String name;
@override final  Gender gender;

/// Create a copy of PartnerInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PartnerInfoCopyWith<_PartnerInfo> get copyWith => __$PartnerInfoCopyWithImpl<_PartnerInfo>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PartnerInfo&&(identical(other.name, name) || other.name == name)&&(identical(other.gender, gender) || other.gender == gender));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,gender);
}

@override
String toString() {
    return 'PartnerInfo(name: $name, gender: $gender)';
}


}

/// @nodoc
abstract mixin class _$PartnerInfoCopyWith<$Res> implements $PartnerInfoCopyWith<$Res> {
  factory _$PartnerInfoCopyWith(_PartnerInfo value, $Res Function(_PartnerInfo) _then) = __$PartnerInfoCopyWithImpl;
@override @useResult
$Res call({
 String name, Gender gender
});




}
/// @nodoc
class __$PartnerInfoCopyWithImpl<$Res>
    implements _$PartnerInfoCopyWith<$Res> {
  __$PartnerInfoCopyWithImpl(this._self, this._then);

  final _PartnerInfo _self;
  final $Res Function(_PartnerInfo) _then;

/// Create a copy of PartnerInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? gender = null,}) {
  return _then(_PartnerInfo(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender,
  ));
}


}

/// @nodoc
mixin _$PartnerProfile {

 PartnerInfo get partnerA; PartnerInfo get partnerB;
/// Create a copy of PartnerProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PartnerProfileCopyWith<PartnerProfile> get copyWith => _$PartnerProfileCopyWithImpl<PartnerProfile>(this as PartnerProfile, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PartnerProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PartnerProfile&&(identical(other.partnerA, _this.partnerA) || other.partnerA == _this.partnerA)&&(identical(other.partnerB, _this.partnerB) || other.partnerB == _this.partnerB));
}


@override
int get hashCode {
  final _this = this as PartnerProfile;
  return Object.hash(runtimeType,_this.partnerA,_this.partnerB);
}

@override
String toString() {
  final _this = this as PartnerProfile;
  return 'PartnerProfile(partnerA: ${_this.partnerA}, partnerB: ${_this.partnerB})';
}


}

/// @nodoc
abstract mixin class $PartnerProfileCopyWith<$Res>  {
  factory $PartnerProfileCopyWith(PartnerProfile value, $Res Function(PartnerProfile) _then) = _$PartnerProfileCopyWithImpl;
@useResult
$Res call({
 PartnerInfo partnerA, PartnerInfo partnerB
});


$PartnerInfoCopyWith<$Res> get partnerA;$PartnerInfoCopyWith<$Res> get partnerB;

}
/// @nodoc
class _$PartnerProfileCopyWithImpl<$Res>
    implements $PartnerProfileCopyWith<$Res> {
  _$PartnerProfileCopyWithImpl(this._self, this._then);

  final PartnerProfile _self;
  final $Res Function(PartnerProfile) _then;

/// Create a copy of PartnerProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? partnerA = null,Object? partnerB = null,}) {
  return _then(PartnerProfile(
partnerA: null == partnerA ? _self.partnerA : partnerA // ignore: cast_nullable_to_non_nullable
as PartnerInfo,partnerB: null == partnerB ? _self.partnerB : partnerB // ignore: cast_nullable_to_non_nullable
as PartnerInfo,
  ));
}
/// Create a copy of PartnerProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PartnerInfoCopyWith<$Res> get partnerA {
  
  return $PartnerInfoCopyWith<$Res>(_self.partnerA, (value) {
    return _then(_self.copyWith(partnerA: value));
  });
}/// Create a copy of PartnerProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PartnerInfoCopyWith<$Res> get partnerB {
  
  return $PartnerInfoCopyWith<$Res>(_self.partnerB, (value) {
    return _then(_self.copyWith(partnerB: value));
  });
}
}


/// Adds pattern-matching-related methods to [PartnerProfile].
extension PartnerProfilePatterns on PartnerProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PartnerProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PartnerProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PartnerProfile value)  $default,){
final _that = this;
switch (_that) {
case _PartnerProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PartnerProfile value)?  $default,){
final _that = this;
switch (_that) {
case _PartnerProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PartnerInfo partnerA,  PartnerInfo partnerB)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PartnerProfile() when $default != null:
return $default(_that.partnerA,_that.partnerB);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PartnerInfo partnerA,  PartnerInfo partnerB)  $default,) {final _that = this;
switch (_that) {
case _PartnerProfile():
return $default(_that.partnerA,_that.partnerB);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PartnerInfo partnerA,  PartnerInfo partnerB)?  $default,) {final _that = this;
switch (_that) {
case _PartnerProfile() when $default != null:
return $default(_that.partnerA,_that.partnerB);case _:
  return null;

}
}

}

/// @nodoc


class _PartnerProfile extends PartnerProfile {
  const _PartnerProfile({required this.partnerA, required this.partnerB}): super._();
  

@override final  PartnerInfo partnerA;
@override final  PartnerInfo partnerB;

/// Create a copy of PartnerProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PartnerProfileCopyWith<_PartnerProfile> get copyWith => __$PartnerProfileCopyWithImpl<_PartnerProfile>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PartnerProfile&&(identical(other.partnerA, partnerA) || other.partnerA == partnerA)&&(identical(other.partnerB, partnerB) || other.partnerB == partnerB));
}


@override
int get hashCode {
    return Object.hash(runtimeType,partnerA,partnerB);
}

@override
String toString() {
    return 'PartnerProfile(partnerA: $partnerA, partnerB: $partnerB)';
}


}

/// @nodoc
abstract mixin class _$PartnerProfileCopyWith<$Res> implements $PartnerProfileCopyWith<$Res> {
  factory _$PartnerProfileCopyWith(_PartnerProfile value, $Res Function(_PartnerProfile) _then) = __$PartnerProfileCopyWithImpl;
@override @useResult
$Res call({
 PartnerInfo partnerA, PartnerInfo partnerB
});


@override $PartnerInfoCopyWith<$Res> get partnerA;@override $PartnerInfoCopyWith<$Res> get partnerB;

}
/// @nodoc
class __$PartnerProfileCopyWithImpl<$Res>
    implements _$PartnerProfileCopyWith<$Res> {
  __$PartnerProfileCopyWithImpl(this._self, this._then);

  final _PartnerProfile _self;
  final $Res Function(_PartnerProfile) _then;

/// Create a copy of PartnerProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? partnerA = null,Object? partnerB = null,}) {
  return _then(_PartnerProfile(
partnerA: null == partnerA ? _self.partnerA : partnerA // ignore: cast_nullable_to_non_nullable
as PartnerInfo,partnerB: null == partnerB ? _self.partnerB : partnerB // ignore: cast_nullable_to_non_nullable
as PartnerInfo,
  ));
}

/// Create a copy of PartnerProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PartnerInfoCopyWith<$Res> get partnerA {
  
  return $PartnerInfoCopyWith<$Res>(_self.partnerA, (value) {
    return _then(_self.copyWith(partnerA: value));
  });
}/// Create a copy of PartnerProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PartnerInfoCopyWith<$Res> get partnerB {
  
  return $PartnerInfoCopyWith<$Res>(_self.partnerB, (value) {
    return _then(_self.copyWith(partnerB: value));
  });
}
}

// dart format on
