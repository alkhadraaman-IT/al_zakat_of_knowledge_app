import 'package:al_zakat_of_knowledge_app/app/theme/app_typography.dart';
import 'package:al_zakat_of_knowledge_app/features/reports/presentation/widgets/report_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../features/favorites/presentation/cubit/favorites_cubit.dart';
import '../../features/favorites/presentation/cubit/toggle_cubit.dart';

/// كرت مقالة. بدون بيانات افتراضية (title و body مطلوبين)،
/// وبدون setState: حالة "اقرأ المزيد" بـ [ToggleCubit] محلي.
class AppArticleCard extends StatelessWidget {
  final String title;
  final String body;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  /// إذا كان غير null يظهر زر الإبلاغ.
  final String? articleId;

  /// بديل عن شاشة الإبلاغ الافتراضية.
  final VoidCallback? onReport;

  const AppArticleCard({
    super.key,
    required this.title,
    required this.body,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.articleId,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (_) => ToggleCubit(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: cs.outline.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: cs.surface.withValues(alpha: 0.45),
                blurRadius: 20.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, cs),
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
              SizedBox(height: 8.h),
              _ExpandableBody(body: body),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  /// قلب المفضلة + شارة الصدقة + زر الإبلاغ.
  Widget _buildHeader(BuildContext context, ColorScheme cs) {
    return Row(
      children: [
        InkWell(
          onTap: onFavoriteToggle,
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
              color: isFavorite ? cs.primary : cs.onSurfaceVariant,
              size: 18.w,
            ),
          ),
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.volunteer_activism, color: cs.primary, size: 12.w),
              SizedBox(width: 4.w),
Text(
                'article.charity_badge'.tr(),
                style: AppTypography.arabicCaption(
                  color: cs.primary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        if (articleId != null) ...[
          SizedBox(width: 8.w),
          Tooltip(
            message: 'report.title'.tr(),
            child: Material(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(12.r),
              child: InkWell(
                onTap: () {
                  if (onReport != null) {
                    onReport!();
                  } else {
                    showReportSheet(
                      context: context,
                      targetType: 'article',
                      targetId: articleId!,
                    );
                  }
                },
                borderRadius: BorderRadius.circular(12.r),
                child: SizedBox(
                  width: 40.w,
                  height: 40.w,
                  child: Icon(
                    Icons.flag_outlined,
                    color: cs.onSurfaceVariant,
                    size: 20.w,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// نص المقالة مع "اقرأ المزيد / أقل" — الحالة من [ToggleCubit].
class _ExpandableBody extends StatelessWidget {
  final String body;
  const _ExpandableBody({required this.body});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bodyStyle = AppTypography.arabicBody(
      color: cs.onSurfaceVariant,
      fontSize: 13,
    );

    return BlocBuilder<ToggleCubit, bool>(
      builder: (context, isExpanded) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedCrossFade(
              firstChild: Text(
                body,
                style: bodyStyle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              secondChild: Text(body, style: bodyStyle),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
            SizedBox(height: 4.h),
            TextButton(
              onPressed: () => context.read<ToggleCubit>().toggle(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                isExpanded
                    ? 'article.show_less'.tr()
                    : 'article.read_more'.tr(),
                style: AppTypography.arabicLabel(
                  color: cs.primary,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
