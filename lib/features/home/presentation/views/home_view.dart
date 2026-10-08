import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_map_grid_painter.dart';
import '../../../../shared/widgets/app_article_card.dart';
import '../../../../shared/widgets/app_search_bar.dart';
import '../../../../shared/widgets/app_segmented_bar.dart';
import '../../../../shared/widgets/app_session_card.dart';
import '../../../../shared/widgets/app_study_tool_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// Home Feed screen — Stitch Design System with tab switching.
/// No local top header — MainShell provides the persistent top bar.
/// No local bottom nav — MainShell provides the persistent bottom dock.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go(AppRoutes.login);
        }
      },
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: AppSpacing.md),
              _buildGreetingSection(context),
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
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 10.r,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 20.w,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: AppSegmentedBar(
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
                  selectedIndex: _selectedTab,
                  onTabChanged: (index) => setState(() => _selectedTab = index),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              _buildTabContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'home.greeting'.tr(),
            style: AppTypography.arabicBody(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final userName = state is AuthAuthenticated
                      ? state.user.fullName.split(' ').first
                      : 'home.guest_name'.tr();
                  return Text(
                    userName,
                    style: AppTypography.arabicHeadline(
                      color: Theme.of(context).colorScheme.onSurface,
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

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildLecturesContent();
      case 1:
        return _buildArticlesContent();
      case 2:
        return _buildStudyToolsContent();
      default:
        return _buildLecturesContent();
    }
  }

  Widget _buildLecturesContent() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
          child: const AppSessionCard(sessionId: 'mock-home-featured'),
        ),
        SizedBox(height: AppSpacing.md),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
          child: _buildSecondaryCardPeek(context),
        ),
      ],
    );
  }

  Widget _buildArticlesContent() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      itemCount: 3,
      separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) => AppArticleCard(index: index),
    );
  }

  Widget _buildStudyToolsContent() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      itemCount: 2,
      separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) => AppStudyToolCard(index: index),
    );
  }

  Widget _buildSecondaryCardPeek(BuildContext context) {
    return Opacity(
      opacity: 0.75,
      child: Container(
        height: 80.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.38), width: 1.5),
          boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12), blurRadius: 18.r)],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: CustomPaint(painter: AppMapGridPainter(lineColor: AppColors.mapGridLine)),
            ),
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5), blurRadius: 12.r)],
              ),
              child: Icon(Icons.location_on, color: Theme.of(context).colorScheme.onPrimary, size: 16.w),
            ),
          ],
        ),
      ),
    );
  }
}

