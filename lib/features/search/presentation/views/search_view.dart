import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_article_card.dart';
import '../../../../shared/widgets/app_filter_chips.dart';
import '../../../../shared/widgets/app_search_bar.dart';
import '../../../../shared/widgets/app_segmented_bar.dart';
import '../../../../shared/widgets/app_session_card.dart';
import '../../../../shared/widgets/app_study_tool_card.dart';
import '../../../../shared/widgets/app_top_header.dart';

/// Search screen — Stitch Design System with tab switching.
class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTab = 0;

  final List<String> _recentSearches = [
    'أصول الفقه',
    'علم التجويد',
    'السيرة النبوية',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTopHeader(
              context: context,
              onBack: () => Navigator.of(context).pop(),
            ),
            SizedBox(height: AppSpacing.md),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
              child: AppSearchBar(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
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
                  child: Icon(Icons.search, color: Theme.of(context).colorScheme.onPrimary, size: 20.w),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
              child: AppSegmentedBar(
                labels: [
                  'tabs.lectures'.tr(),
                  'tabs.articles'.tr(),
                  'tabs.tools'.tr(),
                ],
                selectedIndex: _selectedTab,
                onTabChanged: (index) => setState(() => _selectedTab = index),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            AppFilterChips(
              labels: [
                'search.filter_all'.tr(),
                'search.filter_in_person'.tr(),
                'search.filter_online'.tr(),
                'search.filter_free'.tr(),
                'search.filter_waqf'.tr(),
              ],
              onSelectionChanged: (_) {},
            ),
            SizedBox(height: AppSpacing.md),
            Expanded(
              child: _searchController.text.isEmpty && _recentSearches.isNotEmpty
                  ? _buildRecentSearches()
                  : _buildTabResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabResults() {
    switch (_selectedTab) {
      case 0:
        return _buildLectureResults();
      case 1:
        return _buildArticleResults();
      case 2:
        return _buildToolResults();
      default:
        return _buildLectureResults();
    }
  }

  Widget _buildLectureResults() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      itemCount: 3,
      separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) => AppSessionCard(sessionId: 'mock-search-${index + 1}'),
    );
  }

  Widget _buildArticleResults() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      itemCount: 3,
      separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) => AppArticleCard(index: index),
    );
  }

  Widget _buildToolResults() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      itemCount: 2,
      separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) => AppStudyToolCard(index: index),
    );
  }

  Widget _buildRecentSearches() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'search.recent'.tr(),
            style: AppTypography.arabicTitle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
          ),
          SizedBox(height: AppSpacing.md),
          ...List.generate(_recentSearches.length, (index) {
            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(Icons.history, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20.w),
                  SizedBox(width: 12.w),
                  Text(
                    _recentSearches[index],
                    style: AppTypography.arabicBody(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
