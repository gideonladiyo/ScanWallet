import '../../../../core/utils/result.dart';
import '../repositories/category_repository.dart';

class DeleteCategoryUsecase {
  const DeleteCategoryUsecase(this._repository);

  final CategoryRepository _repository;

  Future<Result<void>> call(String id) {
    return _repository.deleteCategory(id);
  }
}
