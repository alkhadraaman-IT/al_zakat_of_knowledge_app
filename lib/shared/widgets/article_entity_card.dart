import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../features/articles/domain/entities/article_entity.dart';
import '../../features/articles/domain/entities/category_entity.dart';
import '../../features/articles/presentation/cubit/categories_cubit.dart';
import '../../features/favorites/domain/entities/favorite_item_entity.dart';
import '../../features/favorites/presentation/widgets/favorite_builder.dart';
import '../../features/favorites/presentation/widgets/favorite_mappers.dart';
import 'app_article_card.dart';

class ArticleEntityCard extends StatelessWidget {
  final ArticleEntity article;
  const ArticleEntityCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    // نلفّ بـ CategoriesCubit (singleton من GetIt) — لا يحتاج Parent provider
    return BlocProvider.value(
      value: sl<CategoriesCubit>(),
      child: BlocBuilder<CategoriesCubit, List<CategoryEntity>>(
        buildWhen: (prev, curr) => prev != curr,
        builder: (context, categories) {
          String? categoryLabel;
          for (final c in categories) {
            if (c.id == article.categoryId) {
              categoryLabel = c.nameFor(context.locale.languageCode);
              break;
            }
          }
          return FavoriteBuilder(
            type: FavoriteType.article,
            id: article.id,
            toFavorite: article.toFavorite,
            builder: (context, isFavorite, onToggle) => AppArticleCard(
              articleId: article.id,
              authorId: article.authorId,
              categoryId: article.categoryId,
              categoryLabel: categoryLabel,   // ← مرَّر التصنيف
              title: article.title,
              body: article.body,
              isFavorite: isFavorite,
              onFavoriteToggle: onToggle,
            ),
          );
        },
      ),
    );
  }
}