import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/widgets/app_segmented_bar.dart';
import '../../../../shared/widgets/app_state_views.dart';
import '../../../sessions/presentation/session_cubit/session_cubit.dart';
import '../../../study_tools/presentation/bloc/study_tool_cubit.dart';
import '../../domain/entities/favorite_item_entity.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';
import '../widgets/favorite_card.dart';

/// شاشة المفضلة (جسم الصفحة فقط — الـ AppBar والـ bottom nav من الـ shell).
///
/// - بدون setState: التاب المختار والقائمة من [FavoritesCubit].
/// - القائمة بتتحدّث لحالها: الـ Cubit مشترك على Stream من صندوق Hive.
/// - يحتاج [FavoritesCubit] مزوّد من أعلى التطبيق (main.dart).
class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    // SessionCubit و StudyToolCubit: لعرض النسخة الحية للمحاضرة/الأداة.
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<SessionCubit>()),
        BlocProvider.value(value: sl<StudyToolCubit>()),
      ],
      child: const _FavoritesBody(),
    );
  }
}

class _FavoritesBody extends StatelessWidget {
  const _FavoritesBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: AppSpacing.md),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
          child: BlocSelector<FavoritesCubit, FavoritesState, FavoriteType>(
            selector: (state) => state.selectedType,
            builder: (context, type) => AppSegmentedBar(
              // نفس ترتيب enum FavoriteType: lecture, article, tool
              labels: [
                'favorites.tab_lectures'.tr(),
                'favorites.tab_articles'.tr(),
                'favorites.tab_tools'.tr(),
              ],
              icons: const [
                Icons.groups_3,
                Icons.article_outlined,
                Icons.settings_outlined,
              ],
              selectedIndex: type.index,
              onTabChanged: (index) => context
                  .read<FavoritesCubit>()
                  .selectType(FavoriteType.values[index]),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.md),
        const Expanded(child: _FavoritesList()),
      ],
    );
  }
}

class _FavoritesList extends StatelessWidget {
  const _FavoritesList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.selectedType != current.selectedType ||
          !listEquals(previous.visible, current.visible),
      builder: (context, state) {
        if (state.status == FavoritesStatus.loading) {
          return const AppLoadingState();
        }

        if (state.status == FavoritesStatus.failure) {
          return AppEmptyState(
            icon: Icons.error_outline,
            title: state.error ?? '',
          );
        }

        final items = state.visible;
        if (items.isEmpty) {
          return AppEmptyState(
            icon: Icons.bookmark_border,
            title: 'favorites.empty'.tr(),
            hint: 'favorites.empty_hint'.tr(),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.only(
            left: AppSpacing.screenHorizontal,
right: AppSpacing.screenHorizontal,
            bottom: AppSpacing.xl,
          ),
          itemCount: items.length,
          separatorBuilder: (_, _) => SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) => FavoriteCard(
            key: ValueKey(items[index].key),
            item: items[index],
            index: index,
          ),
        );
      },
    );
  }
}
