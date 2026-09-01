import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_info.dart';
import 'data/datasources/transaction_local_datasource.dart';
import 'data/datasources/transaction_remote_datasource.dart';
import 'data/repositories/transaction_repository_impl.dart';
import 'domain/repositories/transaction_repository.dart';
import 'domain/usecases/create_transaction_usecase.dart';
import 'domain/usecases/delete_transaction_usecase.dart';
import 'domain/usecases/get_transactions_usecase.dart';
import 'domain/usecases/update_transaction_usecase.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(
    ref.watch(transactionRemoteDatasourceProvider),
    TransactionLocalDatasource(),
    ref.watch(networkInfoProvider),
  );
});

final getTransactionsUsecaseProvider = Provider<GetTransactionsUsecase>(
  (ref) => GetTransactionsUsecase(ref.watch(transactionRepositoryProvider)),
);

final createTransactionUsecaseProvider = Provider<CreateTransactionUsecase>(
  (ref) => CreateTransactionUsecase(ref.watch(transactionRepositoryProvider)),
);

final updateTransactionUsecaseProvider = Provider<UpdateTransactionUsecase>(
  (ref) => UpdateTransactionUsecase(ref.watch(transactionRepositoryProvider)),
);

final deleteTransactionUsecaseProvider = Provider<DeleteTransactionUsecase>(
  (ref) => DeleteTransactionUsecase(ref.watch(transactionRepositoryProvider)),
);
