import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// Splash screen — Neon Emerald Gradient with Centered Logo.
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
    context.read<AuthCubit>().checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.home);
        } else if (state is AuthUnauthenticated) {
          context.go(AppRoutes.onboarding);
        }
      },
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              // تطبيق التدرج اللوني المطلوب بالكامل للخلفية
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF00D68F),
                    Color(0xFF00A572),
                  ],
                ),
              ),
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // الشعار في المنتصف تماماً (يحتوي اسم التطبيق بداخله أو تحته)
                                _buildLogo(),
                              //   SizedBox(height: AppSpacing.xl),
                              //   _buildAppTitle(),
                              //   SizedBox(height: AppSpacing.sm),
                              //   _buildTagline(),
                              //   SizedBox(height: AppSpacing.xxl),
                              //   _buildVersionTag(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
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
          width: 240.w,
          height: 240.w,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _glowAnimation.value * 0.2),
                blurRadius: 35.r,
                spreadRadius: 4.r,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30.r),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Image.asset(
                'assets/images/logo_white.png', // مسار الشعار الذي يحتوي اسم التطبيق
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.school_outlined,
                  size: 54.w,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildAppTitle() {
  //   return FadeTransition(
  //     opacity: _fadeAnimation,
  //     child: Text(
  //       'زكاة العلم',
  //       style: AppTypography.arabicDisplay(
  //         color: Colors.white,
  //         fontSize: 36,
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildTagline() {
  //   return FadeTransition(
  //     opacity: _fadeAnimation,
  //     child: Text(
  //       'صدقة جارية بعلمك',
  //       style: AppTypography.arabicBody(
  //         color: Colors.white.withValues(alpha: 0.85),
  //         fontSize: 16,
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildVersionTag() {
  //   return FadeTransition(
  //     opacity: _fadeAnimation,
  //     child: Container(
  //       padding: EdgeInsets.symmetric(
  //         horizontal: 16.w,
  //         vertical: 8.h,
  //       ),
  //       decoration: BoxDecoration(
  //         color: Colors.white.withValues(alpha: 0.15),
  //         borderRadius: BorderRadius.circular(20.r),
  //         border: Border.all(
  //           color: Colors.white.withValues(alpha: 0.3),
  //           width: 1,
  //         ),
  //       ),
  //       child: Text(
  //         AppConstants.appVersion,
  //         style: AppTypography.monoCaption(
  //           color: Colors.white,
  //           fontSize: 12,
  //         ),
  //       ),
  //     ),
  //   );
  // }
}