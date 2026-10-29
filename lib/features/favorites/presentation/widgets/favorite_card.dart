import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/widgets/article_entity_card.dart';
import '../../../../shared/widgets/session_entity_card.dart';
import '../../../../shared/widgets/study_tool_entity_card.dart';
import '../../../articles/data/models/article_model.dart';
import '../../../articles/domain/entities/article_entity.dart';
import '../../../articles/presentation/bloc/article_cubit.dart';
import '../../../articles/presentation/bloc/article_state.dart';
import '../../../sessions/data/models/session_model.dart';
import '../../../sessions/domain/entities/session_entity.dart';
import '../../../sessions/presentation/session_cubit/session_cubit.dart';
import '../../../sessions/presentation/session_cubit/session_state.dart';
import '../../../study_tools/data/models/study_tool_model.dart';
import '../../../study_tools/domain/entities/study_tool_entity.dart';
import '../../../study_tools/presentation/cubit/study_tool_cubit.dart';
import '../../../study_tools/presentation/cubit/study_tool_state.dart';
import '../../domain/entities/favorite_item_entity.dart';

class FavoriteCard extends StatelessWidget {
  final FavoriteEntity item;
  final int index;

  const FavoriteCard({super.key, required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    switch (item.type) {
      case FavoriteType.lecture:
        final live = context.select<SessionCubit, SessionEntity?>((cubit) {
          final state = cubit.state;
          if (state is SessionsLoaded) {
            for (final session in state.sessions) {
              if (session.id == item.id) return session;
            }
          }
          return null;
        });
        return SessionEntityCard(
          session: live ?? SessionModel.fromMap(item.payload),
        );

      case FavoriteType.article:
        final live = context.select<ArticleCubit, ArticleEntity?>((cubit) {
          final state = cubit.state;
          if (state is ArticleLoaded) {
            for (final article in state.articles) {
              if (article.id == item.id) return article;
            }
          }
          return null;
        });
        return ArticleEntityCard(
          article: live ?? ArticleModel.fromMap(item.payload),
        );

      case FavoriteType.tool:
        final live = context.select<StudyToolCubit, StudyToolEntity?>((cubit) {
          final state = cubit.state;
          if (state is StudyToolLoaded) {
            for (final tool in state.tools) {
              if (tool.id == item.id) return tool;
            }
          }
          return null;
        });
        return StudyToolEntityCard(
          tool: live ?? StudyToolModel.fromMap(item.payload),
          index: index,
        );
    }
  }
}