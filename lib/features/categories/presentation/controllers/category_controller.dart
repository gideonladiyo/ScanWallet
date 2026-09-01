import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../../../core/utils/result.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../categories_providers.dart';
import '../../domain/entities/category_entity.dart';

/// Category list + CRUD state (TASKS.md 4C.1).
class CategoryController extends AsyncNotifier<List<CategoryEntity>> {
  @override
  FutureOr<List<CategoryEntity>> build() async {
    ref.watch(authStateChangesProvider);
    final result = await ref.watch(getCategoriesUsecaseProvider).call();
    return result.fold((failure) => throw failure, (categories) => categories);
  }

  Future<Result<CategoryEntity>> create(
    String name,
    TransactionType transactionType, {
    String? color,
  }) async {
    final result = await ref
        .read(createCategoryUsecaseProvider)
        .call(name, transactionType, color: color);
    return result.fold((failure) => Failure(failure), (category) {
      ref.invalidateSelf();
      return Success(category);
    });
  }

  Future<Result<CategoryEntity>> updateCategory(CategoryEntity category) async {
    final result = await ref.read(updateCategoryUsecaseProvider).call(category);
    return result.fold((failure) => Failure(failure), (category) {
      ref.invalidateSelf();
      return Success(category);
    });
  }

  Future<Result<void>> delete(String id) async {
    final result = await ref.read(deleteCategoryUsecaseProvider).call(id);
    return result.fold((failure) => Failure(failure), (_) {
      ref.invalidateSelf();
      return const Success(null);
    });
  }
}

final categoryControllerProvider =
    AsyncNotifierProvider<CategoryController, List<CategoryEntity>>(
      CategoryController.new,
    );
