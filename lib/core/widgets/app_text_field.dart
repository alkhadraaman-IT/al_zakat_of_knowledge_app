import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

/// Type 1 glowing border text field per ARCHITECTURE_RULES.md.
/// Features: BorderRadius.circular(16.r), 1px primary border, soft glow on focus.
class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool isPassword;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final int maxLines;
  final int? maxLength;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.maxLines = 1,
    this.maxLength,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;
  bool _obscureText = true;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(start: 4.w, bottom: 8.h),
          child: Text(
            widget.label,
            style: AppTypography.label(),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: _hasFocus && !hasError
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 16.r,
                      spreadRadius: 1.r,
                    ),
                  ]
                : hasError
                    ? [
                        BoxShadow(
                          color: AppColors.error.withValues(alpha: 0.2),
                          blurRadius: 12.r,
                          spreadRadius: 1.r,
                        ),
                      ]
                    : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            obscureText: widget.isPassword && _obscureText,
            keyboardType: widget.keyboardType,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            textInputAction: widget.textInputAction,
            style: AppTypography.body(),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTypography.body(color: AppColors.onSurfaceVariant),
              errorText: widget.errorText,
              errorStyle: AppTypography.caption(color: AppColors.error),
              filled: true,
              fillColor: widget.enabled
                  ? AppColors.surface
                  : AppColors.surface.withValues(alpha: 0.5),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: EdgeInsetsDirectional.only(start: 12.w, end: 8.w),
                      child: IconTheme(
                        data: IconThemeData(
                          color: _hasFocus
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant,
                          size: 22.w,
                        ),
                        child: widget.prefixIcon!,
                      ),
                    )
                  : null,
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.onSurfaceVariant,
                        size: 22.w,
                      ),
                      onPressed: () => setState(() => _obscureText = !_obscureText),
                    )
                  : widget.suffixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(
                  color: AppColors.outline,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(
                  color: AppColors.error,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(
                  color: AppColors.error,
                  width: 1.5,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(
                  color: AppColors.outline.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
            ),
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            validator: widget.validator,
          ),
        ),
      ],
    );
  }
}
