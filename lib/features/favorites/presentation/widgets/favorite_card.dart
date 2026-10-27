import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/widgets/session_entity_card.dart';
import '../../../articles/data/models/article_model.dart';
import '../../../sessions/data/models/session_model.dart';
import '../../../sessions/domain/entities/session_entity.dart';
import '../../../sessions/presentation/session_cubit/session_cubit.dart';
import '../../../sessions/presentation/session_cubit/session_state.dart';
import '../../../study_tools/data/models/study_tool_model.dart';
import '../../../study_tools/domain/entities/study_tool_entity.dart';
import '../../../study_tools/presentation/bloc/study_tool_cubit.dart';
import '../../../study_tools/presentation/bloc/study_tool_state.dart';
import '../../domain/entities/favorite_item_entity.dart';

/// كرت عنصر بشاشة المفضلة. يعيد استخدام نفس كروت Home.
/// ضغط الأيقونة على عنصر محفوظ = حذفه من المفضلة.
///
/// المحاضرات والأدوات: إذا القائمة الحية محمّلة بالـ Cubit نعرض النسخة
/// الحديثة (المقاعد المحجوزة / متاحة أو مأخوذة)، وإلا نعرض النسخة المحفوظة.
/// يحتاج SessionCubit و StudyToolCubit فوقه (FavoritesView بتزوّدهم).
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
        return ArticleEntityCard(article: ArticleModel.fromMap(item.payload));

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
