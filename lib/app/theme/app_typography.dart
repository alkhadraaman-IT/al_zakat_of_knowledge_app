import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

/// Typography system per ARCHITECTURE_RULES.md section 4.1.
/// Arabic: Thmanyah Font.
/// English/Latin text and numbers: IBM Plex Mono.
class AppTypography {
  AppTypography._();

  // Font Families
  static const String arabicFont = 'Thmanyah';
  static const String monoFont = 'IBM Plex Mono';

  /// Whether the UI is currently showing Arabic. Set by the app root from the
  /// active locale (lib/app/app.dart) so every style picks the right family.
  static bool isArabic = true;

  /// Family for the current language: Thmanyah for Arabic, IBM Plex Mono for
  /// English/Latin text and numbers.
  static String get uiFont => isArabic ? arabicFont : monoFont;

  // Fallback chains. A glyph the primary family lacks falls back to the app's
  // other family before reaching a system font — without these, Arabic text
  // styled with IBM Plex Mono (0 Arabic glyphs) silently rendered in a system
  // font instead of Thmanyah, and Arabic-primary styles had no mono fallback
  // for Latin text and digits.
  static const List<String> _uiFallbacks = <String>[arabicFont, monoFont];
  static const List<String> _monoFallbacks = <String>[arabicFont];

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

  // Latin text and numbers are covered by the mono* styles above — English UI
  // text reaches IBM Plex Mono through [uiFont], so there is no separate Latin
  // family.

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
