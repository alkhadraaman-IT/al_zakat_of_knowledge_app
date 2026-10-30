import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/session_entity.dart';

class SessionMapCard extends StatelessWidget {
  final SessionEntity session;
  const SessionMapCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final hasLocation = session.lat != null && session.lng != null;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16.r),
        border: isLight ? Border.all(color: cs.outline.withValues(alpha: 0.3)) : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (hasLocation)
            _buildRealMap(cs, session.lat!, session.lng!)
          else
            Container(
              height: 176.h,
              color: cs.surfaceContainerLowest,
              child: Center(
                child: Icon(Icons.location_off, color: cs.onSurfaceVariant, size: 40.w),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 36.w, height: 36.w,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.place_outlined, color: cs.primary, size: 20.w),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.placeName,
                        style: AppTypography.arabicTitle(color: cs.onSurface, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        session.city,
                        style: AppTypography.arabicBody(color: cs.onSurfaceVariant, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Tooltip(
                      message: 'session.copy_location'.tr(),
                      child: Material(
                        color: cs.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(10.r),
                        child: InkWell(
                          onTap: () => _copyLocation(context),
                          borderRadius: BorderRadius.circular(10.r),
                          child: SizedBox(
                            width: 36.w, height: 36.w,
                            child: Icon(Icons.copy_rounded, color: cs.primary, size: 17.w),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Material(
                      color: cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(10.r),
                      child: InkWell(
                        onTap: () => _openInMaps(),
                        borderRadius: BorderRadius.circular(10.r),
                        child: SizedBox(
                          height: 36.w,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('session.directions'.tr(), style: AppTypography.arabicLabel(color: cs.primary, fontSize: 12)),
                                SizedBox(width: 4.w),
                                Icon(Icons.directions, color: cs.primary, size: 15.w),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealMap(ColorScheme cs, double lat, double lng) {
    final point = LatLng(lat, lng);
    return SizedBox(
      height: 176.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: point,
              initialZoom: 15,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
              onTap: (_, _) => _openInMaps(),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.example.al_zakat_of_knowledge_app',
                maxNativeZoom: 19,
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: point, width: 48.w, height: 48.w,
                    alignment: Alignment.topCenter,
                    child: Icon(Icons.location_on, color: cs.primary, size: 40.w),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            right: 8.w, bottom: 6.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text('© Esri', style: TextStyle(fontSize: 10.sp, color: cs.onSurfaceVariant)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openInMaps() async {
    String url;
    if (session.lat != null && session.lng != null) {
      url = 'https://www.google.com/maps/dir/?api=1&destination=${session.lat},${session.lng}';
    } else {
      final query = [session.placeName, session.city].where((e) => e.isNotEmpty).join(' ');
      if (query.isEmpty) return;
      url = 'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(query)}';
    }
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> _copyLocation(BuildContext context) async {
    final label = [session.placeName, session.city].where((e) => e.isNotEmpty).join('، ');
    String? url;
    if (session.lat != null && session.lng != null) {
      url = 'https://www.google.com/maps/search/?api=1&query=${session.lat},${session.lng}';
    } else if (label.isNotEmpty) {
      url = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(label)}';
    }
    if (url == null) return;

    final text = label.isEmpty ? url : '📍 $label\n$url';
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('session.location_copied'.tr()),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}