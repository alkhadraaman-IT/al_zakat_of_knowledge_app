import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/widgets/app_search_bar.dart';
import '../../../../shared/widgets/app_segmented_bar.dart';
import '../../../../shared/widgets/app_top_header.dart';
import '../../../../shared/widgets/article_entity_card.dart';
import '../../../../shared/widgets/session_entity_card.dart';
import '../../../../shared/widgets/study_tool_entity_card.dart';
import '../../../articles/domain/entities/article_entity.dart';
import '../../../articles/presentation/bloc/article_cubit.dart';
import '../../../articles/presentation/bloc/article_state.dart';
import '../../../sessions/domain/entities/session_entity.dart';
import '../../../study_tools/domain/entities/study_tool_entity.dart';
import '../../../study_tools/presentation/cubit/study_tool_cubit.dart';
import '../../../study_tools/presentation/cubit/study_tool_state.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';
import '../widgets/search_filter_bottom_sheet.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<SearchCubit>()..load()),
        BlocProvider.value(value: sl<ArticleCubit>()),
        BlocProvider.value(value: sl<StudyToolCubit>()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ArticleCubit, ArticleState>(
            listenWhen: (_, curr) => curr is ArticleLoaded,
            listener: (context, state) {
              if (state is ArticleLoaded) {
                context.read<SearchCubit>().refreshLists(
                  articles: state.articles,
                );
              }
            },
          ),
          BlocListener<StudyToolCubit, StudyToolState>(
            listenWhen: (_, curr) => curr is StudyToolLoaded,
            listener: (context, state) {
              if (state is StudyToolLoaded) {
                context.read<SearchCubit>().refreshLists(tools: state.tools);
              }
            },
          ),
        ],
        child: Builder(
          builder: (context) {
            final cs = Theme.of(context).colorScheme;
            return Scaffold(
              backgroundColor: cs.surface,
              body: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTopHeader(
                      context: context,
                      onBack: () => Navigator.of(context).pop(),
                      trailing: null,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenHorizontal,
                        vertical: AppSpacing.md,
                      ),
                      child: AppSearchBar(
                        controller: _searchController,
                        onChanged: (value) =>
                            context.read<SearchCubit>().setQuery(value),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.tune, color: cs.onSurface),
                          onPressed: () => _showFilterBottomSheet(context),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenHorizontal,
                      ),
                      child: BlocBuilder<SearchCubit, SearchState>(
                        builder: (context, state) {
                          final selectedTab = state is SearchLoaded
                              ? state.selectedTab
                              : 0;
                          return AppSegmentedBar(
                            labels: [
                              'tabs.lectures'.tr(),
                              'tabs.articles'.tr(),
                              'tabs.tools'.tr(),
                            ],
                            selectedIndex: selectedTab,
                            onTabChanged: (i) =>
                                context.read<SearchCubit>().setTab(i),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: BlocBuilder<SearchCubit, SearchState>(
                        builder: (context, state) {
                          if (state is SearchLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (state is SearchError) {
                            return _buildErrorState(context, state);
                          }
                          if (state is SearchLoaded) {
                            final isQueryEmpty = _searchController.text
                                .trim()
                                .isEmpty;
                            switch (state.selectedTab) {
                              case 0:
                                return state.sessions.isEmpty
                                    ? _buildEmptyState(context, 0, isQueryEmpty)
                                    : _buildSessionResults(state.sessions);
                              case 1:
                                return state.articles.isEmpty
                                    ? _buildEmptyState(context, 1, isQueryEmpty)
                                    : _buildArticleResults(state.articles);
                              case 2:
                                return state.tools.isEmpty
                                    ? _buildEmptyState(context, 2, isQueryEmpty)
                                    : _buildToolResults(state.tools);
                              default:
                                return _buildEmptyState(
                                  context,
                                  state.selectedTab,
                                  isQueryEmpty,
                                );
                            }
                          }
                          // SearchInitial — شاشة قصيرة قبل بدء التحميل
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final cubit = context.read<SearchCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SearchFilterBottomSheet(cubit: cubit),
    );
  }

  Widget _buildErrorState(BuildContext context, SearchError state) {
    final cs = Theme.of(context).colorScheme;
    final cubit = context.read<SearchCubit>();
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: cs.error, size: 56.w),
            SizedBox(height: 12.h),
            Text(
              state.message.tr(),
              style: AppTypography.arabicCaption(
                color: cs.onSurfaceVariant,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            Material(
              color: cs.primary,
              borderRadius: BorderRadius.circular(12.r),
              child: InkWell(
                onTap: () => cubit.retry(),
                borderRadius: BorderRadius.circular(12.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, color: cs.onPrimary, size: 18.w),
                      SizedBox(width: 8.w),
                      Text(
                        'sessions.retry'.tr(),
                        style: AppTypography.arabicLabel(
                          color: cs.onPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    int selectedTab,
    bool isQueryEmpty,
  ) {
    String key;
    if (isQueryEmpty) {
      key = 'search.no_data_available';
    } else {
      switch (selectedTab) {
        case 0:
          key = 'search.no_lectures';
          break;
        case 1:
          key = 'search.no_articles';
          break;
        case 2:
          key = 'search.no_tools';
          break;
        default:
          key = 'search.no_results';
      }
    }
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Text(
          key.tr(),
          style: AppTypography.arabicTitle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSessionResults(List<SessionEntity> sessions) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.md,
      ),
      itemCount: sessions.length,
      separatorBuilder: (_, _) => SizedBox(height: AppSpacing.md),
      itemBuilder: (context, i) => SessionEntityCard(
        key: ValueKey(sessions[i].id),
        session: sessions[i],
      ),
    );
  }

  Widget _buildArticleResults(List<ArticleEntity> articles) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.md,
      ),
      itemCount: articles.length,
      separatorBuilder: (_, _) => SizedBox(height: AppSpacing.md),
      itemBuilder: (context, i) => ArticleEntityCard(
        key: ValueKey(articles[i].id),
        article: articles[i],
      ),
    );
  }

  Widget _buildToolResults(List<StudyToolEntity> tools) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.md,
      ),
      itemCount: tools.length,
      separatorBuilder: (_, _) => SizedBox(height: AppSpacing.md),
      itemBuilder: (context, i) => StudyToolEntityCard(
        key: ValueKey(tools[i].id),
        tool: tools[i],
        index: i,
      ),
    );
  }
}

