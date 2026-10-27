import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_typography.dart';

/// Shared session/lecture card — كرت الجلسة المشترك المحدث بشعار التطبيق وصورة المستخدم.
class AppSessionCard extends StatelessWidget {
  final String sessionId;
  final String title;
  final String lecturerName;
  final String lecturerInitial;
  final String? lecturerPhotoUrl; // صورة المستخدم أو المحاضر
  final String dateLabel;
  final String timeLabel;
  final String locationLabel;
  final String mapPillLabel;
  final double capacityFactor;
  final String percentLabel;
  final String seatsLabel;
  final String? ctaLabel;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  
  final double? lat;
  final double? lng;

  const AppSessionCard({
    super.key,
    required this.sessionId,
    this.title = 'أصول الفقه العظيم — المجلس الثالث',
    this.lecturerName = 'د. سعد العتيبي',
    this.lecturerInitial = 'د',
    this.lecturerPhotoUrl,
    this.dateLabel = 'السبت، ١٠ أكتوبر',
    this.timeLabel = 'بعد المغرب',
    this.locationLabel = 'مسجد الراجحي — الرياض',
    this.mapPillLabel = 'مسجد الراجحي — الرياض',
    this.capacityFactor = 0.6,
    this.percentLabel = '60%',
    this.seatsLabel = '18/30',
    this.ctaLabel,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.lat,
    this.lng,
  });

  Future<void> _openInMaps(double? latitude, double? longitude, String fallbackQuery) async {
    String url;
    if (latitude != null && longitude != null) {
      url = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
    } else {
      if (fallbackQuery.isEmpty) return;
      url = 'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(fallbackQuery)}';
    }
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => context.push('/session-details/$sessionId'),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: cs.primary.withValues(alpha: 0.38),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.12),
              blurRadius: 18.r,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── معاينة بصرية بديلة مستقرة بشعار التطبيق ────────────────
            _buildAppBrandHeaderPreview(cs, mapPillLabel),
            
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.arabicTitle(
                            color: cs.onSurface,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          onFavoriteToggle?.call();
                        },
                        child: Container(
                          width: 36.w,
                          height: 36.w,
                          decoration: BoxDecoration(
                            color: isFavorite
                                ? cs.primary.withValues(alpha: 0.15)
                                : cs.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isFavorite
                                  ? cs.primary
                                  : cs.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Icon(
                            isFavorite
                                ? Icons.bookmark
                                : Icons.bookmark_outline,
                            color: cs.primary,
                            size: 20.w,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      // ── صورة المستخدم أو الحرف الأول من اسمه ────────────────
                      Container(
                        width: 28.w,
                        height: 28.w,
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: cs.primary.withValues(alpha: 0.4),
                          ),
                        ),
                        child: ClipOval(
                          child: (lecturerPhotoUrl != null && lecturerPhotoUrl!.isNotEmpty)
                              ? Image.network(
                                  lecturerPhotoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Center(
                                    child: Text(
                                      lecturerInitial.isNotEmpty ? lecturerInitial[0] : 'د',
                                      style: AppTypography.arabicLabel(
                                        color: cs.primary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    lecturerInitial.isNotEmpty ? lecturerInitial[0] : 'د',
                                    style: AppTypography.arabicLabel(
                                      color: cs.primary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        lecturerName,
                        style: AppTypography.arabicBody(
                          color: cs.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: cs.onSurfaceVariant,
                        size: 16.w,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        dateLabel,
                        style: AppTypography.arabicCaption(
                          color: cs.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '•',
                        style: AppTypography.arabicCaption(
                          color: cs.outline,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.schedule,
                        color: cs.onSurfaceVariant,
                        size: 16.w,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        timeLabel,
                        style: AppTypography.arabicCaption(
                          color: cs.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: cs.onSurfaceVariant,
                        size: 16.w,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          locationLabel,
                          style: AppTypography.arabicCaption(
                            color: cs.onSurfaceVariant,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _CapacityBar(
                    cs: cs,
                    factor: capacityFactor,
                    percentLabel: percentLabel,
                    seatsLabel: seatsLabel,
                  ),
                  SizedBox(height: 16.h),
                  _CTAButton(
                    cs: cs,
                    label: ctaLabel ?? 'search.book_seat'.tr(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// رأس البطاقة البديل: يدمج شعار التطبيق مع خلفية متناسقة ونظيفة بدلاً من خريطة المعاينة المسببة للمشاكل
  Widget _buildAppBrandHeaderPreview(ColorScheme cs, String pillLabel) {
    return Container(
      height: 120.h,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border(
          bottom: BorderSide(color: cs.primary.withValues(alpha: 0.2)),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // خلفية جمالية متدرجة
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    cs.primary.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                  radius: 0.8,
                ),
              ),
            ),
          ),
          // شعار التطبيق (بدل أيقونة القبعة القديمة)
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: cs.primary.withValues(alpha: 0.4), width: 1.5),
            ),
            child: Icon(
              Icons.school_rounded, // شعار أو أيقونة معبرة عن التطبيق والجلسات العلمية
              color: cs.primary,
              size: 28.w,
            ),
          ),
          Positioned(
            bottom: 12.h,
            left: 16.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: cs.outline.withValues(alpha: 0.6)),
              ),
              child: Text(
                pillLabel,
                style: AppTypography.arabicCaption(
                  color: cs.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CapacityBar extends StatelessWidget {
  final ColorScheme cs;
  final double factor;
  final String percentLabel;
  final String seatsLabel;

  const _CapacityBar({
    required this.cs,
    required this.factor,
    required this.percentLabel,
    required this.seatsLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              percentLabel,
              style: AppTypography.monoLabel(color: cs.primary, fontSize: 12),
            ),
            Text(
              seatsLabel,
              style: AppTypography.monoCaption(
                color: cs.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Container(
          height: 8.h,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerRight,
            widthFactor: factor.clamp(0.0, 1.0).toDouble(),
            child: Container(
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(4.r),
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.5),
                    blurRadius: 10.r,
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

class _CTAButton extends StatelessWidget {
  final ColorScheme cs;
  final String label;

  const _CTAButton({required this.cs, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.35),
            blurRadius: 18.r,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: AppTypography.arabicTitle(color: cs.onPrimary, fontSize: 16),
        ),
      ),
    );
  }
}