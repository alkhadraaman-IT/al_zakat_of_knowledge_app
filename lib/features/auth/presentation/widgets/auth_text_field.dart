import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';

class AuthTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputType keyboardType;
  final bool isPassword;
  final IconData prefixIcon;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.focusNode,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    required this.prefixIcon,
    this.textInputAction = TextInputAction.next,
    this.validator,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscureText = true;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() =>
      setState(() => _hasFocus = widget.focusNode.hasFocus);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.tr(),
          style: AppTypography.arabicLabel(
            color: cs.onSurface,
            fontSize: 14,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: _hasFocus
                ? [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.15),
                      blurRadius: 12.r,
                      spreadRadius: 1.r,
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            obscureText: _obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            style: AppTypography.arabicBody(color: cs.onSurface, fontSize: 16),
            decoration: InputDecoration(
              hintText: widget.hint.tr(),
              hintStyle: AppTypography.arabicBody(
                color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                fontSize: 16,
              ),
              prefixIcon: Icon(
                widget.prefixIcon,
                color: _hasFocus ? cs.primary : cs.onSurfaceVariant,
                size: 22.w,
              ),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: cs.onSurfaceVariant,
                        size: 22.w,
                      ),
                      onPressed: () =>
                          setState(() => _obscureText = !_obscureText),
                    )
                  : null,
              filled: true,
              fillColor: cs.surfaceContainerHighest,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: cs.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: cs.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: cs.error, width: 1.5),
              ),
            ),
            validator: widget.validator,
          ),
        ),
      ],
    );
  }
}