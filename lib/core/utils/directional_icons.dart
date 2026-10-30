import 'package:flutter/material.dart';

class DirectionalIcons {
  /// يُرجع سهم الرجوع المناسب حسب اتجاه اللغة
  static IconData back(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return isRtl ? Icons.arrow_forward : Icons.arrow_back;
  }

  /// يُرجع سهم الرجوع النمط الخاص بـ iOS حسب الاتجاه
  static IconData backIos(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return isRtl ? Icons.arrow_forward_ios : Icons.arrow_back_ios_new;
  }

  /// يُرجع سهم التقدم/التنقل للأمام (مثل القوائم والشفرونات)
  static IconData forward(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return isRtl ? Icons.chevron_left : Icons.chevron_right;
  }
}