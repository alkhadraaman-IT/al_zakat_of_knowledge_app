import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/utils/supabase_timeout.dart';
import '../../domain/entities/article_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/article_repository.dart';
import '../datasources/article_remote_datasource.dart';

/// Implementation of [ArticleRepository] using Supabase.
class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ArticleRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ArticleEntity>> createArticle({
    required String authorId,
    required String title,
    required String body,
    required int categoryId,
  }) async {
    print('<<<<<<<<<<<[createArticle]>>>>>>>>>>>>>');
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final article = await remoteDataSource.createArticle(
        authorId: authorId,
        title: title,
        body: body,
        categoryId: categoryId,
      );
      return Right(article);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on SupabaseTimeoutException catch (_) {
      print('<<<<<<<<<<<[createArticle Timeout]>>>>>>>>>>>>>');
      return Left(
        NetworkFailure(
          message: 'Network request timed out. Please check your connection.',
        ),
      );
    } on SupabaseSocketException catch (_) {
      print('<<<<<<<<<<<[createArticle SocketException]>>>>>>>>>>>>>');
      return Left(NetworkFailure(message: 'Network error'));
    } catch (_) {
      return Left(ServerFailure(message: 'Server error'));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    print('<<<<<<<<<<<[getCategories]>>>>>>>>>>>>>');
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final categories = await remoteDataSource.getCategories();
      return Right(categories);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on SupabaseTimeoutException catch (_) {
      print('<<<<<<<<<<<[getCategories Timeout]>>>>>>>>>>>>>');
      return Left(
        NetworkFailure(
          message: 'Network request timed out. Please check your connection.',
        ),
      );
    } on SupabaseSocketException catch (_) {
      print('<<<<<<<<<<<[getCategories SocketException]>>>>>>>>>>>>>');
      return Left(NetworkFailure(message: 'Network error'));
    } catch (_) {
      return Left(ServerFailure(message: 'Server error'));
    }
  }

  @override
  Future<Either<Failure, List<ArticleEntity>>> getArticles() async {
    print('<<<<<<<<<<<[getArticles]>>>>>>>>>>>>>');
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final articles = await remoteDataSource.getArticles();
      return Right(articles);
    } on PostgrestException catch (e) {
      print('<<<<<<<<<<<[getArticles PostgrestException]>>>>>>>>>>>>>');
      print('Message: ${e.message} (code: ${e.code})');
      return Left(ServerFailure(message: e.message, code: e.code));
    } on SupabaseTimeoutException catch (_) {
      print('<<<<<<<<<<<[getArticles Timeout]>>>>>>>>>>>>>');
      return Left(
        NetworkFailure(
          message: 'Network request timed out. Please check your connection.',
        ),
      );
    } on SupabaseSocketException catch (_) {
      print('<<<<<<<<<<<[getArticles SocketException]>>>>>>>>>>>>>');
      return Left(NetworkFailure(message: 'Network error'));
    } catch (_) {
      return Left(ServerFailure(message: 'Server error'));
    }
  }

  @override
  Future<Either<Failure, List<ArticleEntity>>> getArticlesByAuthor(
    String authorId,
  ) async {
    print('<<<<<<<<<<<[getArticlesByAuthor]>>>>>>>>>>>>>');
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final articles = await remoteDataSource.getArticlesByAuthor(authorId);
      return Right(articles);
    } on PostgrestException catch (e) {
      print('<<<<<<<<<<<[getArticlesByAuthor PostgrestException]>>>>>>>>>>>>>');
      print('Message: ${e.message} (code: ${e.code})');
      return Left(ServerFailure(message: e.message, code: e.code));
    } on SupabaseTimeoutException catch (_) {
      print('<<<<<<<<<<<[getArticlesByAuthor Timeout]>>>>>>>>>>>>>');
      return Left(
        NetworkFailure(
          message: 'Network request timed out. Please check your connection.',
        ),
      );
    } on SupabaseSocketException catch (_) {
      print('<<<<<<<<<<<[getArticlesByAuthor SocketException]>>>>>>>>>>>>>');
      return Left(NetworkFailure(message: 'Network error'));
    } catch (_) {
      return Left(ServerFailure(message: 'Server error'));
    }
  }

  @override
  Future<Either<Failure, void>> updateArticle({
    required String articleId,
    required String title,
    required String body,
    required int categoryId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remoteDataSource.updateArticle(
        articleId: articleId,
        title: title,
        body: body,
        categoryId: categoryId,
      );
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on SupabaseTimeoutException catch (_) {
      return const Left(NetworkFailure(message: 'Network timeout'));
    } on SupabaseSocketException catch (_) {
      return const Left(NetworkFailure(message: 'Network error'));
    } catch (_) {
      return const Left(ServerFailure(message: 'Server error'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteArticle({
    required String articleId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remoteDataSource.deleteArticle(articleId: articleId);
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on SupabaseTimeoutException catch (_) {
      return const Left(NetworkFailure(message: 'Network timeout'));
    } on SupabaseSocketException catch (_) {
      return const Left(NetworkFailure(message: 'Network error'));
    } catch (_) {
      return const Left(ServerFailure(message: 'Server error'));
    }
  }
}
