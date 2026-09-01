import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../domain/entities/category_entity.dart';

/// Serialization for the `categories` table (PLANNING.md §1.4).
class CategoryModel {
  const CategoryModel._();

  static CategoryEntity fromJson(Map<String, dynamic> json) {
    return CategoryEntity(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      transactionType: TransactionType.fromWire(
        json['transaction_type'] as String,
      ),
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static Map<String, dynamic> toInsertJson({
    required String userId,
    required String name,
    required TransactionType transactionType,
    String? color,
  }) {
    return {
      'user_id': userId,
      'name': name,
      'transaction_type': transactionType.wireName,
      if (color != null) 'color': color,
    };
  }

  static Map<String, dynamic> toUpdateJson(CategoryEntity category) {
    return {
      'name': category.name,
      'transaction_type': category.transactionType.wireName,
      if (category.color != null) 'color': category.color,
    };
  }
}
