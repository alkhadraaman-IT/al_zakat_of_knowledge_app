import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/syrian_cities.dart';
import '../../../../core/utils/directional_icons.dart';
import '../../../articles/domain/entities/category_entity.dart';
import '../../../articles/presentation/cubit/categories_cubit.dart';

// ─────────────────────────────────────────────
// 1) Text Field
// ─────────────────────────────────────────────
class SessionFormTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const SessionFormTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.validator,
    this.inputFormatters,
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
          readOnly: readOnly,
          onTap: onTap,
          inputFormatters: inputFormatters,
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
class SessionCityDropdown extends StatelessWidget {
  final String? selectedCity;
  final ValueChanged<String?> onChanged;

  const SessionCityDropdown({
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
          'create.city_label'.tr(),
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
                'create.city_hint'.tr(),
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
// 3) Category Dropdown
// ─────────────────────────────────────────────
class SessionCategoryDropdown extends StatelessWidget {
  final int? selectedCategoryId;
  final ValueChanged<int?> onChanged;

  const SessionCategoryDropdown({
    super.key,
    required this.selectedCategoryId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'create.category_label'.tr(),
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
          child: BlocBuilder<CategoriesCubit, List<CategoryEntity>>(
            builder: (context, categories) {
              if (categories.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  child: Center(
                    child: SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.primary,
                      ),
                    ),
                  ),
                );
              }
              return DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: categories.any((c) => c.id == selectedCategoryId)
                      ? selectedCategoryId
                      : null,
                  isExpanded: true,
                  hint: Text(
                    'create.category_hint'.tr(),
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
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// 4) Location Picker
// ─────────────────────────────────────────────
class SessionLocationPicker extends StatelessWidget {
  final LatLng? picked;
  final VoidCallback onTap;

  const SessionLocationPicker({
    super.key,
    required this.picked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasLocation = picked != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: hasLocation ? cs.primary : cs.outline.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasLocation
                  ? Icons.check_circle
                  : Icons.add_location_alt_outlined,
              color: hasLocation ? cs.primary : cs.onSurfaceVariant,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                hasLocation
                    ? 'create.location_set'.tr()
                    : 'create.location_hint'.tr(),
                style: AppTypography.arabicBody(
                  color: cs.onSurface,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(
              DirectionalIcons.forward(context),
              color: cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 5) DateTime Picker
// ─────────────────────────────────────────────
class SessionDateTimePicker extends StatelessWidget {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const SessionDateTimePicker({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onDateChanged,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final dateText = selectedDate == null
        ? null
        : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';
    final timeText = selectedTime?.format(context);

    return Row(
      children: [
        Expanded(
          child: _pickerCard(
            context: context,
            icon: Icons.calendar_today_outlined,
            label: 'create.date_label'.tr(),
            value: dateText,
            hint: 'create.date_hint'.tr(),
            onTap: () async {
              final now = DateTime.now();
              final initial =
                  (selectedDate != null && !selectedDate!.isBefore(now))
                      ? selectedDate!
                      : now.add(const Duration(days: 1));
              final picked = await showDatePicker(
                context: context,
                initialDate: initial,
                firstDate: now,
                lastDate: now.add(const Duration(days: 365)),
              );
              if (picked != null) onDateChanged(picked);
            },
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _pickerCard(
            context: context,
            icon: Icons.access_time_outlined,
            label: 'create.time_label'.tr(),
            value: timeText,
            hint: 'create.time_hint'.tr(),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: selectedTime ?? TimeOfDay.now(),
              );
              if (picked != null) onTimeChanged(picked);
            },
          ),
        ),
      ],
    );
  }

  Widget _pickerCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String? value,
    required String hint,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    final hasValue = value != null && value.isNotEmpty;
    final displayText = hasValue ? value : hint;
    final displayColor = hasValue
        ? cs.onSurface
        : cs.onSurfaceVariant.withValues(alpha: 0.5);
    final iconColor = hasValue ? cs.primary : cs.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.arabicLabel(color: cs.onSurface, fontSize: 14),
        ),
        SizedBox(height: 8.h),
        Material(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12.r),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: hasValue ? cs.primary : cs.outline,
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, color: iconColor, size: 20.w),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      displayText,
                      style: AppTypography.arabicBody(
                        color: displayColor,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}