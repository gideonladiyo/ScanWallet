import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../transactions/domain/entities/transaction_entity.dart';

part 'category_entity.freezed.dart';

/// Transaction category (PLANNING.md §1.4).
@freezed
class CategoryEntity with _$CategoryEntity {
  const factory CategoryEntity({
    required String id,
    required String userId,
    required String name,
    required TransactionType transactionType,
    String? icon,
    String? color,
    @Default(false) bool isDefault,
    required DateTime createdAt,
  }) = _CategoryEntity;
}
