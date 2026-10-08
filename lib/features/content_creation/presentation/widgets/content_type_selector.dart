import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_typography.dart';
import 'create_article_sheet.dart';
import 'create_material_sheet.dart';
import 'create_session_sheet.dart';

/// Content type selector bottom sheet.
void showContentTypeSelector(BuildContext context) {
  final cs = Theme.of(context).colorScheme;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w, height: 4.h,
              margin: EdgeInsets.only(bottom: 20.h),
              decoration: BoxDecoration(color: cs.outline, borderRadius: BorderRadius.circular(2.r)),
            ),
            Text('انشر صدقتك العلمية', style: AppTypography.arabicHeadline(color: cs.onSurface, fontSize: 20)),
            SizedBox(height: 8.h),
            Text('اختر نوع المحتوى', style: AppTypography.arabicBody(color: cs.onSurfaceVariant, fontSize: 14)),
            SizedBox(height: 24.h),
            _Option(
              icon: Icons.groups_3,
              title: 'محاضرة / جلسة علمية',
              description: 'حدد المكان والمقاعد',
              cs: cs,
              onTap: () { Navigator.pop(context); showCreateSessionSheet(context); },
            ),
            SizedBox(height: 12.h),
            _Option(
              icon: Icons.article_outlined,
              title: 'مقالة نافعة',
              description: 'شارك علمك كصدقة جارية',
              cs: cs,
              onTap: () { Navigator.pop(context); showCreateArticleSheet(context); },
            ),
            SizedBox(height: 12.h),
            _Option(
              icon: Icons.inventory_2_outlined,
              title: 'أداة أو مادة دراسية',
              description: 'أدوات وكتب مجانية',
              cs: cs,
              onTap: () { Navigator.pop(context); showCreateMaterialSheet(context); },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      );
    },
  );
}

class _Option extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final ColorScheme cs;
  final VoidCallback onTap;

  const _Option({required this.icon, required this.title, required this.description, required this.cs, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(children: [
            Container(
              width: 48.w, height: 48.w,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
              ),
              child: Icon(icon, color: cs.primary, size: 24.w),
            ),
            SizedBox(width: 12.w),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: AppTypography.arabicTitle(color: cs.onSurface, fontSize: 16)),
              SizedBox(height: 2.h),
              Text(description, style: AppTypography.arabicCaption(color: cs.onSurfaceVariant, fontSize: 12)),
            ])),
            Icon(Icons.chevron_left, color: cs.onSurfaceVariant, size: 20.w),
          ]),
        ),
      ),
    );
  }
}
