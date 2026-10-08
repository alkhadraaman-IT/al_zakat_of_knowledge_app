import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_article_card.dart';
import '../../../../shared/widgets/app_segmented_bar.dart';
import '../../../../shared/widgets/app_session_card.dart';

/// Favorites screen — Stitch Design System.
/// Primary tab accessed from bottom nav dock.
/// No local top header — MainShell provides the persistent AppTopHeader.
/// No back button — this is a primary tab, not a pushed screen.
/// Session + article cards use the centralized shared widgets
/// (AppSessionCard / AppArticleCard) with favorite-toggle support.
class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  int _selectedTab = 0;
  final Set<int> _favoriteLectures = {0, 2};
  final Set<int> _favoriteArticles = {1};

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: AppSpacing.md),
          _buildScreenTitle(context),
          SizedBox(height: AppSpacing.md),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
            child: AppSegmentedBar(
              labels: [
                'favorites.tab_lectures'.tr(),
                'favorites.tab_articles'.tr(),
                'favorites.tab_tools'.tr(),
              ],
              selectedIndex: _selectedTab,
              onTabChanged: (index) => setState(() => _selectedTab = index),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Expanded(
            child: _selectedTab == 0
                ? _buildLecturesTab()
                : _selectedTab == 1
                    ? _buildArticlesTab()
                    : _buildToolsTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenTitle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
            ),
            child: Icon(
              Icons.bookmark,
              color: Theme.of(context).colorScheme.primary,
              size: 20.w,
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'favorites.title'.tr(),
                style: AppTypography.arabicHeadline(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 24,
                ),
              ),
              Text(
                'favorites.subtitle'.tr(),
                style: AppTypography.arabicCaption(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLecturesTab() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.md,
      ),
      itemCount: 3,
      separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) => AppSessionCard(
        sessionId: 'mock-favorite-${index + 1}',
        isFavorite: _favoriteLectures.contains(index),
        onFavoriteToggle: () => setState(() {
          if (_favoriteLectures.contains(index)) {
            _favoriteLectures.remove(index);
          } else {
            _favoriteLectures.add(index);
          }
        }),
      ),
    );
  }

  Widget _buildArticlesTab() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.md,
      ),
      itemCount: 2,
      separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) => AppArticleCard(
        index: index,
        isFavorite: _favoriteArticles.contains(index),
        onFavoriteToggle: () => setState(() {
          if (_favoriteArticles.contains(index)) {
            _favoriteArticles.remove(index);
          } else {
            _favoriteArticles.add(index);
          }
        }),
      ),
    );
  }

  Widget _buildToolsTab() {
    return Center(
      child: Text(
        'favorites.empty_tools'.tr(),
        style: AppTypography.arabicBody(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 14,
        ),
      ),
    );
  }
}
