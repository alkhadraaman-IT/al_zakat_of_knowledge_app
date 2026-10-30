import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_typography.dart';

class AppStudyToolCard extends StatelessWidget {
  final int index;
  final VoidCallback? onTap;

  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  final String title;
  final String subject;
  final String studyYear;
  final String university;
  final String city;
  final String pickupPlace;
  final String pickupNotes;

  final bool isTaken;
  final String? categoryLabel;

  final VoidCallback? onReport;

  // المالك
  final bool isOwner;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  // غير المالك
  final VoidCallback? onTake;

  const AppStudyToolCard({
    super.key,
    required this.index,
    required this.title,
    required this.subject,
    required this.studyYear,
    required this.university,
    required this.city,
    required this.pickupPlace,
    required this.pickupNotes,
    required this.isTaken,
    this.categoryLabel,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onReport,
    this.isOwner = false,
    this.onEdit,
    this.onDelete,
    this.onTake,
  });

  bool get _isAvailable => !isTaken;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final available = _isAvailable;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: available
                ? cs.primary.withValues(alpha: 0.38)
                : cs.outline.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: available
                  ? cs.primary.withValues(alpha: 0.12)
                  : cs.surface.withValues(alpha: 0.45),
              blurRadius: 18.r,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(cs),
            SizedBox(height: 12.h),
            Text(
              title,
              style: AppTypography.arabicTitle(
                color: cs.onSurface,
                fontSize: 16,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            Text(
              subject,
              style: AppTypography.arabicCaption(
                color: cs.onSurfaceVariant,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            if (_hasText(studyYear) || _hasText(university))
              _detailRow(
                cs,
                Icons.school_outlined,
                [studyYear, university].where(_hasText).join(' — '),
              ),
            if (_hasText(city))
              _detailRow(cs, Icons.location_on_outlined, city),
            if (_hasText(pickupPlace))
              _detailRow(cs, Icons.storefront_outlined, pickupPlace),
            if (_hasText(pickupNotes))
              _detailRow(cs, Icons.note_outlined, pickupNotes, maxLines: 2),
            SizedBox(height: 12.h),
            _buildStatusChip(cs, available),
            SizedBox(height: 12.h),
            _buildBottomRow(context, cs, available),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme cs) {
    return Row(
      children: [
        InkWell(
          onTap: onFavoriteToggle,
          borderRadius: BorderRadius.circular(10.r),
          child: Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
            ),
            child: Icon(
              isFavorite ? Icons.bookmark : Icons.bookmark_border,
              color: cs.primary,
              size: 18.w,
            ),
          ),
        ),
        const Spacer(),
        if (_hasText(categoryLabel)) ...[
          _chip(cs, categoryLabel!),
          SizedBox(width: 8.w),
        ],
        if (!isOwner && onReport != null) _reportButton(cs),
      ],
    );
  }

  Widget _reportButton(ColorScheme cs) {
    return Tooltip(
      message: 'report.title'.tr(),
      child: Material(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(10.r),
        child: InkWell(
          onTap: onReport,
          borderRadius: BorderRadius.circular(10.r),
          child: SizedBox(
            width: 36.w,
            height: 36.w,
            child: Icon(Icons.flag_outlined,
                color: cs.onSurfaceVariant, size: 18.w),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ColorScheme cs, bool available) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: available
            ? cs.primary.withValues(alpha: 0.1)
            : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: available ? cs.primary.withValues(alpha: 0.4) : cs.outline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: available ? cs.primary : cs.onSurfaceVariant,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            available ? 'tool.available'.tr() : 'tool.taken'.tr(),
            style: AppTypography.arabicCaption(
              color: available ? cs.primary : cs.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  /// الصف السفلي:
  /// - المالك: [تعديل] [حذف]
  /// - غير المالك + متاحة: [أخذت الأداة] (مع تأكيد)
  /// - غير المالك + مأخوذة: [تم الأخذ] معطل
  Widget _buildBottomRow(BuildContext context, ColorScheme cs, bool available) {
    if (isOwner) {
      return Row(
        children: [
          Expanded(
            child: _actionButton(
              cs: cs,
              label: 'common.edit'.tr(),
              icon: Icons.edit_outlined,
              background: cs.primary,
              foreground: cs.onPrimary,
              onTap: onEdit,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _actionButton(
              cs: cs,
              label: 'common.delete'.tr(),
              icon: Icons.delete_outline,
              background: cs.error.withValues(alpha: 0.12),
              foreground: cs.error,
              onTap: onDelete,
            ),
          ),
        ],
      );
    }

    if (!available) {
      return _disabledTakeButton(cs);
    }

    return _takeButton(context, cs);
  }

  Widget _actionButton({
    required ColorScheme cs,
    required String label,
    required IconData icon,
    required Color background,
    required Color foreground,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: SizedBox(
          height: 44.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foreground, size: 18.w),
              SizedBox(width: 6.w),
              Text(
                label,
                style: AppTypography.arabicTitle(
                  color: foreground,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _takeButton(BuildContext context, ColorScheme cs) {
    return Material(
      color: cs.primary,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTake == null
            ? null
            : () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: cs.surfaceContainerHigh,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    title: Text(
                      'tool.take_confirm_title'.tr(),
                      style: AppTypography.arabicTitle(
                        color: cs.onSurface,
                        fontSize: 17,
                      ),
                    ),
                    content: Text(
                      'tool.take_confirm_message'.tr(),
                      style: AppTypography.arabicBody(
                        color: cs.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(
                          'common.cancel'.tr(),
                          style: AppTypography.arabicLabel(
                            color: cs.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(
                          'tool.take_confirm_yes'.tr(),
                          style: AppTypography.arabicLabel(
                            color: cs.primary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) onTake!();
              },
        child: SizedBox(
          height: 44.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_bag_outlined,
                  color: cs.onPrimary, size: 18.w),
              SizedBox(width: 8.w),
              Text(
                'tool.take_action'.tr(),
                style: AppTypography.arabicTitle(
                  color: cs.onPrimary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _disabledTakeButton(ColorScheme cs) {
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline,
              color: cs.onSurfaceVariant, size: 18.w),
          SizedBox(width: 8.w),
          Text(
            'tool.taken'.tr(),
            style: AppTypography.arabicLabel(
              color: cs.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(ColorScheme cs, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
      ),
      child: Text(text,
          style: AppTypography.arabicCaption(
              color: cs.onSurfaceVariant, fontSize: 11)),
    );
  }

  Widget _detailRow(
    ColorScheme cs,
    IconData icon,
    String text, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: cs.onSurfaceVariant, size: 15.w),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: AppTypography.arabicCaption(
                color: cs.onSurface,
                fontSize: 12,
              ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  static bool _hasText(String? value) =>
      value != null && value.trim().isNotEmpty;
}