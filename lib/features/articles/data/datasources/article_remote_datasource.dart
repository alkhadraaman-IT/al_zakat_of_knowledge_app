import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:al_zakat_of_knowledge_app/core/utils/supabase_timeout.dart';
import '../models/article_model.dart';
import '../models/category_model.dart';

abstract class ArticleRemoteDataSource {
  Future<ArticleModel> createArticle({
    required String authorId,
    required String title,
    required String body,
    required int categoryId,
  });

  Future<List<CategoryModel>> getCategories();
  Future<List<ArticleModel>> getArticles();
  Future<List<ArticleModel>> getArticlesByAuthor(String authorId);
}

class ArticleRemoteDataSourceImpl implements ArticleRemoteDataSource {
  final SupabaseClient supabaseClient;

  ArticleRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<ArticleModel> createArticle({
    required String authorId,
    required String title,
    required String body,
    required int categoryId,
  }) async {
    print('<<<<<<<<<<<[createArticle]>>>>>>>>>>>>>');
    final article = ArticleModel(
      id: '',
      authorId: authorId,
      title: title,
      body: body,
      categoryId: categoryId,
      imageUrl: null,
      createdAt: DateTime.now(),
    );

    final response = await (supabaseClient
        .from('articles')
        .insert(article.toInsertJson())
        .select()
        .maybeSingle())
        .withTimeout(operationName: 'createArticle');

    if (response == null) {
      throw Exception('Article creation returned no row');
    }

    // التصحيح هنا: استخدام fromMap بدلاً من fromEntity
    return ArticleModel.fromMap(response);
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    print('<<<<<<<<<<<[getCategories]>>>>>>>>>>>>>');
    final response = await (supabaseClient
        .from('categories')
        .select()
        .order('sort_order'))
        .withTimeout(operationName: 'getCategories');
    return response.map((json) => CategoryModel.fromSupabase(json)).toList();
  }

  @override
  Future<List<ArticleModel>> getArticles() async {
    print('<<<<<<<<<<<[getArticles]>>>>>>>>>>>>>');
    final response = await (supabaseClient
        .from('articles')
        .select()
        .order('created_at', ascending: false))
        .withTimeout(operationName: 'getArticles');
    
    return response
        .map((json) => ArticleModel.fromMap(json))
        .toList();
  }

  @override
  Future<List<ArticleModel>> getArticlesByAuthor(String authorId) async {
    print('<<<<<<<<<<<[getArticlesByAuthor]>>>>>>>>>>>>>');
    final response = await (supabaseClient
        .from('articles')
        .select()
        .eq('author_id', authorId)
        .order('created_at', ascending: false))
        .withTimeout(operationName: 'getArticlesByAuthor');
    
    return response
        .map((json) => ArticleModel.fromMap(json))
        .toList();
  }
}