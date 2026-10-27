import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import 'edit_profile_sheet.dart';
import 'social_button.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final String city;
  final String university;
  final String? photoUrl;
  final String? cvPdfUrl;
  final String? githubUrl;
  final String? linkedInUrl;
  final bool isOwnerProfile;
  final VoidCallback onProfileUpdated;
  final Function(String, {bool isPdf}) onOpenUrl;

  const ProfileCard({
    super.key,
    required this.name,
    required this.email,
    required this.city,
    required this.university,
    this.photoUrl,
    this.cvPdfUrl,
    this.githubUrl,
    this.linkedInUrl,
    required this.isOwnerProfile,
    required this.onProfileUpdated,
    required this.onOpenUrl,
  });

  void _openPdfInternal(BuildContext context, String pdfUrl) {
    String formattedUrl = pdfUrl.trim();
    if (!formattedUrl.startsWith('http://') &&
        !formattedUrl.startsWith('https://')) {
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
    final detailsList = [
      city,
      university,
      email,
    ].where((e) => e.trim().isNotEmpty).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary
                  .withValues(alpha: 0.1),
              blurRadius: 24.r,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primaryContainer,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary
                            .withValues(alpha: 0.4),
                        blurRadius: 16.r,
                      ),
                    ],
                  ),
                  child: photoUrl != null && photoUrl!.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            photoUrl!,
                            width: 64.w,
                            height: 64.w,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Center(
                          child: Text(
                            name.trim().isNotEmpty ? name.trim()[0] : 'ع',
                            style: AppTypography.arabicDisplay(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 28,
                            ),
                          ),
                        ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTypography.arabicHeadline(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 20,
                        ),
                      ),
                      if (detailsList.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          detailsList.join(' • '),
                          style: AppTypography.arabicBody(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isOwnerProfile)
                  GestureDetector(
                    onTap: () async {
                      await showEditProfileSheet(context, onNameSaved: (_) {});
                      onProfileUpdated();
                    },
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(
                        Icons.edit_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20.w,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 20.h),
            ProfileSocialButtons(
              cvPdfUrl: cvPdfUrl,
              githubUrl: githubUrl,
              linkedInUrl: linkedInUrl,
              onOpenUrl: onOpenUrl,
            ),
          ],
        ),
      ),
    );
  }
}
