import '../../../../core/error/failure_mapper.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_remote_datasource.dart';

class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl(this._datasource);

  final AccountRemoteDatasource _datasource;

  @override
  Future<Result<List<AccountEntity>>> getAccounts() async {
    try {
      return Success(await _datasource.getAccounts());
    } catch (e) {
      return Failure(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<AccountEntity>> createAccount(
    String name,
    AccountType accountType, {
    String? color,
  }) async {
    try {
      return Success(
        await _datasource.createAccount(name, accountType, color: color),
      );
    } catch (e) {
      return Failure(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<AccountEntity>> updateAccount(AccountEntity account) async {
    try {
      return Success(await _datasource.updateAccount(account));
    } catch (e) {
      return Failure(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> deleteAccount(String id) async {
    try {
      await _datasource.deleteAccount(id);
      return const Success(null);
    } catch (e) {
      return Failure(mapExceptionToFailure(e));
    }
  }
}
