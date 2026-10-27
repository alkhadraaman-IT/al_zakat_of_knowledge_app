import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_typography.dart';

class AppSessionCard extends StatelessWidget {
  final String sessionId;
  final String title;
  final String lecturerName;
  final String lecturerInitial;
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
  
  final dynamic lat;
  final dynamic lng;
  
  final String? noteLabel; // 👈 حقل جديد للملاحظة
  final VoidCallback? onTap; // 👈 حقل جديد للتحكم بحدث النقر

  const AppSessionCard({
    super.key,
    required this.sessionId,
    required this.title,
    required this.lecturerName,
    required this.lecturerInitial,
    required this.dateLabel,
    required this.timeLabel,
    required this.locationLabel,
    required this.mapPillLabel,
    required this.capacityFactor,
    required this.percentLabel,
    required this.seatsLabel,
    this.ctaLabel,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.lat,
    this.lng,
    this.noteLabel,
    this.onTap,
  });

  static double? _parseCoordinate(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    final raw = value.toString().trim();
    if (raw.isEmpty) return null;
    return double.tryParse(raw.replaceAll(',', '.'));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    final double? parsedLat = _parseCoordinate(lat);
    final double? parsedLng = _parseCoordinate(lng);

    return GestureDetector(
      // 👈 استخدام onTap المخصص إذا وجد، وإلا الانتقال للصفحة الافتراضية
      onTap: onTap ?? () => context.push('/session-details/$sessionId'),
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
            if (parsedLat != null && parsedLng != null)
              _buildRealMapPreview(cs, parsedLat, parsedLng, mapPillLabel)
            else
              _buildPlaceholderMap(cs, isLight),

            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ... (باقي كود العنوان والمحاضر والتواريخ كما هو بدون تغيير) ...
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.arabicTitle(color: cs.onSurface, fontSize: 17),
                        ),
                      ),
                      InkWell(
                        onTap: () => onFavoriteToggle?.call(),
                        child: Container(
                          width: 36.w,
                          height: 36.w,
                          decoration: BoxDecoration(
                            color: isFavorite ? cs.primary.withValues(alpha: 0.15) : cs.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: isFavorite ? cs.primary : cs.primary.withValues(alpha: 0.2)),
                          ),
                          child: Icon(isFavorite ? Icons.bookmark : Icons.bookmark_outline, color: cs.primary, size: 20.w),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: cs.primary.withValues(alpha: 0.5)),
                        ),
                        child: Center(
                          child: Text(
                            lecturerInitial.isNotEmpty ? lecturerInitial[0] : 'د',
                            style: AppTypography.arabicLabel(color: cs.primary, fontSize: 14),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(lecturerName, style: AppTypography.arabicBody(color: cs.onSurfaceVariant, fontSize: 14)),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, color: cs.onSurfaceVariant, size: 16.w),
                      SizedBox(width: 8.w),
                      Text(dateLabel, style: AppTypography.arabicCaption(color: cs.onSurfaceVariant, fontSize: 12)),
                      SizedBox(width: 8.w),
                      Text('•', style: AppTypography.arabicCaption(color: cs.outline, fontSize: 12)),
                      SizedBox(width: 8.w),
                      Icon(Icons.schedule, color: cs.onSurfaceVariant, size: 16.w),
                      SizedBox(width: 8.w),
                      Text(timeLabel, style: AppTypography.arabicCaption(color: cs.onSurfaceVariant, fontSize: 12)),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: cs.onSurfaceVariant, size: 16.w),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(locationLabel, style: AppTypography.arabicCaption(color: cs.onSurfaceVariant, fontSize: 12), overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _CapacityBar(cs: cs, factor: capacityFactor, percentLabel: percentLabel, seatsLabel: seatsLabel),
                  
                  // 👈 عرض الملاحظة إذا كانت موجودة
                  if (noteLabel != null) ...[
                    SizedBox(height: 12.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: cs.error, size: 16.w),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            noteLabel!,
                            style: AppTypography.arabicCaption(color: cs.error, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ],

                  SizedBox(height: 16.h),
                  _CTAButton(cs: cs, label: ctaLabel ?? 'search.book_seat'.tr()),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ... (باقي دوال الخريطة _buildRealMapPreview و _buildPlaceholderMap كما هي بدون تغيير) ...
  Widget _buildRealMapPreview(ColorScheme cs, double latitude, double longitude, String pillLabel) {
    final point = LatLng(latitude, longitude);
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      child: SizedBox(
        height: 144.h,
        child: IgnorePointer(
          child: Stack(
            fit: StackFit.expand,
            children: [
              FlutterMap(
                key: ValueKey('card_map_$sessionId-$latitude-$longitude'),
                options: MapOptions(
                  initialCenter: point,
                  initialZoom: 15.0,
                  interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.al_zakat_of_knowledge_app',
                    maxNativeZoom: 19,
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: point,
                        width: 40.w,
                        height: 40.w,
                        alignment: Alignment.topCenter,
                        child: Icon(Icons.location_on, color: cs.primary, size: 36.w),
                      ),
                    ],
                  ),
                ],
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
                    style: AppTypography.arabicCaption(color: cs.onSurfaceVariant, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderMap(ColorScheme cs, bool isLight) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      child: SizedBox(
        height: 144.h,
        child: Container(
          color: cs.surfaceContainerLowest,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
                  child: Icon(Icons.location_on, color: cs.onPrimary, size: 18.w),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CapacityBar extends StatelessWidget {
  final ColorScheme cs;
  final double factor;
  final String percentLabel;
  final String seatsLabel;

  const _CapacityBar({required this.cs, required this.factor, required this.percentLabel, required this.seatsLabel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(percentLabel, style: AppTypography.monoLabel(color: cs.primary, fontSize: 12)),
            Text(seatsLabel, style: AppTypography.monoCaption(color: cs.onSurfaceVariant, fontSize: 12)),
          ],
        ),
        SizedBox(height: 6.h),
        Container(
          height: 8.h,
          decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(4.r)),
          child: FractionallySizedBox(
            alignment: Alignment.centerRight,
            widthFactor: factor.clamp(0.0, 1.0).toDouble(),
            child: Container(decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(4.r))),
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
      decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(16.r)),
      child: Center(
        child: Text(label, style: AppTypography.arabicTitle(color: cs.onPrimary, fontSize: 16)),
      ),
    );
  }
}