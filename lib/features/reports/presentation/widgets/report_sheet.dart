import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../cubit/report_cubit.dart';
import '../cubit/report_state.dart';

/// يعرض رسالة SnackBar بلون النجاح (أخضر).
void _showSuccess(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Theme.of(context).colorScheme.primary,
    ),
  );
}

/// يعرض رسالة SnackBar بلون الخطأ (أحمر).
void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Theme.of(context).colorScheme.error,
    ),
  );
}

Future<bool> showReportSheet({
  required BuildContext context,
  required String targetType,
  required String targetId,
}) async {
  final reported = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider(
      create: (_) => sl<ReportCubit>(),
      child: _ReportSheet(targetType: targetType, targetId: targetId),
    ),
  );

  if (reported == true && context.mounted) {
    _showSuccess(context, 'report.success'.tr());
  }

  return reported ?? false;
}

class _ReportSheet extends StatefulWidget {
  final String targetType;
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
  String? _formError;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _formError = null);

    if (_selectedReasonKey == null) {
      setState(() => _formError = 'report.choose_reason'.tr());
      return;
    }

    final reporterId = _resolveReporterId();
    if (reporterId == null) {
      setState(() => _formError = 'report.error_auth'.tr());
      return;
    }

    final details = _selectedReasonKey == 'report.reason_other'
        ? _detailsController.text.trim()
        : null;

    context.read<ReportCubit>().submitReport(
          reporterId: reporterId,
          targetType: widget.targetType,
          targetId: widget.targetId,
          reason: _selectedReasonKey!,
          details: details,
        );
  }

  String? _resolveReporterId() {
    final state = context.read<AuthCubit>().state;
    if (state is AuthAuthenticated) return state.user.id;
    return null;
  }

  String _friendlyError(Failure failure) {
    if (failure is NetworkFailure) return 'report.error_offline'.tr();
    switch (failure.code) {
      case '23503':
        return 'report.error_invalid_target'.tr();
      case '42501':
        return 'report.error_permission'.tr();
      default:
        return 'report.error_submit'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocConsumer<ReportCubit, ReportState>(
      listener: (ctx, state) {
        if (state is ReportSuccess) {
          Navigator.pop(ctx, true);
        } else if (state is ReportError) {
          // استخراج الأخطاء عبر Failure
          final failure = ServerFailure(
            message: state.message,
            code: state.code,
          );
          setState(() => _formError = _friendlyError(failure));
        }
      },
      builder: (ctx, state) {
        final isSubmitting = state is ReportSubmitting;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
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
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      margin: EdgeInsets.only(bottom: 20.h),
                      decoration: BoxDecoration(
                        color: cs.outline,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
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

                  RadioGroup<String>(
                    groupValue: _selectedReasonKey,
                    onChanged: isSubmitting
                        ? (_) {}
                        : (value) =>
                            setState(() => _selectedReasonKey = value),
                    child: Column(
                      children: _reasonKeys.map((option) {
                        return RadioListTile<String>(
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
                        );
                      }).toList(),
                    ),
                  ),

                  if (_selectedReasonKey == 'report.reason_other')
                    Padding(
                      padding: EdgeInsets.only(top: 12.h),
                      child: TextField(
                        controller: _detailsController,
                        maxLines: 3,
                        minLines: 2,
                        enabled: !isSubmitting,
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

                  if (_formError != null) ...[
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: cs.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        _formError!,
                        style: AppTypography.arabicBody(
                          color: cs.error,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: 20.h),

                  Material(
                    color: isSubmitting
                        ? cs.surfaceContainerHighest
                        : (_selectedReasonKey == null
                            ? cs.surfaceContainerHighest
                            : cs.primary),
                    borderRadius: BorderRadius.circular(16.r),
                    child: InkWell(
                      onTap: isSubmitting || _selectedReasonKey == null
                          ? null
                          : () {
                              FocusScope.of(context).unfocus();
                              _submit();
                            },
                      borderRadius: BorderRadius.circular(16.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: Center(
                          child: isSubmitting
                              ? SizedBox(
                                  height: 20.w,
                                  width: 20.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: cs.onSurfaceVariant,
                                  ),
                                )
                              : Text(
                                  'report.submit'.tr(),
                                  style: AppTypography.arabicTitle(
                                    color: _selectedReasonKey == null
                                        ? cs.onSurfaceVariant
                                        : cs.onPrimary,
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
      },
    );
  }
}