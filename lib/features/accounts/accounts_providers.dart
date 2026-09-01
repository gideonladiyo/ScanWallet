import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/datasources/account_remote_datasource.dart';
import 'data/repositories/account_repository_impl.dart';
import 'domain/repositories/account_repository.dart';
import 'domain/usecases/create_account_usecase.dart';
import 'domain/usecases/delete_account_usecase.dart';
import 'domain/usecases/get_accounts_usecase.dart';
import 'domain/usecases/update_account_usecase.dart';

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepositoryImpl(ref.watch(accountRemoteDatasourceProvider));
});

final getAccountsUsecaseProvider = Provider<GetAccountsUsecase>(
  (ref) => GetAccountsUsecase(ref.watch(accountRepositoryProvider)),
);

final createAccountUsecaseProvider = Provider<CreateAccountUsecase>(
  (ref) => CreateAccountUsecase(ref.watch(accountRepositoryProvider)),
);

final updateAccountUsecaseProvider = Provider<UpdateAccountUsecase>(
  (ref) => UpdateAccountUsecase(ref.watch(accountRepositoryProvider)),
);

final deleteAccountUsecaseProvider = Provider<DeleteAccountUsecase>(
  (ref) => DeleteAccountUsecase(ref.watch(accountRepositoryProvider)),
);
