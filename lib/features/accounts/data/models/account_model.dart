import '../../domain/entities/account_entity.dart';

/// Serialization for the `accounts` table (PLANNING.md §1.3).
class AccountModel {
  const AccountModel._();

  static AccountEntity fromJson(Map<String, dynamic> json) {
    return AccountEntity(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      accountType: AccountType.fromWire(json['account_type'] as String),
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static Map<String, dynamic> toInsertJson({
    required String userId,
    required String name,
    required AccountType accountType,
    String? color,
  }) {
    return {
      'user_id': userId,
      'name': name,
      'account_type': accountType.wireName,
      if (color != null) 'color': color,
    };
  }

  static Map<String, dynamic> toUpdateJson(AccountEntity account) {
    return {
      'name': account.name,
      'account_type': account.accountType.wireName,
      if (account.color != null) 'color': account.color,
    };
  }
}
