// `hide TextDirection` — easy_localization re-exports package:intl,
// which declares its own TextDirection class that shadows
// Flutter's TextDirection enum (TextDirection.rtl).
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_typography.dart';

/// Reusable search bar — matches _ModernTextField design tokens.
/// Used on Home screen (tappable) and Search screen (with input).
class AppSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;

  const AppSearchBar({
    super.key,
    this.controller,
    this.hintText,
    this.onTap,
    this.onChanged,
    this.suffixIcon,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  bool _hasFocus = false;

  @override
  Widget build(BuildContext context) {
    final isTappable = widget.onTap != null;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: _hasFocus ? Theme.of(context).colorScheme.primary : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: _hasFocus
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                    blurRadius: 12.r,
                    spreadRadius: 1.r,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                onChanged: widget.onChanged,
                enabled: !isTappable,
                style: AppTypography.arabicBody(fontSize: 16),
                decoration: InputDecoration(
                  hintText: widget.hintText ?? 'search.hint'.tr(),
                  hintStyle: AppTypography.arabicBody(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
                textDirection: TextDirection.rtl,
                onTap: widget.onTap,
              ),
            ),
            if (widget.suffixIcon != null)
              widget.suffixIcon!
            else
              Padding(
                padding: EdgeInsetsDirectional.only(end: 8.w),
                child: Icon(
                  Icons.search,
                  color: _hasFocus ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 22.w,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
