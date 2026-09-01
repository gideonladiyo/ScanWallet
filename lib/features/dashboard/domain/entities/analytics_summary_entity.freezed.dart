// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_summary_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CategoryBreakdownEntity {
  String get categoryId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  double get totalAmount => throw _privateConstructorUsedError;
  int get transactionCount => throw _privateConstructorUsedError;

  /// Create a copy of CategoryBreakdownEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CategoryBreakdownEntityCopyWith<CategoryBreakdownEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoryBreakdownEntityCopyWith<$Res> {
  factory $CategoryBreakdownEntityCopyWith(
    CategoryBreakdownEntity value,
    $Res Function(CategoryBreakdownEntity) then,
  ) = _$CategoryBreakdownEntityCopyWithImpl<$Res, CategoryBreakdownEntity>;
  @useResult
  $Res call({
    String categoryId,
    String name,
    String? color,
    double totalAmount,
    int transactionCount,
  });
}

/// @nodoc
class _$CategoryBreakdownEntityCopyWithImpl<
  $Res,
  $Val extends CategoryBreakdownEntity
>
    implements $CategoryBreakdownEntityCopyWith<$Res> {
  _$CategoryBreakdownEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CategoryBreakdownEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryId = null,
    Object? name = null,
    Object? color = freezed,
    Object? totalAmount = null,
    Object? transactionCount = null,
  }) {
    return _then(
      _value.copyWith(
            categoryId: null == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            color: freezed == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as String?,
            totalAmount: null == totalAmount
                ? _value.totalAmount
                : totalAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            transactionCount: null == transactionCount
                ? _value.transactionCount
                : transactionCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CategoryBreakdownEntityImplCopyWith<$Res>
    implements $CategoryBreakdownEntityCopyWith<$Res> {
  factory _$$CategoryBreakdownEntityImplCopyWith(
    _$CategoryBreakdownEntityImpl value,
    $Res Function(_$CategoryBreakdownEntityImpl) then,
  ) = __$$CategoryBreakdownEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String categoryId,
    String name,
    String? color,
    double totalAmount,
    int transactionCount,
  });
}

/// @nodoc
class __$$CategoryBreakdownEntityImplCopyWithImpl<$Res>
    extends
        _$CategoryBreakdownEntityCopyWithImpl<
          $Res,
          _$CategoryBreakdownEntityImpl
        >
    implements _$$CategoryBreakdownEntityImplCopyWith<$Res> {
  __$$CategoryBreakdownEntityImplCopyWithImpl(
    _$CategoryBreakdownEntityImpl _value,
    $Res Function(_$CategoryBreakdownEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CategoryBreakdownEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryId = null,
    Object? name = null,
    Object? color = freezed,
    Object? totalAmount = null,
    Object? transactionCount = null,
  }) {
    return _then(
      _$CategoryBreakdownEntityImpl(
        categoryId: null == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        color: freezed == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String?,
        totalAmount: null == totalAmount
            ? _value.totalAmount
            : totalAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        transactionCount: null == transactionCount
            ? _value.transactionCount
            : transactionCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$CategoryBreakdownEntityImpl implements _CategoryBreakdownEntity {
  const _$CategoryBreakdownEntityImpl({
    required this.categoryId,
    required this.name,
    this.color,
    required this.totalAmount,
    required this.transactionCount,
  });

  @override
  final String categoryId;
  @override
  final String name;
  @override
  final String? color;
  @override
  final double totalAmount;
  @override
  final int transactionCount;

  @override
  String toString() {
    return 'CategoryBreakdownEntity(categoryId: $categoryId, name: $name, color: $color, totalAmount: $totalAmount, transactionCount: $transactionCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategoryBreakdownEntityImpl &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.transactionCount, transactionCount) ||
                other.transactionCount == transactionCount));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    categoryId,
    name,
    color,
    totalAmount,
    transactionCount,
  );

  /// Create a copy of CategoryBreakdownEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CategoryBreakdownEntityImplCopyWith<_$CategoryBreakdownEntityImpl>
  get copyWith =>
      __$$CategoryBreakdownEntityImplCopyWithImpl<
        _$CategoryBreakdownEntityImpl
      >(this, _$identity);
}

abstract class _CategoryBreakdownEntity implements CategoryBreakdownEntity {
  const factory _CategoryBreakdownEntity({
    required final String categoryId,
    required final String name,
    final String? color,
    required final double totalAmount,
    required final int transactionCount,
  }) = _$CategoryBreakdownEntityImpl;

  @override
  String get categoryId;
  @override
  String get name;
  @override
  String? get color;
  @override
  double get totalAmount;
  @override
  int get transactionCount;

  /// Create a copy of CategoryBreakdownEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CategoryBreakdownEntityImplCopyWith<_$CategoryBreakdownEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AnalyticsSummaryEntity {
  double get totalBalance => throw _privateConstructorUsedError;
  double get totalIncome => throw _privateConstructorUsedError;
  double get totalExpense => throw _privateConstructorUsedError;
  DateTime get periodStart => throw _privateConstructorUsedError;
  DateTime get periodEnd => throw _privateConstructorUsedError;
  List<CategoryBreakdownEntity> get breakdown =>
      throw _privateConstructorUsedError;

  /// Create a copy of AnalyticsSummaryEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnalyticsSummaryEntityCopyWith<AnalyticsSummaryEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnalyticsSummaryEntityCopyWith<$Res> {
  factory $AnalyticsSummaryEntityCopyWith(
    AnalyticsSummaryEntity value,
    $Res Function(AnalyticsSummaryEntity) then,
  ) = _$AnalyticsSummaryEntityCopyWithImpl<$Res, AnalyticsSummaryEntity>;
  @useResult
  $Res call({
    double totalBalance,
    double totalIncome,
    double totalExpense,
    DateTime periodStart,
    DateTime periodEnd,
    List<CategoryBreakdownEntity> breakdown,
  });
}

/// @nodoc
class _$AnalyticsSummaryEntityCopyWithImpl<
  $Res,
  $Val extends AnalyticsSummaryEntity
>
    implements $AnalyticsSummaryEntityCopyWith<$Res> {
  _$AnalyticsSummaryEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnalyticsSummaryEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalBalance = null,
    Object? totalIncome = null,
    Object? totalExpense = null,
    Object? periodStart = null,
    Object? periodEnd = null,
    Object? breakdown = null,
  }) {
    return _then(
      _value.copyWith(
            totalBalance: null == totalBalance
                ? _value.totalBalance
                : totalBalance // ignore: cast_nullable_to_non_nullable
                      as double,
            totalIncome: null == totalIncome
                ? _value.totalIncome
                : totalIncome // ignore: cast_nullable_to_non_nullable
                      as double,
            totalExpense: null == totalExpense
                ? _value.totalExpense
                : totalExpense // ignore: cast_nullable_to_non_nullable
                      as double,
            periodStart: null == periodStart
                ? _value.periodStart
                : periodStart // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            periodEnd: null == periodEnd
                ? _value.periodEnd
                : periodEnd // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            breakdown: null == breakdown
                ? _value.breakdown
                : breakdown // ignore: cast_nullable_to_non_nullable
                      as List<CategoryBreakdownEntity>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AnalyticsSummaryEntityImplCopyWith<$Res>
    implements $AnalyticsSummaryEntityCopyWith<$Res> {
  factory _$$AnalyticsSummaryEntityImplCopyWith(
    _$AnalyticsSummaryEntityImpl value,
    $Res Function(_$AnalyticsSummaryEntityImpl) then,
  ) = __$$AnalyticsSummaryEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double totalBalance,
    double totalIncome,
    double totalExpense,
    DateTime periodStart,
    DateTime periodEnd,
    List<CategoryBreakdownEntity> breakdown,
  });
}

/// @nodoc
class __$$AnalyticsSummaryEntityImplCopyWithImpl<$Res>
    extends
        _$AnalyticsSummaryEntityCopyWithImpl<$Res, _$AnalyticsSummaryEntityImpl>
    implements _$$AnalyticsSummaryEntityImplCopyWith<$Res> {
  __$$AnalyticsSummaryEntityImplCopyWithImpl(
    _$AnalyticsSummaryEntityImpl _value,
    $Res Function(_$AnalyticsSummaryEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AnalyticsSummaryEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalBalance = null,
    Object? totalIncome = null,
    Object? totalExpense = null,
    Object? periodStart = null,
    Object? periodEnd = null,
    Object? breakdown = null,
  }) {
    return _then(
      _$AnalyticsSummaryEntityImpl(
        totalBalance: null == totalBalance
            ? _value.totalBalance
            : totalBalance // ignore: cast_nullable_to_non_nullable
                  as double,
        totalIncome: null == totalIncome
            ? _value.totalIncome
            : totalIncome // ignore: cast_nullable_to_non_nullable
                  as double,
        totalExpense: null == totalExpense
            ? _value.totalExpense
            : totalExpense // ignore: cast_nullable_to_non_nullable
                  as double,
        periodStart: null == periodStart
            ? _value.periodStart
            : periodStart // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        periodEnd: null == periodEnd
            ? _value.periodEnd
            : periodEnd // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        breakdown: null == breakdown
            ? _value._breakdown
            : breakdown // ignore: cast_nullable_to_non_nullable
                  as List<CategoryBreakdownEntity>,
      ),
    );
  }
}

/// @nodoc

class _$AnalyticsSummaryEntityImpl implements _AnalyticsSummaryEntity {
  const _$AnalyticsSummaryEntityImpl({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.periodStart,
    required this.periodEnd,
    final List<CategoryBreakdownEntity> breakdown = const [],
  }) : _breakdown = breakdown;

  @override
  final double totalBalance;
  @override
  final double totalIncome;
  @override
  final double totalExpense;
  @override
  final DateTime periodStart;
  @override
  final DateTime periodEnd;
  final List<CategoryBreakdownEntity> _breakdown;
  @override
  @JsonKey()
  List<CategoryBreakdownEntity> get breakdown {
    if (_breakdown is EqualUnmodifiableListView) return _breakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_breakdown);
  }

  @override
  String toString() {
    return 'AnalyticsSummaryEntity(totalBalance: $totalBalance, totalIncome: $totalIncome, totalExpense: $totalExpense, periodStart: $periodStart, periodEnd: $periodEnd, breakdown: $breakdown)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnalyticsSummaryEntityImpl &&
            (identical(other.totalBalance, totalBalance) ||
                other.totalBalance == totalBalance) &&
            (identical(other.totalIncome, totalIncome) ||
                other.totalIncome == totalIncome) &&
            (identical(other.totalExpense, totalExpense) ||
                other.totalExpense == totalExpense) &&
            (identical(other.periodStart, periodStart) ||
                other.periodStart == periodStart) &&
            (identical(other.periodEnd, periodEnd) ||
                other.periodEnd == periodEnd) &&
            const DeepCollectionEquality().equals(
              other._breakdown,
              _breakdown,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalBalance,
    totalIncome,
    totalExpense,
    periodStart,
    periodEnd,
    const DeepCollectionEquality().hash(_breakdown),
  );

  /// Create a copy of AnalyticsSummaryEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnalyticsSummaryEntityImplCopyWith<_$AnalyticsSummaryEntityImpl>
  get copyWith =>
      __$$AnalyticsSummaryEntityImplCopyWithImpl<_$AnalyticsSummaryEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _AnalyticsSummaryEntity implements AnalyticsSummaryEntity {
  const factory _AnalyticsSummaryEntity({
    required final double totalBalance,
    required final double totalIncome,
    required final double totalExpense,
    required final DateTime periodStart,
    required final DateTime periodEnd,
    final List<CategoryBreakdownEntity> breakdown,
  }) = _$AnalyticsSummaryEntityImpl;

  @override
  double get totalBalance;
  @override
  double get totalIncome;
  @override
  double get totalExpense;
  @override
  DateTime get periodStart;
  @override
  DateTime get periodEnd;
  @override
  List<CategoryBreakdownEntity> get breakdown;

  /// Create a copy of AnalyticsSummaryEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnalyticsSummaryEntityImplCopyWith<_$AnalyticsSummaryEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}
