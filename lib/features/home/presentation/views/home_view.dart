import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/widgets/app_search_bar.dart';
import '../../../../shared/widgets/app_segmented_bar.dart';
import '../../../articles/presentation/bloc/article_cubit.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../sessions/presentation/session_cubit/session_cubit.dart';
import '../../../study_tools/presentation/cubit/study_tool_cubit.dart';
import '../cubit/home_cubit.dart';
import '../widgets/greeting_section.dart'; // 👈 استخدمنا المكون المنفصل
import '../widgets/home_tabs.dart'; // 👈 استخدمنا التابات المنفصلة

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
              const GreetingSection(), // 👈 تم حذف المكرر واستخدام الملف الخاص به
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
                      return const ArticlesTab();
                    case 2:
                      return const ToolsTab();
                    case 0:
                    default:
                      return const LecturesTab();
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