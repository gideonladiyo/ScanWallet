import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../models/category_model.dart';

/// Supabase CRUD for the `categories` table.
class CategoryRemoteDatasource {
  CategoryRemoteDatasource(this._client);

  final SupabaseClient _client;

  Future<List<CategoryEntity>> getCategories() async {
    final rows = await _client
        .from('categories')
        .select()
        .order('created_at', ascending: true);
    return (rows as List).map((row) => CategoryModel.fromJson(row)).toList();
  }

  Future<CategoryEntity> createCategory(
    String name,
    TransactionType transactionType, {
    String? color,
  }) async {
    final row = await _client
        .from('categories')
        .insert(
          CategoryModel.toInsertJson(
            userId: _client.auth.currentUser!.id,
            name: name,
            transactionType: transactionType,
            color: color,
          ),
        )
        .select()
        .single();
    return CategoryModel.fromJson(row);
  }

  Future<CategoryEntity> updateCategory(CategoryEntity category) async {
    final row = await _client
        .from('categories')
        .update(CategoryModel.toUpdateJson(category))
        .eq('id', category.id)
        .select()
        .single();
    return CategoryModel.fromJson(row);
  }

  Future<void> deleteCategory(String id) async {
    await _client.from('categories').delete().eq('id', id);
  }
}

final categoryRemoteDatasourceProvider = Provider<CategoryRemoteDatasource>((
  ref,
) {
  return CategoryRemoteDatasource(ref.watch(supabaseClientProvider));
});
