import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_typography.dart';

class AuthButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPrimary;

  const AuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
  });

  @override
  State<AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => _controller.forward(),
      onTapUp: isDisabled ? null : (_) => _controller.reverse(),
      onTapCancel: isDisabled ? null : () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, _) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            height: 56.h,
            decoration: BoxDecoration(
              gradient: widget.isPrimary && !isDisabled
                  ? LinearGradient(
                      colors: [cs.primary, cs.primaryContainer],
                    )
                  : null,
              color: widget.isPrimary
                  ? null
                  : (isDisabled ? cs.surfaceContainerHighest : cs.surface),
              borderRadius: BorderRadius.circular(16.r),
              border: widget.isPrimary
                  ? null
                  : Border.all(
                      color: isDisabled ? cs.outline : cs.primary,
                      width: 1.5,
                    ),
              boxShadow: widget.isPrimary && !isDisabled
                  ? [
                      BoxShadow(
                        color: cs.primary.withValues(alpha: 0.3),
                        blurRadius: 16.r,
                        offset: Offset(0, 4.h),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isDisabled ? null : widget.onPressed,
                borderRadius: BorderRadius.circular(16.r),
                child: Center(
                  child: widget.isLoading
                      ? SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              widget.isPrimary ? cs.onPrimary : cs.primary,
                            ),
                          ),
                        )
                      : Text(
                          widget.text.tr(),
                          style: AppTypography.button(
                            color: widget.isPrimary ? cs.onPrimary : cs.primary,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}