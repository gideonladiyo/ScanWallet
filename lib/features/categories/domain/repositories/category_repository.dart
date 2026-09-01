import '../../../../core/utils/result.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/category_entity.dart';

abstract class CategoryRepository {
  Future<Result<List<CategoryEntity>>> getCategories();
  Future<Result<CategoryEntity>> createCategory(
    String name,
    TransactionType transactionType, {
    String? color,
  });
  Future<Result<CategoryEntity>> updateCategory(CategoryEntity category);
  Future<Result<void>> deleteCategory(String id);
}
