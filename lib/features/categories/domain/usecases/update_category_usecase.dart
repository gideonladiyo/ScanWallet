import '../../../../core/utils/result.dart';
import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class UpdateCategoryUsecase {
  const UpdateCategoryUsecase(this._repository);

  final CategoryRepository _repository;

  Future<Result<CategoryEntity>> call(CategoryEntity category) {
    return _repository.updateCategory(category);
  }
}
