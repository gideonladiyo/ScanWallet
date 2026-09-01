import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_entity.freezed.dart';

/// Account type. Mirrors `accounts.account_type` (PLANNING.md §1.3).
enum AccountType {
  cash,
  eWallet,
  bank;

  String get wireName => switch (this) {
    cash => 'cash',
    eWallet => 'e_wallet',
    bank => 'bank',
  };

  static AccountType fromWire(String value) {
    return switch (value) {
      'cash' => AccountType.cash,
      'e_wallet' => AccountType.eWallet,
      _ => AccountType.bank,
    };
  }
}

/// A wallet/account owned by the user (Cash, GoPay, BCA, ...).
@freezed
class AccountEntity with _$AccountEntity {
  const factory AccountEntity({
    required String id,
    required String userId,
    required String name,
    required AccountType accountType,
    String? icon,
    String? color,
    @Default(0) double balance,
    @Default(false) bool isDefault,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AccountEntity;
}
