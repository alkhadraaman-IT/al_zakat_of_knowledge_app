import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_state_views.dart';
import '../../../../shared/widgets/article_entity_card.dart';
import '../../../../shared/widgets/session_entity_card.dart';
import '../../../../shared/widgets/study_tool_entity_card.dart';
import '../../../articles/domain/entities/article_entity.dart';
import '../../../articles/presentation/bloc/article_cubit.dart';
import '../../../articles/presentation/bloc/article_state.dart';
import '../../../sessions/domain/entities/session_entity.dart';
import '../../../sessions/presentation/session_cubit/session_cubit.dart';
import '../../../sessions/presentation/session_cubit/session_state.dart';
import '../../../study_tools/domain/entities/study_tool_entity.dart';
import '../../../study_tools/presentation/cubit/study_tool_cubit.dart';
import '../../../study_tools/presentation/cubit/study_tool_state.dart';

class LecturesTab extends StatelessWidget {
  const LecturesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      buildWhen: (_, c) => c is! SessionSubmitting && c is! SessionSuccess,
      builder: (context, state) {
        final sessions = state is SessionsLoaded
            ? state.sessions
            : const <SessionEntity>[];
        return FeedBody(
          isLoading: state is! SessionsLoaded && state is! SessionError,
          error: state is SessionError ? state.message : null,
          onRetry: () => context.read<SessionCubit>().getSessions(),
          errorTitle: 'sessions.error_loading'.tr(),
          retryLabel: 'sessions.retry'.tr(),
          emptyIcon: Icons.groups_3,
          emptyTitle: 'sessions.empty'.tr(),
          count: sessions.length,
          itemBuilder: (context, index) => SessionEntityCard(
            key: ValueKey(sessions[index].id),
            session: sessions[index],
          ),
        );
      },
    );
  }
}

class ArticlesTab extends StatelessWidget {
  const ArticlesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArticleCubit, ArticleState>(
      buildWhen: (_, c) => c is! ArticleSubmitting && c is! ArticleSuccess,
      builder: (context, state) {
        final articles = state is ArticleLoaded
            ? state.articles
            : const <ArticleEntity>[];
        return FeedBody(
          isLoading: state is! ArticleLoaded && state is! ArticleError,
          error: state is ArticleError ? state.message : null,
          onRetry: () => context.read<ArticleCubit>().getArticles(),
          errorTitle: 'article.error_loading'.tr(),
          retryLabel: 'article.retry'.tr(),
          emptyIcon: Icons.article_outlined,
          emptyTitle: 'article.empty'.tr(),
          count: articles.length,
          itemBuilder: (context, index) => ArticleEntityCard(
            key: ValueKey(articles[index].id),
            article: articles[index],
          ),
        );
      },
    );
  }
}

class ToolsTab extends StatelessWidget {
  const ToolsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudyToolCubit, StudyToolState>(
      buildWhen: (_, current) =>
          current is StudyToolLoaded ||
          current is StudyToolLoading ||
          current is StudyToolError,
      builder: (context, state) {
        final tools = state is StudyToolLoaded
            ? state.tools
            : const <StudyToolEntity>[];
        return FeedBody(
          isLoading: state is StudyToolLoading,
          error: state is StudyToolError ? state.message : null,
          onRetry: () => context.read<StudyToolCubit>().getStudyTools(),
          errorTitle: 'study_tools.error_loading'.tr(),
          retryLabel: 'study_tools.retry'.tr(),
          emptyIcon: Icons.inventory_2_outlined,
          emptyTitle: 'study_tools.empty'.tr(),
          count: tools.length,
          itemBuilder: (context, index) => StudyToolEntityCard(
            key: ValueKey(tools[index].id),
            tool: tools[index],
            index: index,
          ),
        );
      },
    );
  }
}

class FeedBody extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final String errorTitle;
  final String retryLabel;
  final IconData emptyIcon;
  final String emptyTitle;
  final int count;
  final IndexedWidgetBuilder itemBuilder;

  const FeedBody({
    super.key,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.errorTitle,
    required this.retryLabel,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.count,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final stateHeight = 280.h;

    if (isLoading) return AppLoadingState(height: stateHeight);

    if (error != null) {
      return AppErrorState(
        height: stateHeight,
        title: errorTitle,
        message: error,
        retryLabel: retryLabel,
        onRetry: onRetry,
      );
    }

    if (count == 0) {
      return AppEmptyState(
        height: stateHeight,
        icon: emptyIcon,
        title: emptyTitle,
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      itemCount: count,
      separatorBuilder: (_, _) => SizedBox(height: AppSpacing.md),
      itemBuilder: itemBuilder,
    );
  }
}