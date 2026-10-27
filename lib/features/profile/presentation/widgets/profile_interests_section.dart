import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';

class ProfileInterestsSection extends StatelessWidget {
  final bool isLoadingCategories;
  final List<Map<String, dynamic>> categories;
  final Set<String> selectedCategoryIds;
  final String? userId;
  final Function(String catId, bool isSelected) onCategoryToggled;

  const ProfileInterestsSection({
    super.key,
    required this.isLoadingCategories,
    required this.categories,
    required this.selectedCategoryIds,
    required this.userId,
    required this.onCategoryToggled,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isArabic = context.locale.languageCode == 'ar';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'profile.interests'.tr(),
            style: AppTypography.arabicTitle(
              color: colorScheme.onSurface,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 12.h),
          isLoadingCategories
              ? const Center(child: CircularProgressIndicator())
              : categories.isEmpty
                  ? Text(
                      'لا توجد تصنيفات متاحة',
                      style: AppTypography.arabicBody(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    )
                  : Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: categories.map((category) {
                        final catId = category['id'].toString();
                        final catName = isArabic
                            ? (category['name_ar'] ?? '')
                            : (category['name_en'] ?? '');
                        final isSelected = selectedCategoryIds.contains(catId);

                        return GestureDetector(
                          onTap: () => onCategoryToggled(catId, isSelected),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colorScheme.primary.withValues(alpha: 0.15)
                                  : colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: isSelected
                                    ? colorScheme.primary.withValues(alpha: 0.5)
                                    : colorScheme.outline,
                              ),
                            ),
                            child: Text(
                              catName,
                              style: AppTypography.arabicLabel(
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
        ],
      ),
    );
  }
}