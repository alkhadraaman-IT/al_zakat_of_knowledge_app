import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';

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

  /// يوجّه المستخدم غير المسجّل بحسب ما إذا شاهد الـ Onboarding سابقاً.
  Future<void> _routeUnauthenticatedUser() async {
    final hasSeenOnboarding =
        await sl<AuthLocalDataSource>().isOnboardingCompleted();
    if (!mounted) return;
    if (hasSeenOnboarding) {
      context.go(AppRoutes.login);
    } else {
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.home);
        } else if (state is AuthUnauthenticated) {
          _routeUnauthenticatedUser();
        }
      },
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
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
                                _buildLogo(),
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
                color: Colors.black.withValues(
                  alpha: _glowAnimation.value * 0.2,
                ),
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
                'assets/images/logo_white.png',
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
}