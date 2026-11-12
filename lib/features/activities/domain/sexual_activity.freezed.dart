// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sexual_activity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SexualActivity {

 int? get id; DateOnly get date; Set<Practice> get practices; CumshotZone get cumshot; int get orgasmA; int get orgasmB;
/// Create a copy of SexualActivity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SexualActivityCopyWith<SexualActivity> get copyWith => _$SexualActivityCopyWithImpl<SexualActivity>(this as SexualActivity, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SexualActivity;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SexualActivity&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.date, _this.date) || other.date == _this.date)&&const DeepCollectionEquality().equals(other.practices, _this.practices)&&(identical(other.cumshot, _this.cumshot) || other.cumshot == _this.cumshot)&&(identical(other.orgasmA, _this.orgasmA) || other.orgasmA == _this.orgasmA)&&(identical(other.orgasmB, _this.orgasmB) || other.orgasmB == _this.orgasmB));
}


@override
int get hashCode {
  final _this = this as SexualActivity;
  return Object.hash(runtimeType,_this.id,_this.date,const DeepCollectionEquality().hash(_this.practices),_this.cumshot,_this.orgasmA,_this.orgasmB);
}

@override
String toString() {
  final _this = this as SexualActivity;
  return 'SexualActivity(id: ${_this.id}, date: ${_this.date}, practices: ${_this.practices}, cumshot: ${_this.cumshot}, orgasmA: ${_this.orgasmA}, orgasmB: ${_this.orgasmB})';
}


}

/// @nodoc
abstract mixin class $SexualActivityCopyWith<$Res>  {
  factory $SexualActivityCopyWith(SexualActivity value, $Res Function(SexualActivity) _then) = _$SexualActivityCopyWithImpl;
@useResult
$Res call({
 int? id, DateOnly date, Set<Practice> practices, CumshotZone cumshot, int orgasmA, int orgasmB
});




}
/// @nodoc
class _$SexualActivityCopyWithImpl<$Res>
    implements $SexualActivityCopyWith<$Res> {
  _$SexualActivityCopyWithImpl(this._self, this._then);

  final SexualActivity _self;
  final $Res Function(SexualActivity) _then;

/// Create a copy of SexualActivity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? date = null,Object? practices = null,Object? cumshot = null,Object? orgasmA = null,Object? orgasmB = null,}) {
  return _then(SexualActivity(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateOnly,practices: null == practices ? _self.practices : practices // ignore: cast_nullable_to_non_nullable
as Set<Practice>,cumshot: null == cumshot ? _self.cumshot : cumshot // ignore: cast_nullable_to_non_nullable
as CumshotZone,orgasmA: null == orgasmA ? _self.orgasmA : orgasmA // ignore: cast_nullable_to_non_nullable
as int,orgasmB: null == orgasmB ? _self.orgasmB : orgasmB // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SexualActivity].
extension SexualActivityPatterns on SexualActivity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SexualActivity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SexualActivity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SexualActivity value)  $default,){
final _that = this;
switch (_that) {
case _SexualActivity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SexualActivity value)?  $default,){
final _that = this;
switch (_that) {
case _SexualActivity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  DateOnly date,  Set<Practice> practices,  CumshotZone cumshot,  int orgasmA,  int orgasmB)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SexualActivity() when $default != null:
return $default(_that.id,_that.date,_that.practices,_that.cumshot,_that.orgasmA,_that.orgasmB);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  DateOnly date,  Set<Practice> practices,  CumshotZone cumshot,  int orgasmA,  int orgasmB)  $default,) {final _that = this;
switch (_that) {
case _SexualActivity():
return $default(_that.id,_that.date,_that.practices,_that.cumshot,_that.orgasmA,_that.orgasmB);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  DateOnly date,  Set<Practice> practices,  CumshotZone cumshot,  int orgasmA,  int orgasmB)?  $default,) {final _that = this;
switch (_that) {
case _SexualActivity() when $default != null:
return $default(_that.id,_that.date,_that.practices,_that.cumshot,_that.orgasmA,_that.orgasmB);case _:
  return null;

}
}

}

/// @nodoc


class _SexualActivity extends SexualActivity {
  const _SexualActivity({this.id, required this.date,  Set<Practice> practices = const <Practice>{}, this.cumshot = CumshotZone.none, this.orgasmA = 0, this.orgasmB = 0}): _practices = practices,super._();
  

@override final  int? id;
@override final  DateOnly date;
 final  Set<Practice> _practices;
@override@JsonKey() Set<Practice> get practices {
  if (_practices is EqualUnmodifiableSetView) return _practices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_practices);
}

@override@JsonKey() final  CumshotZone cumshot;
@override@JsonKey() final  int orgasmA;
@override@JsonKey() final  int orgasmB;

/// Create a copy of SexualActivity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SexualActivityCopyWith<_SexualActivity> get copyWith => __$SexualActivityCopyWithImpl<_SexualActivity>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SexualActivity&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other.practices, _practices)&&(identical(other.cumshot, cumshot) || other.cumshot == cumshot)&&(identical(other.orgasmA, orgasmA) || other.orgasmA == orgasmA)&&(identical(other.orgasmB, orgasmB) || other.orgasmB == orgasmB));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,date,const DeepCollectionEquality().hash(_practices),cumshot,orgasmA,orgasmB);
}

@override
String toString() {
    return 'SexualActivity(id: $id, date: $date, practices: $practices, cumshot: $cumshot, orgasmA: $orgasmA, orgasmB: $orgasmB)';
}


}

/// @nodoc
abstract mixin class _$SexualActivityCopyWith<$Res> implements $SexualActivityCopyWith<$Res> {
  factory _$SexualActivityCopyWith(_SexualActivity value, $Res Function(_SexualActivity) _then) = __$SexualActivityCopyWithImpl;
@override @useResult
$Res call({
 int? id, DateOnly date, Set<Practice> practices, CumshotZone cumshot, int orgasmA, int orgasmB
});




}
/// @nodoc
class __$SexualActivityCopyWithImpl<$Res>
    implements _$SexualActivityCopyWith<$Res> {
  __$SexualActivityCopyWithImpl(this._self, this._then);

  final _SexualActivity _self;
  final $Res Function(_SexualActivity) _then;

/// Create a copy of SexualActivity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? date = null,Object? practices = null,Object? cumshot = null,Object? orgasmA = null,Object? orgasmB = null,}) {
  return _then(_SexualActivity(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateOnly,practices: null == practices ? _self._practices : practices // ignore: cast_nullable_to_non_nullable
as Set<Practice>,cumshot: null == cumshot ? _self.cumshot : cumshot // ignore: cast_nullable_to_non_nullable
as CumshotZone,orgasmA: null == orgasmA ? _self.orgasmA : orgasmA // ignore: cast_nullable_to_non_nullable
as int,orgasmB: null == orgasmB ? _self.orgasmB : orgasmB // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
