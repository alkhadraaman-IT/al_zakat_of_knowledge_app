import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/syrian_cities.dart';
import '../cubit/search_cubit.dart';

class SearchFilterBottomSheet extends StatefulWidget {
  final SearchCubit cubit;
  const SearchFilterBottomSheet({super.key, required this.cubit});

  @override
  State<SearchFilterBottomSheet> createState() =>
      _SearchFilterBottomSheetState();
}

class _SearchFilterBottomSheetState extends State<SearchFilterBottomSheet> {
  String? _selectedCategory;
  String? _selectedLocation;
  bool? _isAvailable;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.cubit.category;
    _selectedLocation = widget.cubit.location;
    _isAvailable = widget.cubit.isAvailable;
    _selectedDate = widget.cubit.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedTab = widget.cubit.selectedTab;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
        left: AppSpacing.screenHorizontal,
        right: AppSpacing.screenHorizontal,
        top: AppSpacing.md,
      ),
      constraints: BoxConstraints(maxHeight: 520.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'search.filter.title'.tr(),
                style: AppTypography.arabicTitle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: _buildFilterContent(context, selectedTab),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = null;
                      _selectedLocation = null;
                      _isAvailable = null;
                      _selectedDate = null;
                    });
                    widget.cubit.clearFilters();
                  },
                  child: Text('search.filter.clear'.tr()),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    widget.cubit.applyFilters(
                      category: _selectedCategory,
                      selectedDate: _selectedDate,
                      location: _selectedLocation,
                      isAvailable: _isAvailable,
                    );
                    Navigator.pop(context);
                  },
                  child: Text('search.filter.apply'.tr()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterContent(BuildContext context, int selectedTab) {
    if (selectedTab == 0) return _buildSessionsFilterSheet(context);
    if (selectedTab == 1) return _buildArticlesFilterSheet(context);
    return _buildToolsFilterSheet(context);
  }

  Widget _buildSessionsFilterSheet(BuildContext context) {
    final categoryIds = widget.cubit.categories.map((c) => c.id).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            Icons.calendar_today,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            'search.filter.date'.tr(),
            style: AppTypography.arabicBody(fontSize: 14),
          ),
          trailing: Text(
            _selectedDate != null
                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                : 'search.filter.select_date'.tr(),
            style: AppTypography.arabicBody(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 12,
            ),
          ),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) setState(() => _selectedDate = picked);
          },
        ),
        const Divider(),
        Text(
          'search.filter.location'.tr(),
          style: AppTypography.arabicCaption(fontSize: 12),
        ),
        SizedBox(height: 6.h),
        DropdownButtonFormField<String?>(
          initialValue: _selectedLocation,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: 'search.filter.location_hint'.tr(),
            border: const OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 8.h,
            ),
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(
                'search.filter.all'.tr(),
                style: AppTypography.arabicBody(fontSize: 14),
              ),
            ),
            ...SyrianCities.all.map(
              (gov) => DropdownMenuItem<String?>(
                value: gov,
                child: Text(gov, style: AppTypography.arabicBody(fontSize: 14)),
              ),
            ),
          ],
          onChanged: (val) => setState(() => _selectedLocation = val),
        ),
        if (categoryIds.isNotEmpty) ...[
          const Divider(),
          Text(
            'search.filter.category'.tr(),
            style: AppTypography.arabicCaption(fontSize: 12),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: categoryIds.map((catId) {
              final isSelected = _selectedCategory == catId.toString();
              return _filterChip(
                context,
                _categoryLabel(context, catId),
                isSelected,
                () => setState(
                  () =>
                      _selectedCategory = isSelected ? null : catId.toString(),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildArticlesFilterSheet(BuildContext context) {
    final categoryIds = widget.cubit.categories.map((c) => c.id).toList();

    if (categoryIds.isEmpty) {
      return Text(
        'search.filter.no_filters_article'.tr(),
        style: AppTypography.arabicBody(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 14,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'search.filter.category'.tr(),
          style: AppTypography.arabicCaption(fontSize: 12),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: categoryIds.map((catId) {
            final isSelected = _selectedCategory == catId.toString();
            return _filterChip(
              context,
              _categoryLabel(context, catId),
              isSelected,
              () => setState(
                () => _selectedCategory = isSelected ? null : catId.toString(),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildToolsFilterSheet(BuildContext context) {
    final categoryIds =
      widget.cubit.categories.map((c) => c.id).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'search.filter.availability'.tr(),
          style: AppTypography.arabicCaption(fontSize: 12),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _filterChip(
              context,
              'search.filter.all'.tr(),
              _isAvailable == null,
              () => setState(() => _isAvailable = null),
            ),
            _filterChip(
              context,
              'search.filter.available'.tr(),
              _isAvailable == true,
              () => setState(() => _isAvailable = true),
            ),
            _filterChip(
              context,
              'search.filter.taken'.tr(),
              _isAvailable == false,
              () => setState(() => _isAvailable = false),
            ),
          ],
        ),
        if (categoryIds.isNotEmpty) ...[
          const Divider(),
          Text(
            'search.filter.category'.tr(),
            style: AppTypography.arabicCaption(fontSize: 12),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: categoryIds.map((catId) {
              final isSelected = _selectedCategory == catId.toString();
              return _filterChip(
                context,
                _categoryLabel(context, catId),
                isSelected,
                () => setState(
                  () =>
                      _selectedCategory = isSelected ? null : catId.toString(),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _filterChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final cs = Theme.of(context).colorScheme;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: cs.primary.withValues(alpha: 0.1),
      backgroundColor: cs.surface,
      checkmarkColor: cs.primary,
      labelStyle: AppTypography.arabicBody(
        color: isSelected ? cs.primary : cs.onSurface,
        fontSize: 12,
      ),
    );
  }

  String _categoryLabel(BuildContext context, int catId) {
    for (final category in widget.cubit.categories) {
      if (category.id == catId) {
        return category.nameFor(context.locale.languageCode);
      }
    }
    return '$catId';
  }
}
