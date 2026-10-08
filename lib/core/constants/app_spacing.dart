import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Centralized spacing constants following the 8pt grid system.
/// All values are designed for ScreenUtil responsive scaling.
class AppSpacing {
  AppSpacing._();

  // Base spacing units
  static double get xs => 4.w;
  static double get sm => 8.w;
  static double get md => 16.w;
  static double get lg => 24.w;
  static double get xl => 32.w;
  static double get xxl => 48.w;
  static double get xxxl => 64.w;

  // Screen padding (mandatory 20.w horizontal)
  static double get screenHorizontal => 20.w;
  static double get screenVertical => 20.h;

  // Component spacing
  static double get buttonSpacing => 16.h;
  static double get fieldSpacing => 16.h;
  static double get sectionSpacing => 32.h;
  static double get cardPadding => 16.w;

  // Icon sizes
  static double get iconSm => 16.w;
  static double get iconMd => 24.w;
  static double get iconLg => 32.w;
  static double get iconXl => 48.w;

  // Logo sizes
  static double get logoSize => 120.w;
  static double get logoIconSize => 64.w;
}
