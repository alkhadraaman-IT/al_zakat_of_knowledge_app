import 'package:flutter/material.dart';

/// Locale-aware icons for back buttons and navigation chevrons.
///
/// The icon is chosen from the ambient [Directionality] instead of being
/// mirrored with `Transform.scale`, `Transform.flip` or a `TextDirection`
/// override: those hacks shift the glyph off its tap target, blur it on some
/// platforms and leave the accessibility hint pointing the wrong way.
///
/// In Arabic (RTL) the "back" affordance points right; in English (LTR) it
/// points left.
class DirectionalIcons {
  DirectionalIcons._();

  static bool isRtl(BuildContext context) =>
      Directionality.of(context) == TextDirection.rtl;

  /// Back arrow for headers and app bars.
  static IconData back(BuildContext context) =>
      isRtl(context) ? Icons.arrow_forward : Icons.arrow_back;

  /// Thin iOS-style back arrow.
  static IconData backIos(BuildContext context) =>
      isRtl(context) ? Icons.arrow_forward_ios : Icons.arrow_back_ios_new;

  /// Chevron for rows and cards that open a detail screen. It points the way
  /// the content continues: right in LTR, left in RTL.
  static IconData forward(BuildContext context) =>
      isRtl(context) ? Icons.chevron_left : Icons.chevron_right;
}
