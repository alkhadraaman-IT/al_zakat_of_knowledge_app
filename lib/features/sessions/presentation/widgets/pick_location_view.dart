import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/directional_icons.dart';

/// صفحة اختيار موقع المحاضرة على الخريطة.
/// علامة ثابتة في منتصف الشاشة: يحرّك المستخدم الخريطة تحتها ثم يضغط "تأكيد".
/// تعيد [LatLng] عند التأكيد، أو null إن رجع المستخدم دون تأكيد.
class PickLocationPage extends StatefulWidget {
  /// الموقع المختار سابقاً (عند التعديل)، وإلا تبدأ الخريطة من [_fallbackCenter].
  final LatLng? initial;

  const PickLocationPage({super.key, this.initial});

  @override
  State<PickLocationPage> createState() => _PickLocationPageState();
}

class _PickLocationPageState extends State<PickLocationPage> {
  /// دمشق. غيّرها إلى المدينة التي تريد أن تبدأ منها الخريطة.
  static const LatLng _fallbackCenter = LatLng(33.5138, 36.2765);

  final MapController _controller = MapController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    Navigator.pop(context, _controller.camera.center);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasInitial = widget.initial != null;

    return Scaffold(
      appBar: AppBar(
        // The automatic Material back button always points left, which is wrong
        // for Arabic — pick the icon from the ambient direction instead.
        leading: IconButton(
          icon: Icon(DirectionalIcons.back(context)),
          onPressed: () => Navigator.maybePop(context),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        ),
        title: Text(
          'create.location_prompt'.tr(),
          style: AppTypography.arabicBody(color: cs.onSurface, fontSize: 18),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _controller,
            options: MapOptions(
              initialCenter: widget.initial ?? _fallbackCenter,
              initialZoom: hasInitial ? 16 : 14,
              minZoom: 3,
              maxZoom: 19,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}', // مطلوب من سياسة استخدام OpenStreetMap: اسم حزمة التطبيق.
                userAgentPackageName: 'com.example.al_zakat_of_knowledge_app',
                maxNativeZoom: 19,
              ),
            ],
          ),

          // العلامة الثابتة في المنتصف (رأسها السفلي هو الموقع المختار).
          IgnorePointer(
            child: Center(
              child: Transform.translate(
                offset: Offset(0, -24.w),
                child: Icon(Icons.location_on, size: 48.w, color: cs.primary),
              ),
            ),
          ),

          // إسناد OpenStreetMap (مطلوب).
          Positioned(
            left: 8.w,
            bottom: 96.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                '© OpenStreetMap · © CARTO',
                style: TextStyle(fontSize: 10.sp, color: cs.onSurfaceVariant),
              ),
            ),
          ),

          // زر التأكيد.
          Positioned(
            left: 16.w,
            right: 16.w,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Material(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(16.r),
                  child: InkWell(
                    onTap: _confirm,
                    borderRadius: BorderRadius.circular(16.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Center(
                        child: Text(
                          'create.confirm_location'.tr(),
                          style: AppTypography.arabicBody(
                            color: cs.onPrimary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
