import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_typography.dart';

/// Study tool card — Stitch Design System (Tab 3: أدوات دراسية).
/// Features: bookmark icon, package icon, title, description, status chip, action button.
class AppStudyToolCard extends StatefulWidget {
  final int index;
  final VoidCallback? onTap;

  const AppStudyToolCard({
    super.key,
    required this.index,
    this.onTap,
  });

  @override
  State<AppStudyToolCard> createState() => _AppStudyToolCardState();
}

class _AppStudyToolCardState extends State<AppStudyToolCard> {
  late bool _isAvailable;

  @override
  void initState() {
    super.initState();
    // Alternate between available and taken for demo
    _isAvailable = widget.index % 2 == 0;
  }

  void _toggleAvailability() {
    setState(() {
      _isAvailable = !_isAvailable;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: _isAvailable
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.38)
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _isAvailable
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
                  : Theme.of(context).colorScheme.surface.withValues(alpha: 0.45),
              blurRadius: 18.r,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bookmark + package icons
            Row(
              children: [
                Container(
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
                    Icons.bookmark,
                    color: Theme.of(context).colorScheme.primary,
                    size: 18.w,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 18.w,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // Title
            Text(
              _toolTitles[widget.index % _toolTitles.length],
              style: AppTypography.arabicTitle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            // Description
            Text(
              _toolDescriptions[widget.index % _toolDescriptions.length],
              style: AppTypography.arabicCaption(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12.h),
            // Status chip
            Row(
              children: [
                if (!_isAvailable) ...[
                  Icon(
                    Icons.schedule,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 14.w,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '٢ أكتوبر ٨:٣٠ م',
                    style: AppTypography.monoCaption(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                ] else
                  const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _isAvailable
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: _isAvailable
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.4)
                          : Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          color: _isAvailable
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        _isAvailable ? 'tool.available'.tr() : 'tool.taken'.tr(),
                        style: AppTypography.arabicCaption(
                          color: _isAvailable
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // Action button
            GestureDetector(
              onTap: _toggleAvailability,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: _isAvailable ? Theme.of(context).colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                  border: _isAvailable
                      ? null
                      : Border.all(color: Theme.of(context).colorScheme.outline),
                  boxShadow: _isAvailable
                      ? [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
                            blurRadius: 14.r,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isAvailable ? Icons.check : Icons.undo,
                        color: _isAvailable
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 16.w,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        _isAvailable ? 'tool.mark_taken'.tr() : 'tool.make_available'.tr(),
                        style: AppTypography.arabicLabel(
                          color: _isAvailable
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<String> _toolTitles = [
    'حقيبة طالب العلم — ٥ كتب علمية',
    'مصحف مجلد — نسخة فاخرة',
  ];

  static const List<String> _toolDescriptions = [
    'مجموعة كتب مطبوعة للمتون في أصول العلم',
    'مصحف طباعة واضحة وإهداء للمتدبر',
  ];
}
