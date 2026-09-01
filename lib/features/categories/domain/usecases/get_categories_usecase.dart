import '../../../../core/utils/result.dart';
import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class GetCategoriesUsecase {
  const GetCategoriesUsecase(this._repository);

  final CategoryRepository _repository;

  Future<Result<List<CategoryEntity>>> call() {
    return _repository.getCategories();
  }
}
