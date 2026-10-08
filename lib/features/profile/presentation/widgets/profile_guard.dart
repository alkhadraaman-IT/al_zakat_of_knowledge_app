import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/domain/entities/profile_entity.dart';
import '../../../auth/domain/usecases/get_current_profile_usecase.dart';
import 'edit_profile_sheet.dart';

/// Publishing guard — verifies the logged-in user's
/// profile carries the essential fields (university,
/// city, and a LinkedIn or CV link) before a session
/// or material is published.
///
/// Returns `true` when publishing may proceed. When the
/// profile is incomplete, a localized dialog prompts the
/// user with a quick action that opens the Edit Profile
/// sheet. Lookup errors never block publishing.
Future<bool> ensureProfileComplete(BuildContext context) async {
  final result = await sl<GetCurrentProfileUseCase>()();
  if (!context.mounted) return true;

  final isComplete = result.fold<bool>(
    (_) => true,
    (entity) => _isPublishingReady(entity),
  );
  if (isComplete) return true;

  await showDialog<void>(
    context: context,
    builder: (dialogCtx) {
      final cs = Theme.of(dialogCtx).colorScheme;
      return AlertDialog(
        backgroundColor: cs.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'profile_guard.title'.tr(),
          style: AppTypography.arabicTitle(color: cs.onSurface, fontSize: 17),
        ),
        content: Text(
          'profile_guard.message'.tr(),
          style: AppTypography.arabicBody(
            color: cs.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              showEditProfileSheet(context);
            },
            child: Text('profile_guard.action'.tr()),
          ),
        ],
      );
    },
  );

  return false;
}

/// Essential publishing fields per the backend
/// specification: university, city, and at least
/// one verification link (LinkedIn or CV).
bool _isPublishingReady(ProfileEntity? profile) {
  return profile != null &&
      (profile.university?.isNotEmpty ?? false) &&
      (profile.city?.isNotEmpty ?? false) &&
      ((profile.linkedinUrl?.isNotEmpty ?? false) ||
          (profile.cvPdfUrl?.isNotEmpty ?? false));
}
