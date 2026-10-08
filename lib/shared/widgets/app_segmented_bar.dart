import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_typography.dart';

/// Reusable segmented category bar — Stitch Design System.
/// Used across Home, Search, Favorites, and Profile screens.
class AppSegmentedBar extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final List<IconData>? icons;

  const AppSegmentedBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onTabChanged,
    this.icons,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final isSelected = index == selectedIndex;
          final icon = icons != null && index < icons!.length ? icons![index] : null;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
                            blurRadius: 14.r,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 16.w,
                      ),
                      SizedBox(width: 6.w),
                    ],
                    Flexible(
                      child: Text(
                        labels[index],
                        style: AppTypography.arabicLabel(
                          color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
