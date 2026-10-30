import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

/// Typography system per ARCHITECTURE_RULES.md section 4.1.
/// Arabic: Thmanyah Font (with system fallback).
/// English/Mono: IBM Plex Mono.
class AppTypography {
  AppTypography._();

  // Font Families
  static const String arabicFont = 'Thmanyah';
  static const String monoFont = 'IBM Plex Mono';
  static const String interFont = 'Inter';

  /// Whether the UI is currently showing Arabic. Set by the app root from the
  /// active locale (lib/app/app.dart) so every style picks the right family.
  static bool isArabic = true;

  /// Family for the current language: Thmanyah for Arabic, Inter for Latin.
  static String get uiFont => isArabic ? arabicFont : interFont;

  // Fallback chains. A glyph the primary family lacks falls back to another
  // custom family before reaching a system font — without these, Arabic text
  // styled with IBM Plex Mono (0 Arabic glyphs) silently rendered in a system
  // font instead of the app's own fonts.
  static const List<String> _uiFallbacks = <String>[arabicFont, interFont, monoFont];
  static const List<String> _monoFallbacks = <String>[arabicFont, interFont];
  static const List<String> _interFallbacks = <String>[arabicFont, monoFont];

  // Arabic Text Styles
  static TextStyle arabicDisplay({Color? color, double? fontSize}) {
    return TextStyle(
      fontFamily: uiFont,
      fontFamilyFallback: _uiFallbacks,
      fontSize: (fontSize ?? 32).sp,
      fontWeight: FontWeight.w700,
      color: color ?? AppColors.onSurface,
      height: 1.4,
      letterSpacing: 0,
    );
  }

  static TextStyle arabicHeadline({Color? color, double? fontSize}) {
    return TextStyle(
      fontFamily: uiFont,
      fontFamilyFallback: _uiFallbacks,
      fontSize: (fontSize ?? 24).sp,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.onSurface,
      height: 1.4,
      letterSpacing: 0,
    );
  }

  static TextStyle arabicTitle({Color? color, double? fontSize}) {
    return TextStyle(
      fontFamily: uiFont,
      fontFamilyFallback: _uiFallbacks,
      fontSize: (fontSize ?? 20).sp,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.onSurface,
      height: 1.5,
      letterSpacing: 0,
    );
  }

  static TextStyle arabicBody({Color? color, double? fontSize}) {
    return TextStyle(
      fontFamily: uiFont,
      fontFamilyFallback: _uiFallbacks,
      fontSize: (fontSize ?? 16).sp,
      fontWeight: FontWeight.w400,
      color: color ?? AppColors.onSurface,
      height: 1.6,
      letterSpacing: 0,
    );
  }

  static TextStyle arabicLabel({Color? color, double? fontSize}) {
    return TextStyle(
      fontFamily: uiFont,
      fontFamilyFallback: _uiFallbacks,
      fontSize: (fontSize ?? 14).sp,
      fontWeight: FontWeight.w500,
      color: color ?? AppColors.onSurfaceVariant,
      height: 1.5,
      letterSpacing: 0,
    );
  }

  static TextStyle arabicCaption({Color? color, double? fontSize}) {
    return TextStyle(
      fontFamily: uiFont,
      fontFamilyFallback: _uiFallbacks,
      fontSize: (fontSize ?? 12).sp,
      fontWeight: FontWeight.w400,
      color: color ?? AppColors.onSurfaceVariant,
      height: 1.5,
      letterSpacing: 0,
    );
  }

  // English/Mono Text Styles
  static TextStyle monoDisplay({Color? color, double? fontSize}) {
    return TextStyle(
      fontFamily: monoFont,
      fontFamilyFallback: _monoFallbacks,
      fontSize: (fontSize ?? 32).sp,
      fontWeight: FontWeight.w700,
      color: color ?? AppColors.onSurface,
      height: 1.2,
      letterSpacing: -0.5,
    );
  }

  static TextStyle monoHeadline({Color? color, double? fontSize}) {
    return TextStyle(
      fontFamily: monoFont,
      fontFamilyFallback: _monoFallbacks,
      fontSize: (fontSize ?? 24).sp,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.onSurface,
      height: 1.3,
      letterSpacing: -0.3,
    );
  }

  static TextStyle monoTitle({Color? color, double? fontSize}) {
    return TextStyle(
      fontFamily: monoFont,
      fontFamilyFallback: _monoFallbacks,
      fontSize: (fontSize ?? 20).sp,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.onSurface,
      height: 1.4,
      letterSpacing: -0.2,
    );
  }

  static TextStyle monoBody({Color? color, double? fontSize}) {
    return TextStyle(
      fontFamily: monoFont,
      fontFamilyFallback: _monoFallbacks,
      fontSize: (fontSize ?? 16).sp,
      fontWeight: FontWeight.w400,
      color: color ?? AppColors.onSurface,
      height: 1.5,
      letterSpacing: 0,
    );
  }

  static TextStyle monoLabel({Color? color, double? fontSize}) {
    return TextStyle(
      fontFamily: monoFont,
      fontFamilyFallback: _monoFallbacks,
      fontSize: (fontSize ?? 14).sp,
      fontWeight: FontWeight.w500,
      color: color ?? AppColors.onSurfaceVariant,
      height: 1.4,
      letterSpacing: 0.1,
    );
  }

  static TextStyle monoCaption({Color? color, double? fontSize}) {
    return TextStyle(
      fontFamily: monoFont,
      fontFamilyFallback: _monoFallbacks,
      fontSize: (fontSize ?? 12).sp,
      fontWeight: FontWeight.w400,
      color: color ?? AppColors.onSurfaceVariant,
      height: 1.4,
      letterSpacing: 0.2,
    );
  }

  // Inter Text Styles (for English body text)
  static TextStyle interDisplay({Color? color, double? fontSize}) {
    return TextStyle(
      fontFamily: interFont,
      fontFamilyFallback: _interFallbacks,
      fontSize: (fontSize ?? 32).sp,
      fontWeight: FontWeight.w700,
      color: color ?? AppColors.onSurface,
      height: 1.2,
      letterSpacing: -0.5,
    );
  }

  static TextStyle interHeadline({Color? color, double? fontSize}) {
    return TextStyle(
      fontFamily: interFont,
      fontFamilyFallback: _interFallbacks,
      fontSize: (fontSize ?? 24).sp,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.onSurface,
      height: 1.3,
      letterSpacing: -0.3,
    );
  }

  static TextStyle interTitle({Color? color, double? fontSize}) {
    return TextStyle(
      fontFamily: interFont,
      fontFamilyFallback: _interFallbacks,
      fontSize: (fontSize ?? 20).sp,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.onSurface,
      height: 1.4,
      letterSpacing: -0.2,
    );
  }

  static TextStyle interBody({Color? color, double? fontSize}) {
    return TextStyle(
      fontFamily: interFont,
      fontFamilyFallback: _interFallbacks,
      fontSize: (fontSize ?? 16).sp,
      fontWeight: FontWeight.w400,
      color: color ?? AppColors.onSurface,
      height: 1.5,
      letterSpacing: 0,
    );
  }

  static TextStyle interLabel({Color? color, double? fontSize}) {
    return TextStyle(
      fontFamily: interFont,
      fontFamilyFallback: _interFallbacks,
      fontSize: (fontSize ?? 14).sp,
      fontWeight: FontWeight.w500,
      color: color ?? AppColors.onSurfaceVariant,
      height: 1.4,
      letterSpacing: 0.1,
    );
  }

  static TextStyle interCaption({Color? color, double? fontSize}) {
    return TextStyle(
      fontFamily: interFont,
      fontFamilyFallback: _interFallbacks,
      fontSize: (fontSize ?? 12).sp,
      fontWeight: FontWeight.w400,
      color: color ?? AppColors.onSurfaceVariant,
      height: 1.4,
      letterSpacing: 0.2,
    );
  }

  // Button text style
  static TextStyle button({Color? color, double? fontSize}) {
    return TextStyle(
      fontFamily: uiFont,
      fontFamilyFallback: _uiFallbacks,
      fontSize: (fontSize ?? 16).sp,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.onPrimary,
      height: 1.4,
      letterSpacing: 0,
    );
  }

  // Body text style (default)
  static TextStyle body({Color? color, double? fontSize}) {
    return arabicBody(color: color, fontSize: fontSize);
  }

  // Label text style (default)
  static TextStyle label({Color? color, double? fontSize}) {
    return arabicLabel(color: color, fontSize: fontSize);
  }

  // Caption text style (default)
  static TextStyle caption({Color? color, double? fontSize}) {
    return arabicCaption(color: color, fontSize: fontSize);
  }
}
