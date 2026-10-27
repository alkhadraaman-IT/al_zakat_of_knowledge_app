import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_typography.dart';

/// Study tool card — Stitch Design System (Tab 3: أدوات دراسية).
///
/// Renders the demo content when only [index] is supplied; pass the real
/// material values ([title], [subject], ...) to render an actual
/// `StudyToolEntity`. Real cards are display-only — `is_taken` is toggled
/// through the backend RPC, so no local action button is rendered for them.
///
/// هذا الكرت الوحيد لعرض الأدوات (Home + StudyTools + Favorites).
/// الحقول الاختيارية [kind] و [categoryLabel] و [pickupNotes] و [onReport]
/// كانت موجودة فقط بنسخة مكررة داخل StudyToolsView.
class AppStudyToolCard extends StatelessWidget {
  final int index;
  final VoidCallback? onTap;

  /// Favorite state for real materials. When
  /// [onFavoriteToggle] is provided the bookmark
  /// icon becomes interactive.
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  /// Real material values — when [title] is non-null the card renders
  /// the actual material instead of the demo content.
  final String? title;
  final String? subject;
  final String? studyYear;
  final String? university;
  final String? city;
  final String? pickupPlace;
  final String? pickupNotes;

  /// Mirrors the material's `is_taken` column.
  final bool? isTaken;

  /// book | stationery | notes | other — يحدد الأيقونة وشارة النوع.
  final String? kind;

  /// اسم التصنيف (شارة بأعلى الكرت).
  final String? categoryLabel;

  /// إذا كان غير null يظهر زر الإبلاغ.
  final VoidCallback? onReport;

  const AppStudyToolCard({
    super.key,
    required this.index,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.title,
    this.subject,
    this.studyYear,
    this.university,
    this.city,
    this.pickupPlace,
    this.pickupNotes,
    this.isTaken,
    this.kind,
    this.categoryLabel,
    this.onReport,
  });

  /// True when real material values are supplied.
  bool get hasRealData => title != null;

  /// الحالة تُشتق من البيانات فقط (لا State محلي ولا setState):
  /// الحقيقي من is_taken، والتجريبي يتناوب حسب [index].
  bool get _isAvailable => hasRealData ? !(isTaken ?? false) : index % 2 == 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDemo = !hasRealData;
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
              isDemo ? _toolTitles[index % _toolTitles.length] : title!,
              style: AppTypography.arabicTitle(
                color: cs.onSurface,
                fontSize: 16,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            Text(
              isDemo
                  ? _toolDescriptions[index % _toolDescriptions.length]
                  : (subject ?? ''),
              style: AppTypography.arabicCaption(
                color: cs.onSurfaceVariant,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (!isDemo) ...[
              SizedBox(height: 8.h),
              if (_hasText(studyYear) || _hasText(university))
                _detailRow(
                  cs,
                  Icons.school_outlined,
                  [studyYear, university].where(_hasText).join(' — '),
                ),
              if (_hasText(city))
                _detailRow(cs, Icons.location_on_outlined, city!),
              if (_hasText(pickupPlace))
                _detailRow(cs, Icons.storefront_outlined, pickupPlace!),
              if (_hasText(pickupNotes))
                _detailRow(cs, Icons.note_outlined, pickupNotes!, maxLines: 2),
            ],
            SizedBox(height: 12.h),
            _buildFooter(cs, isDemo, available),
          ],
        ),
      ),
    );
  }

  /// Bookmark + (category chip) + (report) + kind icon.
  Widget _buildHeader(ColorScheme cs) {
    return Row(
      children: [
        InkWell(
          onTap: onFavoriteToggle, // null-safe (كان onFavoriteToggle!())
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
        if (onReport != null) ...[
          Tooltip(
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
                  child: Icon(
                    Icons.flag_outlined,
                    color: cs.onSurfaceVariant,
                    size: 18.w,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
          ),
          child: Icon(_kindIcon(kind), color: cs.onSurfaceVariant, size: 18.w),
        ),
      ],
    );
  }

  /// Status chip (+ kind chip للأدوات الحقيقية).
  Widget _buildFooter(ColorScheme cs, bool isDemo, bool available) {
    final status = Container(
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

    final kindName = _kindName(kind);

    return Row(
      children: [
        // Demo cards show a placeholder pickup time when taken.
        if (isDemo && !available) ...[
          Icon(Icons.schedule, color: cs.onSurfaceVariant, size: 14.w),
          SizedBox(width: 4.w),
          Text(
            '٢ أكتوبر ٨:٣٠ م',
            style: AppTypography.monoCaption(
              color: cs.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
        if (kindName != null) ...[
          status,
          const Spacer(),
          _chip(cs, kindName),
        ] else ...[
          const Spacer(),
          status,
        ],
      ],
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
      child: Text(
        text,
        style: AppTypography.arabicCaption(
          color: cs.onSurfaceVariant,
          fontSize: 11,
        ),
      ),
    );
  }

  /// Real-material detail line — leading icon + text.
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

  /// اسم النوع محلياً، أو null إذا ما انمرر نوع.
  static String? _kindName(String? kind) {
    switch (kind) {
      case null:
        return null;
      case 'book':
        return 'tool.kind_book'.tr();
      case 'stationery':
        return 'tool.kind_stationery'.tr();
      case 'notes':
        return 'tool.kind_notes'.tr();
      case 'other':
        return 'tool.kind_other'.tr();
      default:
        return kind;
    }
  }

  static IconData _kindIcon(String? kind) {
    switch (kind) {
      case 'book':
        return Icons.book_outlined;
      case 'stationery':
        return Icons.brush_outlined;
      case 'notes':
        return Icons.article_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
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
