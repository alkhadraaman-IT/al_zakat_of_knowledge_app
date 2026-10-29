import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/widgets/app_search_bar.dart';
import '../../../../shared/widgets/app_segmented_bar.dart';
import '../../../../shared/widgets/app_state_views.dart';
import '../../../../shared/widgets/article_entity_card.dart';
import '../../../../shared/widgets/session_entity_card.dart';
import '../../../../shared/widgets/study_tool_entity_card.dart';
import '../../../articles/domain/entities/article_entity.dart';
import '../../../articles/presentation/bloc/article_cubit.dart';
import '../../../articles/presentation/bloc/article_state.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../sessions/domain/entities/session_entity.dart';
import '../../../sessions/presentation/session_cubit/session_cubit.dart';
import '../../../sessions/presentation/session_cubit/session_state.dart';
import '../../../study_tools/domain/entities/study_tool_entity.dart';
import '../../../study_tools/presentation/cubit/study_tool_cubit.dart';
import '../../../study_tools/presentation/cubit/study_tool_state.dart';
import '../cubit/home_cubit.dart';

/// Home Feed — بدون setState وبدون StatefulWidget.
///
/// - التاب المختار + التحميل الأولي: [HomeCubit]
/// - المحاضرات: [SessionCubit]، المقالات: [ArticleCubit]، الأدوات: [StudyToolCubit]
/// - المفضلة: داخل الكروت (FavoriteBuilder ← FavoritesCubit)
///
/// الـ Cubits الثلاثة Singletons، فأي إضافة (محاضرة/أداة/مقالة) بتحدّث
/// القائمة هون لحالها، ولا حاجة لـ AppRefresh.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<SessionCubit>()),
        BlocProvider.value(value: sl<StudyToolCubit>()),
        BlocProvider.value(value: sl<ArticleCubit>()),
        BlocProvider(
          create: (_) => HomeCubit(
            sessionCubit: sl<SessionCubit>(),
            studyToolCubit: sl<StudyToolCubit>(),
            articleCubit: sl<ArticleCubit>(),
          ),
        ),
      ],
      child: const _HomeScreen(),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go(AppRoutes.login);
        }
      },
      child: Container(
        color: cs.surface,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: AppSpacing.md),
              const _GreetingSection(),
              SizedBox(height: AppSpacing.md),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: AppSearchBar(
                  onTap: () => context.push(AppRoutes.search),
                  suffixIcon: Container(
                    width: 48.w,
                    height: 48.w,
                    margin: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.3),
                          blurRadius: 10.r,
                        ),
                      ],
                    ),
                    child: Icon(Icons.search, color: cs.onPrimary, size: 20.w),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: BlocBuilder<HomeCubit, int>(
                  builder: (context, selectedTab) => AppSegmentedBar(
                    labels: [
                      'tabs.lectures'.tr(),
                      'tabs.articles'.tr(),
                      'tabs.tools'.tr(),
                    ],
                    icons: const [
                      Icons.groups_3,
                      Icons.article_outlined,
                      Icons.settings_outlined,
                    ],
                    selectedIndex: selectedTab,
                    onTabChanged: context.read<HomeCubit>().selectTab,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              BlocBuilder<HomeCubit, int>(
                builder: (context, selectedTab) {
                  switch (selectedTab) {
                    case 1:
                      return const _ArticlesTab();
                    case 2:
                      return const _ToolsTab();
                    case 0:
                    default:
                      return const _LecturesTab();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GreetingSection extends StatelessWidget {
  const _GreetingSection();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'home.greeting'.tr(),
            style: AppTypography.arabicBody(
              color: cs.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  final userName = state is AuthAuthenticated
                      ? state.user.fullName.split(' ').first
                      : 'home.guest_name'.tr();
                  return Text(
                    userName,
                    style: AppTypography.arabicHeadline(
                      color: cs.onSurface,
                      fontSize: 24,
                    ),
                  );
                },
              ),
              SizedBox(width: 8.w),
              Text('👋', style: TextStyle(fontSize: 24.sp)),
            ],
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Tabs ─────────────────────────

class _LecturesTab extends StatelessWidget {
  const _LecturesTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      // Submitting / Success (من شاشة الإضافة) ما بتغيّر القائمة الظاهرة
      buildWhen: (_, c) => c is! SessionSubmitting && c is! SessionSuccess,
      builder: (context, state) {
        final sessions = state is SessionsLoaded
            ? state.sessions
            : const <SessionEntity>[];
        return _FeedBody(
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

class _ArticlesTab extends StatelessWidget {
  const _ArticlesTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArticleCubit, ArticleState>(
      buildWhen: (_, c) => c is! ArticleSubmitting && c is! ArticleSuccess,
      builder: (context, state) {
        final articles = state is ArticleLoaded
            ? state.articles
            : const <ArticleEntity>[];
        return _FeedBody(
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

class _ToolsTab extends StatelessWidget {
  const _ToolsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudyToolCubit, StudyToolState>(
      // ✅ يعيد البناء فقط عند تغير فعلي في القائمة
      buildWhen: (_, current) =>
          current is StudyToolLoaded ||
          current is StudyToolLoading ||
          current is StudyToolError,
      builder: (context, state) {
        final tools = state is StudyToolLoaded
            ? state.tools
            : const <StudyToolEntity>[];
        return _FeedBody(
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

/// جسم موحّد للتابات الثلاثة: تحميل ← خطأ ← فارغ ← قائمة.
class _FeedBody extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final String errorTitle;
  final String retryLabel;
  final IconData emptyIcon;
  final String emptyTitle;
  final int count;
  final IndexedWidgetBuilder itemBuilder;

  const _FeedBody({
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
