import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_colors.dart';

/// Glow container types per ARCHITECTURE_RULES.md section 4.3.
enum GlowContainerType {
  /// Type 1: Interactive Primary Glow
  /// BorderRadius.circular(16.r), 1px primary border (#0D5C52), soft primary neon glow.
  primary,

  /// Type 2: Elevated Card
  /// Clean rounded corners (12.r-16.r), subtle drop shadow.
  elevated,

  /// Type 3: Tinted Accent Container
  /// Low-opacity tinted background (#0D5C52 at 10%), solid primary accent border with soft glow.
  tinted,
}

/// A reusable glow container implementing the 3 container types from the design system.
class CustomGlowContainer extends StatelessWidget {
  final Widget child;
  final GlowContainerType type;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? glowColor;
  final double? glowIntensity;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const CustomGlowContainer({
    super.key,
    required this.child,
    this.type = GlowContainerType.primary,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.glowColor,
    this.glowIntensity,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGlowColor = glowColor ?? AppColors.primary;
    final effectiveGlowIntensity = glowIntensity ?? 0.4;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      height: height,
      margin: margin,
      decoration: _buildDecoration(effectiveGlowColor, effectiveGlowIntensity),
      child: Material(
        color: Colors.transparent,
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                borderRadius: _resolveBorderRadius(),
                child: Padding(
                  padding: padding ?? EdgeInsets.all(AppSpacingMd.md),
                  child: child,
                ),
              )
            : Padding(
                padding: padding ?? EdgeInsets.all(AppSpacingMd.md),
                child: child,
              ),
      ),
    );
  }

  BoxDecoration _buildDecoration(Color glowColor, double intensity) {
    switch (type) {
      case GlowContainerType.primary:
        return BoxDecoration(
          color: AppColors.surface,
          borderRadius: _resolveBorderRadius(),
          border: Border.all(color: AppColors.primary, width: 1),
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: intensity),
              blurRadius: 20.r,
              spreadRadius: 2.r,
              offset: Offset(0, 4.h),
            ),
            BoxShadow(
              color: glowColor.withValues(alpha: intensity * 0.3),
              blurRadius: 40.r,
              spreadRadius: 4.r,
            ),
          ],
        );
      case GlowContainerType.elevated:
        return BoxDecoration(
          color: AppColors.surface,
          borderRadius: _resolveBorderRadius(),
          boxShadow: [
            BoxShadow(
              color: const Color(0x0A000000),
              blurRadius: 12.r,
              offset: Offset(0, 4.h),
            ),
          ],
        );
      case GlowContainerType.tinted:
        return BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.10),
          borderRadius: _resolveBorderRadius(),
          border: Border.all(color: AppColors.primary, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.15),
              blurRadius: 16.r,
              spreadRadius: 1.r,
            ),
          ],
        );
    }
  }

  BorderRadius _resolveBorderRadius() {
    if (borderRadius != null) return borderRadius!;
    switch (type) {
      case GlowContainerType.primary:
        return BorderRadius.circular(16.r);
      case GlowContainerType.elevated:
        return BorderRadius.circular(12.r);
      case GlowContainerType.tinted:
        return BorderRadius.circular(16.r);
    }
  }
}

/// Spacing constants used by core widgets.
class AppSpacingMd {
  static double md = 16.w;
}
