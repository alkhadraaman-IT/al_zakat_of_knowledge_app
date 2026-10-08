import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// Splash screen — Stitch Design System: dark theme, neon emerald glow.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );

    _animationController.forward();

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _checkAuthAndRoute();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _checkAuthAndRoute() {
    context.read<AuthBloc>().add(const AuthCheckRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.home);
        } else if (state is AuthUnauthenticated) {
          context.go(AppRoutes.onboarding);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              decoration: const BoxDecoration(
                gradient: AppColors.backgroundGradient,
              ),
              child: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      _buildLogo(),
                      SizedBox(height: AppSpacing.xl),
                      _buildAppTitle(),
                      SizedBox(height: AppSpacing.sm),
                      _buildTagline(),
                      const Spacer(),
                      _buildVersionTag(),
                      SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: AppSpacing.logoSize,
          height: AppSpacing.logoSize,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: _glowAnimation.value * 0.45),
                blurRadius: 25.r,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Icon(
            Icons.school_outlined,
            size: AppSpacing.logoIconSize,
            color: AppColors.onPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildAppTitle() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Text(
        'زكاة العلم',
        style: AppTypography.arabicDisplay(
          color: AppColors.primary,
          fontSize: 36,
        ),
      ),
    );
  }

  Widget _buildTagline() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Text(
        'صدقة جارية بعلمك',
        style: AppTypography.arabicBody(
          color: AppColors.onSurfaceVariant,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildVersionTag() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          AppConstants.appVersion,
          style: AppTypography.monoCaption(
            color: AppColors.primary,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
