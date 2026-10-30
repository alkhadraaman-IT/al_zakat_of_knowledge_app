import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../articles/domain/entities/category_entity.dart';
import '../../../articles/presentation/cubit/categories_cubit.dart';

/// حقل نصي مخصص للمقالات
class ArticleTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final String? Function(String?)? validator;

  const ArticleTextField({
    super.key,
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.arabicLabel(color: cs.onSurface, fontSize: 14)),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: AppTypography.arabicBody(color: cs.onSurface, fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: cs.surfaceContainerLow,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: cs.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: cs.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: cs.primary, width: 1.5),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}

/// قائمة التصنيفات المنسدلة للمقالات
class ArticleCategoryDropdown extends StatelessWidget {
  final int? selectedCategoryId;
  final ValueChanged<int?> onChanged;

  const ArticleCategoryDropdown({
    super.key,
    required this.selectedCategoryId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BlocBuilder<CategoriesCubit, List<CategoryEntity>>(
      builder: (context, categories) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('article.category_label'.tr(),
                style: AppTypography.arabicLabel(
                    color: cs.onSurface, fontSize: 14)),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: cs.outline),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: categories.any((c) => c.id == selectedCategoryId)
                      ? selectedCategoryId
                      : null,
                  isExpanded: true,
                  hint: Text(
                    'article.category_hint'.tr(),
                    style: AppTypography.arabicBody(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                      fontSize: 16,
                    ),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(
                        category.nameFor(context.locale.languageCode),
                        style: AppTypography.arabicBody(
                          color: cs.onSurface,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}