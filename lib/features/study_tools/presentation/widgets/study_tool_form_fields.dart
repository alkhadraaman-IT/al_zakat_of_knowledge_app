import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/syrian_cities.dart';
import '../../../articles/domain/entities/category_entity.dart';
import '../../../articles/presentation/cubit/categories_cubit.dart';

/// قائمة أنواع الأدوات المدعومة (ثابتة في مكان واحد)
const List<String> kStudyToolKinds = [
  'book',
  'stationery',
  'notes',
  'other',
];

// ─────────────────────────────────────────────
// 1) Text Field
// ─────────────────────────────────────────────
class StudyToolTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const StudyToolTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.arabicLabel(color: cs.onSurface, fontSize: 14),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: AppTypography.arabicBody(color: cs.onSurface, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.arabicBody(
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
              fontSize: 16,
            ),
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

// ─────────────────────────────────────────────
// 2) City Dropdown
// ─────────────────────────────────────────────
class StudyToolCityDropdown extends StatelessWidget {
  final String? selectedCity;
  final ValueChanged<String?> onChanged;

  const StudyToolCityDropdown({
    super.key,
    required this.selectedCity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'tool.city_label'.tr(),
          style: AppTypography.arabicLabel(color: cs.onSurface, fontSize: 14),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: cs.outline),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCity,
              isExpanded: true,
              hint: Text(
                'tool.city_hint'.tr(),
                style: AppTypography.arabicBody(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  fontSize: 16,
                ),
              ),
              items: SyrianCities.all.map((city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Text(
                    city,
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
  }
}

// ─────────────────────────────────────────────
// 3) Category Dropdown (يقرأ من CategoriesCubit)
// ─────────────────────────────────────────────
class StudyToolCategoryDropdown extends StatelessWidget {
  final int? selectedCategoryId;
  final ValueChanged<int?> onChanged;

  const StudyToolCategoryDropdown({
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
            Text(
              'tool.category_label'.tr(),
              style: AppTypography.arabicLabel(
                color: cs.onSurface,
                fontSize: 14,
              ),
            ),
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
                    'tool.category_hint'.tr(),
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

// ─────────────────────────────────────────────
// 4) Kind Dropdown
// ─────────────────────────────────────────────
class StudyToolKindDropdown extends StatelessWidget {
  final String selectedKind;
  final ValueChanged<String?> onChanged;

  const StudyToolKindDropdown({
    super.key,
    required this.selectedKind,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'tool.kind_label'.tr(),
          style: AppTypography.arabicLabel(color: cs.onSurface, fontSize: 14),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: cs.outline),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedKind,
              isExpanded: true,
              items: kStudyToolKinds.map((kind) {
                return DropdownMenuItem<String>(
                  value: kind,
                  child: Text(
                    'tool.kind_$kind'.tr(),
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
  }
}