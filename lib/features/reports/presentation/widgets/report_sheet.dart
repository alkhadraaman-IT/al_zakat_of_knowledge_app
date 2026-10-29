import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../shared/widgets/success_dialog.dart';
import '../../domain/usecases/create_report_usecase.dart';

// Helper method to show a SnackBar message — used by both showReportSheet and _ReportSheetState.
void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Theme.of(context).colorScheme.error,
    ),
  );
}

/// Unified report sheet for reporting any content type:
/// sessions (lectures), study_tools, articles.
///
/// Fields:
/// - Reason (radio group: content, schedule, inaccurate, other)
/// - Additional details (text field, required when "Other" selected)
///
/// On success: shows localized success toast.
/// On failure: shows localized error SnackBar, returns `false`.
Future<bool> showReportSheet({
  required BuildContext context,
  required String targetType, // 'session' | 'study_tool' | 'article'
  required String targetId,
}) async {
  final reported = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ReportSheet(targetType: targetType, targetId: targetId),
  );

  // Report submitted successfully — show localized success toast.
  if (reported == true && context.mounted) {
    _showMessage(context, 'report.success'.tr());
  }

  return reported ?? false;
}

class _ReportSheet extends StatefulWidget {
  final String targetType; // 'session' | 'study_tool' | 'article'
  final String targetId;

  const _ReportSheet({
    required this.targetType,
    required this.targetId,
  });

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  static const List<String> _reasonKeys = [
    'report.reason_content',
    'report.reason_schedule',
    'report.reason_inaccurate',
    'report.reason_other',
  ];

  String? _selectedReasonKey;
  final _detailsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedReasonKey == null) return;

    final reporterId = _resolveReporterId();
    if (reporterId == null) {
      _showMessage(context, 'report.error_auth'.tr());
      return;
    }

    setState(() => _isSubmitting = true);

    final reason = _selectedReasonKey!;
    final details = _selectedReasonKey == 'report.reason_other'
        ? _detailsController.text.trim()
        : null;

    final result = await sl<CreateReportUseCase>()(
      reporterId: reporterId,
      targetType: widget.targetType,
      targetId: widget.targetId,
      reason: reason,
      details: details,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold(
      (failure) => _showMessage(context, _friendlyError(failure)),
      (_) => Navigator.pop(context, true),
    );
  }

  String? _resolveReporterId() {
    final state = context.read<AuthCubit>().state;
    if (state is AuthAuthenticated) return state.user.id;
    return null;
  }

  String _friendlyError(Failure failure) {
    if (failure is NetworkFailure) {
      return 'report.error_offline'.tr();
    }
    if (failure.code == '23503') {
      return 'report.error_invalid_target'.tr();
    }
    if (failure.code == '42501') {
      return 'report.error_permission'.tr();
    }
    // Handle null code or unknown codes — show permission error if it's a reporter mismatch
    if (failure.code == null && failure.message.contains('Reporter ID mismatch')) {
      return 'report.error_permission'.tr();
    }
    return 'report.error_submit'.tr();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.all(20.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 20.h),
                decoration: BoxDecoration(
                  color: cs.outline,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Text(
                'report.title'.tr(),
                style: AppTypography.arabicHeadline(
                  color: cs.onSurface,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'report.choose_reason'.tr(),
                style: AppTypography.arabicCaption(
                  color: cs.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 12.h),
              // Reason radio options
              RadioGroup<String>(
                groupValue: _selectedReasonKey,
                onChanged: (value) => setState(() => _selectedReasonKey = value),
                child: Column(
                  children: _reasonKeys.map(
                    (option) => Material(
                      color: Colors.transparent,
                      child: RadioListTile<String>(
                        value: option,
                        activeColor: cs.primary,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        title: Text(
                          option.tr(),
                          style: AppTypography.arabicBody(
                            color: cs.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ).toList(),
                ),
              ),
              // Additional details when "Other" is selected
              if (_selectedReasonKey == 'report.reason_other')
                Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: TextField(
                    controller: _detailsController,
                    maxLines: 3,
                    minLines: 2,
                    style: AppTypography.arabicBody(
                      color: cs.onSurface,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'report.details_hint'.tr(),
                      hintStyle: AppTypography.arabicCaption(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: cs.surfaceContainerHigh,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 20.h),
              // Submit button
              Material(
                color: cs.primary,
                borderRadius: BorderRadius.circular(16.r),
                child: InkWell(
                  onTap: _isSubmitting || _selectedReasonKey == null
                      ? null
                      : () {
                          FocusScope.of(context).unfocus();
                          _submit();
                        },
                  borderRadius: BorderRadius.circular(16.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Center(
                      child: _isSubmitting
                          ? SizedBox(
                              height: 20.w,
                              width: 20.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: cs.onPrimary,
                              ),
                            )
                          : Text(
                              'report.submit'.tr(),
                              style: AppTypography.arabicTitle(
                                color: cs.onPrimary,
                                fontSize: 18,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}