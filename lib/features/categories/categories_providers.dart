import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/datasources/category_remote_datasource.dart';
import 'data/repositories/category_repository_impl.dart';
import 'domain/repositories/category_repository.dart';
import 'domain/usecases/create_category_usecase.dart';
import 'domain/usecases/delete_category_usecase.dart';
import 'domain/usecases/get_categories_usecase.dart';
import 'domain/usecases/update_category_usecase.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.watch(categoryRemoteDatasourceProvider));
});

final getCategoriesUsecaseProvider = Provider<GetCategoriesUsecase>(
  (ref) => GetCategoriesUsecase(ref.watch(categoryRepositoryProvider)),
);

final createCategoryUsecaseProvider = Provider<CreateCategoryUsecase>(
  (ref) => CreateCategoryUsecase(ref.watch(categoryRepositoryProvider)),
);

final updateCategoryUsecaseProvider = Provider<UpdateCategoryUsecase>(
  (ref) => UpdateCategoryUsecase(ref.watch(categoryRepositoryProvider)),
);

final deleteCategoryUsecaseProvider = Provider<DeleteCategoryUsecase>(
  (ref) => DeleteCategoryUsecase(ref.watch(categoryRepositoryProvider)),
);
