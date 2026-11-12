// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'masturbation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Masturbation {

 int? get id; DateOnly get date; Partner get who; bool get toys; int get orgasms;
/// Create a copy of Masturbation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MasturbationCopyWith<Masturbation> get copyWith => _$MasturbationCopyWithImpl<Masturbation>(this as Masturbation, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Masturbation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Masturbation&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.who, _this.who) || other.who == _this.who)&&(identical(other.toys, _this.toys) || other.toys == _this.toys)&&(identical(other.orgasms, _this.orgasms) || other.orgasms == _this.orgasms));
}


@override
int get hashCode {
  final _this = this as Masturbation;
  return Object.hash(runtimeType,_this.id,_this.date,_this.who,_this.toys,_this.orgasms);
}

@override
String toString() {
  final _this = this as Masturbation;
  return 'Masturbation(id: ${_this.id}, date: ${_this.date}, who: ${_this.who}, toys: ${_this.toys}, orgasms: ${_this.orgasms})';
}


}

/// @nodoc
abstract mixin class $MasturbationCopyWith<$Res>  {
  factory $MasturbationCopyWith(Masturbation value, $Res Function(Masturbation) _then) = _$MasturbationCopyWithImpl;
@useResult
$Res call({
 int? id, DateOnly date, Partner who, bool toys, int orgasms
});




}
/// @nodoc
class _$MasturbationCopyWithImpl<$Res>
    implements $MasturbationCopyWith<$Res> {
  _$MasturbationCopyWithImpl(this._self, this._then);

  final Masturbation _self;
  final $Res Function(Masturbation) _then;

/// Create a copy of Masturbation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? date = null,Object? who = null,Object? toys = null,Object? orgasms = null,}) {
  return _then(Masturbation(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateOnly,who: null == who ? _self.who : who // ignore: cast_nullable_to_non_nullable
as Partner,toys: null == toys ? _self.toys : toys // ignore: cast_nullable_to_non_nullable
as bool,orgasms: null == orgasms ? _self.orgasms : orgasms // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Masturbation].
extension MasturbationPatterns on Masturbation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Masturbation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Masturbation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Masturbation value)  $default,){
final _that = this;
switch (_that) {
case _Masturbation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Masturbation value)?  $default,){
final _that = this;
switch (_that) {
case _Masturbation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  DateOnly date,  Partner who,  bool toys,  int orgasms)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Masturbation() when $default != null:
return $default(_that.id,_that.date,_that.who,_that.toys,_that.orgasms);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  DateOnly date,  Partner who,  bool toys,  int orgasms)  $default,) {final _that = this;
switch (_that) {
case _Masturbation():
return $default(_that.id,_that.date,_that.who,_that.toys,_that.orgasms);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  DateOnly date,  Partner who,  bool toys,  int orgasms)?  $default,) {final _that = this;
switch (_that) {
case _Masturbation() when $default != null:
return $default(_that.id,_that.date,_that.who,_that.toys,_that.orgasms);case _:
  return null;

}
}

}

/// @nodoc


class _Masturbation implements Masturbation {
  const _Masturbation({this.id, required this.date, this.who = Partner.a, this.toys = false, this.orgasms = 0});
  

@override final  int? id;
@override final  DateOnly date;
@override@JsonKey() final  Partner who;
@override@JsonKey() final  bool toys;
@override@JsonKey() final  int orgasms;

/// Create a copy of Masturbation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MasturbationCopyWith<_Masturbation> get copyWith => __$MasturbationCopyWithImpl<_Masturbation>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Masturbation&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.who, who) || other.who == who)&&(identical(other.toys, toys) || other.toys == toys)&&(identical(other.orgasms, orgasms) || other.orgasms == orgasms));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,date,who,toys,orgasms);
}

@override
String toString() {
    return 'Masturbation(id: $id, date: $date, who: $who, toys: $toys, orgasms: $orgasms)';
}


}

/// @nodoc
abstract mixin class _$MasturbationCopyWith<$Res> implements $MasturbationCopyWith<$Res> {
  factory _$MasturbationCopyWith(_Masturbation value, $Res Function(_Masturbation) _then) = __$MasturbationCopyWithImpl;
@override @useResult
$Res call({
 int? id, DateOnly date, Partner who, bool toys, int orgasms
});




}
/// @nodoc
class __$MasturbationCopyWithImpl<$Res>
    implements _$MasturbationCopyWith<$Res> {
  __$MasturbationCopyWithImpl(this._self, this._then);

  final _Masturbation _self;
  final $Res Function(_Masturbation) _then;

/// Create a copy of Masturbation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? date = null,Object? who = null,Object? toys = null,Object? orgasms = null,}) {
  return _then(_Masturbation(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateOnly,who: null == who ? _self.who : who // ignore: cast_nullable_to_non_nullable
as Partner,toys: null == toys ? _self.toys : toys // ignore: cast_nullable_to_non_nullable
as bool,orgasms: null == orgasms ? _self.orgasms : orgasms // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
