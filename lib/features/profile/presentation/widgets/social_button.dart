import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../app/theme/app_typography.dart';

class ProfileSocialButtons extends StatelessWidget {
  final String? cvPdfUrl;
  final String? githubUrl;
  final String? linkedInUrl;
  final Function(String, {bool isPdf}) onOpenUrl;

  const ProfileSocialButtons({
    super.key,
    this.cvPdfUrl,
    this.githubUrl,
    this.linkedInUrl,
    required this.onOpenUrl,
  });

  void _openPdfInternal(BuildContext context, String pdfUrl) {
    String formattedUrl = pdfUrl.trim();
    if (!formattedUrl.startsWith('http://') && !formattedUrl.startsWith('https://')) {
      formattedUrl = 'https://$formattedUrl';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.88,
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'profile.cv'.tr(),
                    style: AppTypography.arabicTitle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    color: Colors.white,
                    child: SfPdfViewer.network(
                      formattedUrl,
                      canShowPaginationDialog: true,
                      pageLayoutMode: PdfPageLayoutMode.continuous,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            icon: Icons.code,
            label: 'GitHub',
            url: githubUrl,
            onTap: githubUrl != null && githubUrl!.isNotEmpty
                ? () => onOpenUrl(githubUrl!)
                : null,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _SocialButton(
            icon: Icons.link,
            label: 'LinkedIn',
            url: linkedInUrl,
            onTap: linkedInUrl != null && linkedInUrl!.isNotEmpty
                ? () => onOpenUrl(linkedInUrl!)
                : null,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _SocialButton(
            icon: Icons.description_outlined,
            label: 'profile.cv'.tr(),
            isPrimary: true,
            url: cvPdfUrl,
            onTap: cvPdfUrl != null && cvPdfUrl!.isNotEmpty
                ? () => _openPdfInternal(context, cvPdfUrl!)
                : null,
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final String? url;
  final VoidCallback? onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    this.isPrimary = false,
    this.url,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = url != null && url!.isNotEmpty;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: isAvailable
              ? primaryColor.withValues(alpha: 0.15)
              : Theme.of(context).colorScheme.surfaceContainerHigh.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isAvailable
                ? primaryColor.withValues(alpha: 0.6)
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
          ),
          boxShadow: isAvailable
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.3),
                    blurRadius: 12.r,
                    spreadRadius: 1.r,
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isAvailable
                  ? primaryColor
                  : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              size: 16.w,
            ),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                label,
                style: AppTypography.arabicCaption(
                  color: isAvailable
                      ? primaryColor
                      : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}