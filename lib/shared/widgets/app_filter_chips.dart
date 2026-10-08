import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_typography.dart';

/// Reusable filter chips row — Stitch Design System.
/// Stateful local UI selection with dummy data (database wiring pending).
class AppFilterChips extends StatefulWidget {
  final List<String> labels;
  final int initialSelected;
  final ValueChanged<int>? onSelectionChanged;

  const AppFilterChips({
    super.key,
    required this.labels,
    this.initialSelected = 0,
    this.onSelectionChanged,
  });

  @override
  State<AppFilterChips> createState() => _AppFilterChipsState();
}

class _AppFilterChipsState extends State<AppFilterChips> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelected;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: widget.labels.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final isSelected = index == _selectedIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
              widget.onSelectionChanged?.call(index);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                    : Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                      : Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Text(
                widget.labels[index],
                style: AppTypography.arabicLabel(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
