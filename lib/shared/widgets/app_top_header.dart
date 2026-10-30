import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_typography.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/directional_icons.dart';

/// المكون الموحد للشريط العلوي — متوافق مع كافة الاستدعاءات في المشروع
class AppTopHeader extends StatelessWidget {
  final BuildContext context;
  final VoidCallback? onBack;
  final Widget? trailing;

  // بيانات المستخدم الاختيارية لاستخراج الحرف الأول الحقيقي بدلاً من "ع"
  final String? userName;

  const AppTopHeader({
    super.key,
    required this.context,
    this.onBack,
    this.trailing,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // 1. شعار التطبيق (صورة) بجانبه اسم التطبيق وتحته الشعار النصي
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              // color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.1),
                  blurRadius: 10.r,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.asset(
                'assets/images/logo_app.png', // تأكد من مسار شعار التطبيق لديك
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.lightbulb_outline,
                    color: cs.primary,
                    size: 22.w,
                  );
                },
              ),
            ),
          ),
          SizedBox(width: 10.w),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'app.name'.tr(),
                style: AppTypography.arabicTitle(
                  color: cs.onSurface,
                  fontSize: 18,
                ),
              ),
              Text(
                'app.header_tagline'.tr(),
                style: AppTypography.arabicCaption(
                  color: cs.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),

          const Spacer(),

          // 2. العناصر الجانبية (Trailing) إن وجدت (مثل الإشعارات والملف الشخصي في الرئيسية)
          if (trailing != null) ...[trailing!],

          // 3. زر الرجوع إن وجد (في الواجهات الفرعية)
          if (onBack != null) ...[
            if (trailing != null) SizedBox(width: 8.w),
            Material(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12.r),
              child: InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(12.r),
                child: SizedBox(
                  width: 40.w,
                  height: 40.w,
                  child: Icon(DirectionalIcons.forward(context),
                    color: cs.onSurface,
                    size: 24.w,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
