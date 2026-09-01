import '../../../../core/utils/result.dart';
import '../entities/account_entity.dart';

abstract class AccountRepository {
  Future<Result<List<AccountEntity>>> getAccounts();
  Future<Result<AccountEntity>> createAccount(
    String name,
    AccountType accountType, {
    String? color,
  });
  Future<Result<AccountEntity>> updateAccount(AccountEntity account);
  Future<Result<void>> deleteAccount(String id);
}
