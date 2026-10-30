import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/session_entity.dart';

Future<void> showSessionShareSheet(BuildContext context, SessionEntity session) async {
  final cs = Theme.of(context).colorScheme;
  final shareUrl = 'https://alkhadraaman-it.github.io/zakat_landing/?id=${session.id}';
  final when = session.startsAt.isNotEmpty ? session.startsAt : '';
  final where = [session.placeName, session.city].where((e) => e.isNotEmpty).join('، ');

  final message = [
    '${session.title} — ${'app.name'.tr()}',
    if (when.isNotEmpty) '📅 $when',
    if (where.isNotEmpty) '📍 $where',
    shareUrl,
  ].join('\n');

  Future<void> launchExternal(BuildContext ctx, String url) async {
    try {
      final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (!ok && ctx.mounted) {
        await Clipboard.setData(ClipboardData(text: message));
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('share.copied'.tr())));
      }
    } catch (_) {
      if (ctx.mounted) {
        await Clipboard.setData(ClipboardData(text: message));
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('share.copied'.tr())));
      }
    }
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: cs.surfaceContainerLow,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
    builder: (sheetCtx) {
      final sheetCs = Theme.of(sheetCtx).colorScheme;
      return Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal, AppSpacing.sm, AppSpacing.screenHorizontal,
          AppSpacing.xl + MediaQuery.of(sheetCtx).viewPadding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40.w, height: 4.h,
                decoration: BoxDecoration(color: sheetCs.outline.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(999.r)),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Text('share.title'.tr(), style: AppTypography.arabicTitle(color: sheetCs.onSurface, fontSize: 17), textAlign: TextAlign.center),
            SizedBox(height: AppSpacing.md),
            Center(
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: sheetCs.primary, width: 2),
                ),
                child: QrImageView(
                  data: shareUrl, size: 168.w, backgroundColor: Colors.white,
                  dataModuleStyle: const QrDataModuleStyle(color: Color(0xFF0B1120)),
                  eyeStyle: const QrEyeStyle(color: Color(0xFF0B1120)),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _shortcut(cs: sheetCs, icon: Icons.chat, label: 'share.whatsapp'.tr(), color: const Color(0xFF25D366),
                  onTap: () { Navigator.pop(sheetCtx); launchExternal(context, 'https://api.whatsapp.com/send?text=${Uri.encodeComponent(message)}'); }),
                SizedBox(width: AppSpacing.sm),
                _shortcut(cs: sheetCs, icon: Icons.send, label: 'share.telegram'.tr(), color: const Color(0xFF229ED9),
                  onTap: () { Navigator.pop(sheetCtx); launchExternal(context, 'https://t.me/share/url?url=${Uri.encodeComponent(shareUrl)}&text=${Uri.encodeComponent(message)}'); }),
                SizedBox(width: AppSpacing.sm),
                _shortcut(cs: sheetCs, icon: Icons.email_outlined, label: 'share.email'.tr(), color: sheetCs.primary,
                  onTap: () { Navigator.pop(sheetCtx); launchExternal(context, 'mailto:?subject=${Uri.encodeComponent(session.title)}&body=${Uri.encodeComponent(message)}'); }),
                SizedBox(width: AppSpacing.sm),
                _shortcut(cs: sheetCs, icon: Icons.link, label: 'share.copy_link'.tr(), color: sheetCs.secondary,
                  onTap: () async {
                    Navigator.pop(sheetCtx);
                    await Clipboard.setData(ClipboardData(text: shareUrl));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('share.copied'.tr()), backgroundColor: cs.primary));
                  }),
              ],
            ),
          ],
        ),
      );
    },
  );
}

Widget _shortcut({required ColorScheme cs, required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
  return Expanded(
    child: Material(
      color: cs.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22.w),
              SizedBox(height: 6.h),
              Text(label, style: AppTypography.arabicLabel(color: cs.onSurfaceVariant, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    ),
  );
}