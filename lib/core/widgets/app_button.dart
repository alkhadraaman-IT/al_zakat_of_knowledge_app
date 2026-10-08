import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

/// Primary glowing button used across the app.
/// Implements the Type 1 Interactive Primary Glow container style.
class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double? height;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final bool isOutlined;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.isOutlined = false,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.isDisabled || widget.isLoading;
    final bgColor = widget.backgroundColor ?? AppColors.primary;
    final txtColor = widget.textColor ?? AppColors.onPrimary;

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: widget.width ?? double.infinity,
          height: widget.height ?? 56.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: isDisabled
                ? null
                : [
                    BoxShadow(
                      color: bgColor.withValues(alpha: _glowAnimation.value),
                      blurRadius: 20.r,
                      spreadRadius: 2.r,
                      offset: Offset(0, 4.h),
                    ),
                    BoxShadow(
                      color: bgColor.withValues(alpha: _glowAnimation.value * 0.3),
                      blurRadius: 40.r,
                      spreadRadius: 4.r,
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isDisabled ? null : widget.onPressed,
              borderRadius: BorderRadius.circular(16.r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: widget.isOutlined ? Colors.transparent : bgColor,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: isDisabled ? AppColors.outline : bgColor,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: widget.isLoading
                      ? SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(txtColor),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                color: txtColor,
                                size: 20.w,
                              ),
                              SizedBox(width: 8.w),
                            ],
                            Text(
                              widget.text,
                              style: AppTypography.button(
                                color: widget.isOutlined ? bgColor : txtColor,
                                fontSize: widget.fontSize,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
