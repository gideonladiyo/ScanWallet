import '../../../../core/error/failure_mapper.dart';
import '../../../../core/utils/result.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._datasource);

  final CategoryRemoteDatasource _datasource;

  @override
  Future<Result<List<CategoryEntity>>> getCategories() async {
    try {
      return Success(await _datasource.getCategories());
    } catch (e) {
      return Failure(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<CategoryEntity>> createCategory(
    String name,
    TransactionType transactionType, {
    String? color,
  }) async {
    try {
      return Success(
        await _datasource.createCategory(name, transactionType, color: color),
      );
    } catch (e) {
      return Failure(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<CategoryEntity>> updateCategory(CategoryEntity category) async {
    try {
      return Success(await _datasource.updateCategory(category));
    } catch (e) {
      return Failure(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> deleteCategory(String id) async {
    try {
      await _datasource.deleteCategory(id);
      return const Success(null);
    } catch (e) {
      return Failure(mapExceptionToFailure(e));
    }
  }
}
