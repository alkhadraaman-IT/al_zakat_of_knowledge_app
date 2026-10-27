import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/profile_media_service.dart';
import '../../../auth/data/models/profile_model.dart';
import '../../../auth/domain/usecases/get_current_profile_usecase.dart';
import '../../../auth/domain/usecases/update_profile_usecase.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// Shows the Edit Profile sheet with all seven
/// client-writable profile fields from the backend
/// specification (`ProfileModel.toUpdateJson()`):
/// name, university, city, linkedin_url, github_url,
/// cv_pdf_url and photo_url.
///
/// Photos and CV PDFs are compressed and size-checked
/// by [ProfileMediaService] before uploading to the
/// `avatars` / `cvs` storage buckets.
Future<void> showEditProfileSheet(
  BuildContext context, {
  ValueChanged<String>? onNameSaved,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (_) => _EditProfileSheetContent(onNameSaved: onNameSaved),
  );
}

class _EditProfileSheetContent extends StatefulWidget {
  final ValueChanged<String>? onNameSaved;

  const _EditProfileSheetContent({this.onNameSaved});

  @override
  State<_EditProfileSheetContent> createState() =>
      _EditProfileSheetContentState();
}

class _EditProfileSheetContentState extends State<_EditProfileSheetContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _universityController = TextEditingController();
  final _cityController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _githubController = TextEditingController();

  ProfileModel? _profile;
  String? _photoUrl;
  String? _cvPdfUrl;

  /// Local avatar path — set the moment a photo is
  /// picked so the circle shows an immediate preview
  /// before the upload runs on Save.
  String? _localPhotoPath;

  /// Local CV path — set the moment a PDF is picked
  /// so its upload can run on Save.
  String? _localCvPath;

  /// Name of the selected CV file (e.g. `my_cv.pdf`)
  /// — displayed in the CV row as soon as the
  /// file is picked.
  String? _cvFileName;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _universityController.dispose();
    _cityController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    super.dispose();
  }

  /// Loads the logged-in user's profile row
  /// (fresh fetch with a local-cache fallback).
  Future<void> _loadProfile() async {
    final result = await sl<GetCurrentProfileUseCase>()();
    final profile = result.fold<ProfileModel?>(
      (_) => null,
      (entity) => entity == null
          ? null
          : (entity is ProfileModel ? entity : ProfileModel.fromEntity(entity)),
    );
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _photoUrl = profile?.photoUrl;
      _cvPdfUrl = profile?.cvPdfUrl;
      _nameController.text = profile?.name ?? '';
      _universityController.text = profile?.university ?? '';
      _cityController.text = profile?.city ?? '';
      _linkedinController.text = profile?.linkedinUrl ?? '';
      _githubController.text = profile?.githubUrl ?? '';
      _isLoading = false;
    });
  }

  /// Builds the update payload — only the seven
  /// client-writable fields are sent to the backend
  /// (see `ProfileModel.toUpdateJson()`).
  ProfileModel _buildProfile() {
    final base = _profile;
    return ProfileModel(
      id: base?.id ?? _resolveUserId(),
      name: _nameController.text.trim(),
      photoUrl: _photoUrl,
      linkedinUrl: _linkedinController.text.trim(),
      githubUrl: _githubController.text.trim(),
      cvPdfUrl: _cvPdfUrl,
      university: _universityController.text.trim(),
      city: _cityController.text.trim(),
      createdAt: base?.createdAt ?? DateTime.now(),
    );
  }

  /// Fallback user id when the profile row could
  /// not be loaded — taken from the auth state.
  String _resolveUserId() {
    final state = context.read<AuthCubit>().state;
    if (state is AuthAuthenticated) return state.user.id;
    return '';
  }

  Future<void> _save() async {
    print('<<<<<<<<<<<[_save Profile Started]>>>>>>>>>>>>>');
    if (!(_formKey.currentState?.validate() ?? false)) {
      // Trace why Save may not execute — an
      // invalid form returns silently.
      print('<<<<<<<<<<<[_save Profile Invalid Form]>>>>>>>>>>>>>');
      return;
    }
    setState(() => _isSaving = true);
    try {
      // Upload the freshly picked avatar to the
      // `avatars` bucket — its public URL joins
      // the profiles update payload.
      if (_localPhotoPath != null) {
        final avatarUpload =
            await sl<ProfileMediaService>().uploadAvatar(_localPhotoPath!);
        if (!mounted) return;
        if (avatarUpload.status != MediaUploadStatus.success) {
          setState(() => _isSaving = false);
          _showError(avatarUpload.status == MediaUploadStatus.tooLarge
              ? 'profile.image_too_large'.tr()
              : (avatarUpload.errorMessage ?? 'profile.upload_failed'.tr()));
          return;
        }
        setState(() {
          _photoUrl = avatarUpload.url;
          _localPhotoPath = null;
        });
      }

      // Upload the freshly picked CV to the `cvs`
      // bucket — its public URL joins the profiles
      // update payload.
      if (_localCvPath != null) {
        final cvUpload =
            await sl<ProfileMediaService>().uploadCv(_localCvPath!);
        if (!mounted) return;
        if (cvUpload.status != MediaUploadStatus.success) {
          setState(() => _isSaving = false);
          _showError(cvUpload.status == MediaUploadStatus.tooLarge
              ? 'profile.cv_too_large'.tr()
              : (cvUpload.errorMessage ?? 'profile.upload_failed'.tr()));
          return;
        }
        setState(() {
          _cvPdfUrl = cvUpload.url;
          _localCvPath = null;
        });
      }

      final result = await sl<UpdateProfileUseCase>()(_buildProfile());
      if (!mounted) return;
      setState(() => _isSaving = false);

      result.fold(
        (failure) => _showError(failure.message),
        (updated) {
          widget.onNameSaved?.call(updated.name);
          // Re-check the auth status so the updated
          // user / profile syncs globally across screens.
          context.read<AuthCubit>().checkAuthStatus();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('profile.update_success'.tr()),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          Navigator.pop(context);
        },
      );
    } catch (e) {
      // Silent-exception guard — any unexpected
      // error (network / storage / file system)
      // is logged and the saving state is reset
      // so the Save button stays responsive.
      print('<<<<<<<<<<<[_save Profile Error]>>>>>>>>>>>>>');
      print('Exception: $e');
      if (!mounted) return;
      setState(() => _isSaving = false);
      // The dialog shows the exact exception so
      // the failure cause stays readable.
      _showError('$e');
    }
  }

  Future<void> _pickPhoto() async {
    final localPath = await sl<ProfileMediaService>().pickAvatar();
    if (!mounted) return;
    if (localPath == null) return; // the picker was dismissed
    // Immediate local preview — the state is set
    // before any upload (which runs on Save).
    setState(() => _localPhotoPath = localPath);
  }

  Future<void> _pickCv() async {
    final picked = await sl<ProfileMediaService>().pickCv();
    if (!mounted) return;
    if (picked == null) return; // the picker was dismissed
    // Immediate file feedback — the selected file
    // name and the pending upload state are set
    // before any upload (which runs on Save).
    setState(() {
      _localCvPath = picked.path;
      _cvFileName = picked.fileName;
    });
  }

  /// Spec validation: name is 1–80 characters.
  String? _validateName(String? value) {
    final name = (value ?? '').trim();
    if (name.isEmpty) return 'profile.name_required'.tr();
    if (name.length > 80) return 'profile.name_too_long'.tr();
    return null;
  }

  /// Spec validation: URLs are at most 300 characters.
  String? _validateUrl(String? value) {
    final url = (value ?? '').trim();
    if (url.length > 300) return 'profile.url_too_long'.tr();
    return null;
  }

  /// Explicit error dialog — shown when the profile
  /// save or a media upload fails, so the exact
  /// failure message (e.g. the Supabase storage
  /// error or the RLS denial) stays readable
  /// instead of vanishing with a SnackBar.
  /// The caller resets `_isSaving` first so
  /// Save can be retried.
  void _showError(String message) {
    print('<<<<<<<<<<<[_save Profile Error Dialog]>>>>>>>>>>>>>');
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor:
            Theme.of(dialogContext).colorScheme.surfaceContainerLow,
        title: Text('profile.error'.tr()),
        content: SingleChildScrollView(
          child: Text(message),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('profile.ok'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.screenHorizontal,
          right: AppSpacing.screenHorizontal,
          top: AppSpacing.md,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
        ),
        child: _isLoading
            ? SizedBox(
                height: 120.h,
                child: Center(
                  child: CircularProgressIndicator(color: cs.primary),
                ),
              )
            : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        'profile.edit_profile'.tr(),
                        style: AppTypography.arabicTitle(
                          color: cs.onSurface,
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg),
                      _buildPhotoRow(cs),
                      SizedBox(height: AppSpacing.md),
                      _buildTextField(
                        controller: _nameController,
                        label: 'profile.name_label'.tr(),
                        maxLength: 80,
                        validator: _validateName,
                      ),
                      SizedBox(height: AppSpacing.md),
                      _buildTextField(
                        controller: _universityController,
                        label: 'profile.university_label'.tr(),
                        maxLength: 120,
                      ),
                      SizedBox(height: AppSpacing.md),
                      _buildTextField(
                        controller: _cityController,
                        label: 'profile.city_label'.tr(),
                        maxLength: 120,
                      ),
                      SizedBox(height: AppSpacing.md),
                      _buildTextField(
                        controller: _linkedinController,
                        label: 'profile.linkedin_label'.tr(),
                        maxLength: 300,
                        keyboardType: TextInputType.url,
                        validator: _validateUrl,
                      ),
                      SizedBox(height: AppSpacing.md),
                      _buildTextField(
                        controller: _githubController,
                        label: 'profile.github_label'.tr(),
                        maxLength: 300,
                        keyboardType: TextInputType.url,
                        validator: _validateUrl,
                      ),
                      SizedBox(height: AppSpacing.md),
                      _buildCvRow(cs),
                      SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor: cs.onPrimary,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: _isSaving
                              ? SizedBox(
                                  height: 18.w,
                                  width: 18.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: cs.onPrimary,
                                  ),
                                )
                              : Text('profile.save'.tr()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  /// Avatar row — preview, status, pick and remove.
  Widget _buildPhotoRow(ColorScheme cs) {
    final hasPhoto = _photoUrl != null && _photoUrl!.isNotEmpty;
    final hasLocalPhoto =
        _localPhotoPath != null && _localPhotoPath!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'profile.photo_label'.tr(),
          style: AppTypography.arabicLabel(color: cs.onSurface, fontSize: 13),
        ),
        SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            // Tappable avatar — opens the gallery picker
            // to upload a new photo. Shows the picked
            // image immediately (local preview), then the
            // uploaded URL once it lands.
            GestureDetector(
              onTap: _pickPhoto,
              child: Stack(
                children: [
                  ClipOval(
                    child: Container(
                      width: 60.r,
                      height: 60.r,
                      color: cs.surfaceContainerHigh,
                      child: hasLocalPhoto
                          ? Image.file(
                              File(_localPhotoPath!),
                              fit: BoxFit.cover,
                            )
                          : hasPhoto
                              ? Image.network(
                                  _photoUrl!,
                                  fit: BoxFit.cover,
                                )
                              : Icon(
                                  Icons.person_outline,
                                  color: cs.onSurfaceVariant,
                                  size: 28.w,
                                ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: cs.surfaceContainerLow,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt_outlined,
                        color: cs.onPrimary,
                        size: 12.w,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                hasPhoto || hasLocalPhoto
                    ? 'profile.photo_set'.tr()
                    : 'profile.photo_not_set'.tr(),
                style: AppTypography.arabicCaption(
                  color: cs.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
            TextButton(
              onPressed: _pickPhoto,
              child: Text('profile.choose_photo'.tr()),
            ),
            if (hasPhoto || hasLocalPhoto)
              IconButton(
                onPressed: () => setState(() {
                  _photoUrl = null;
                  _localPhotoPath = null;
                }),
                icon: Icon(Icons.delete_outline, color: cs.error, size: 20.w),
              ),
          ],
        ),
      ],
    );
  }

  /// CV row — status, pick and remove.
  Widget _buildCvRow(ColorScheme cs) {
    final hasCv = _cvPdfUrl != null && _cvPdfUrl!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'profile.cv_label'.tr(),
          style: AppTypography.arabicLabel(color: cs.onSurface, fontSize: 13),
        ),
        SizedBox(height: AppSpacing.sm),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf, color: cs.primary, size: 20.w),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  // The selected file name (e.g.
                  // `my_cv.pdf`) once a PDF is chosen.
                  _cvFileName != null && _cvFileName!.isNotEmpty
                      ? _cvFileName!
                      : hasCv
                          ? 'profile.cv_set'.tr()
                          : 'profile.cv_not_set'.tr(),
                  style: AppTypography.arabicCaption(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ),
              TextButton(
                onPressed: _pickCv,
                child: Text('profile.choose_cv'.tr()),
              ),
              if (hasCv || _cvFileName != null)
                IconButton(
                  onPressed: () => setState(() {
                    _cvPdfUrl = null;
                    _cvFileName = null;
                    _localCvPath = null;
                  }),
                  icon: Icon(Icons.delete_outline, color: cs.error, size: 20.w),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Spec-styled labeled text field.
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLength = 300,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final cs = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTypography.arabicBody(color: cs.onSurface, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        filled: true,
        fillColor: cs.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: cs.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: cs.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: cs.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: cs.error),
        ),
      ),
    );
  }
}
