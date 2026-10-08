import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_typography.dart';

/// Article card — Stitch Design System (Tab 2: مقالات).
/// Features: bookmark icon, "صدقة جارية" badge, title, description, read button + reading time.
class AppArticleCard extends StatelessWidget {
  final int index;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const AppArticleCard({
    super.key,
    required this.index,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.45),
              blurRadius: 20.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bookmark icon + badge
            Row(
              children: [
                GestureDetector(
                  onTap: onFavoriteToggle,
                  child: Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.bookmark,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18.w,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.volunteer_activism,
                        color: Theme.of(context).colorScheme.primary,
                        size: 12.w,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'article.charity_badge'.tr(),
                        style: AppTypography.arabicCaption(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // Title
            Text(
              _articleTitles[index % _articleTitles.length],
              style: AppTypography.arabicTitle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            // Description
            Text(
              _articleDescriptions[index % _articleDescriptions.length],
              style: AppTypography.arabicBody(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12.h),
            // Read button + reading time
            Row(
              children: [
                Text(
                  'article.read_time'.tr(),
                  style: AppTypography.monoCaption(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'article.read'.tr(),
                    style: AppTypography.arabicLabel(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static const List<String> _articleTitles = [
    'فضل طلب العلم وحكمه في الشرع',
    'كيف تجعل علمك صدقة جارية بعد موتك',
    'آداب طلب العلم وآداب العالم والمتعلم',
  ];

  static const List<String> _articleDescriptions = [
    'إن من أفضل ما يتقرب به العبد إلى الله تعالى طلب العلم الشرعي وهو طريق الجنة...',
    'يبقى أثر العلم بعد صاحبه ما بقي من تعلمه أو تعلمه فعلمه، فكيف تؤجر هذا الأجر؟',
    'للعلم آداب ينبغي أن يتحلى بها طالب العلم في طلبه وتحصيله وتعليمه...',
  ];
}
