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
        backgroundColor: AppColors.background,
        body: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              decoration: const BoxDecoration(
                gradient: AppColors.backgroundGradient,
              ),
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // The scroll view lets the splash content
                    // shrink on small screens instead of
                    // overflowing; the ConstrainedBox keeps the
                    // block vertically centered whenever the
                    // content is shorter than the viewport.
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildLogo(),
                              SizedBox(height: AppSpacing.xl),
                              _buildAppTitle(),
                              SizedBox(height: AppSpacing.sm),
                              _buildTagline(),
                              SizedBox(height: AppSpacing.xxl),
                              _buildVersionTag(),
                            ],
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
          width: 110.w,
          height: 110.w,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: _glowAnimation.value * 0.4),
                blurRadius: 30.r,
                spreadRadius: 2.r,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28.r),
            child: Padding(
              padding: EdgeInsets.all(12.w),
              // هنا ضعي مسار شعار التطبيق الحقيقي الخاص بكِ
              child: Image.asset(
                'assets/images/app_logo.png', // استبدلي المسار حسب اسم صورتك
                fit: BoxFit.contain,
                // كبديل مؤقت ريثما تضعين الصورة، ستعمل هذه الدالة بأمان
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.lightbulb_outline_rounded,
                  size: AppSpacing.logoIconSize,
                  color: AppColors.primary,
                ),
              ),
            ),
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

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';

// import '../../../../app/router/app_router.dart';
// import '../../../../app/theme/app_colors.dart';
// import '../../../../app/theme/app_typography.dart';
// import '../../../../core/constants/app_constants.dart';
// import '../../../../core/constants/app_spacing.dart';
// import '../../../auth/presentation/bloc/auth_cubit.dart';
// import '../../../auth/presentation/bloc/auth_state.dart';

// /// Splash screen — Dark Emerald Theme with Soft Radial/Linear Glow.
// class SplashView extends StatefulWidget {
//   const SplashView({super.key});

//   @override
//   State<SplashView> createState() => _SplashViewState();
// }

// class _SplashViewState extends State<SplashView>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _glowAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 2000),
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
//       ),
//     );

//     _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
//       ),
//     );

//     _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
//       ),
//     );

//     _animationController.forward();

//     _animationController.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         _checkAuthAndRoute();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _checkAuthAndRoute() {
//     context.read<AuthCubit>().checkAuthStatus();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<AuthCubit, AuthState>(
//       listener: (context, state) {
//         if (state is AuthAuthenticated) {
//           context.go(AppRoutes.home);
//         } else if (state is AuthUnauthenticated) {
//           context.go(AppRoutes.onboarding);
//         }
//       },
//       child: Scaffold(
//         // خلفية خضراء داكنة مريحة جداً للعين
//         backgroundColor: const Color(0xFF071810),
//         body: AnimatedBuilder(
//           animation: _animationController,
//           builder: (context, child) {
//             return Container(
//               decoration: const BoxDecoration(
//                 // تدرج لوني أخضر داكن مع لمسة بيضاء ضوئية خفيفة جداً من الأعلى والمنتصف
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Color(0xFF0E2E1F), // أخضر داكن مائل للإضاءة
//                     Color(0xFF071810), // أخضر داكن عميق مريح للعين
//                     Color(0xFF040F0A), // تدرج أعمق للأسفل
//                   ],
//                   stops: [0.0, 0.5, 1.0],
//                 ),
//               ),
//               child: SafeArea(
//                 child: LayoutBuilder(
//                   builder: (context, constraints) {
//                     return SingleChildScrollView(
//                       physics: const AlwaysScrollableScrollPhysics(),
//                       child: ConstrainedBox(
//                         constraints: BoxConstraints(
//                           minHeight: constraints.maxHeight,
//                         ),
//                         child: Center(
//                           child: Padding(
                            
//                             padding: EdgeInsets.symmetric(horizontal: 24.w),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 const Spacer(),
//                                 // الشعار في المنتصف تماماً
//                                 _buildLogo(),
//                                 SizedBox(height: AppSpacing.xl),
//                                 _buildAppTitle(),
//                                 SizedBox(height: AppSpacing.sm),
//                                 _buildTagline(),
//                                 const Spacer(),
//                                 // مؤشر تحميل أنيق في الأسفل فقط
//                                 _buildLoadingIndicator(),
//                                 SizedBox(height: AppSpacing.xl),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildLogo() {
//     return FadeTransition(
//       opacity: _fadeAnimation,
//       child: ScaleTransition(
//         scale: _scaleAnimation,
//         child: Container(
//           width: 120.w,
//           height: 120.w,
//           decoration: BoxDecoration(
//             color: const Color(0xFF0E261B),
//             borderRadius: BorderRadius.circular(30.r),
//             border: Border.all(
//               color: AppColors.primary.withValues(alpha: 0.4),
//               width: 1.5,
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: AppColors.primary.withValues(
//                   alpha: _glowAnimation.value * 0.25,
//                 ),
//                 blurRadius: 35.r,
//                 spreadRadius: 4.r,
//               ),
//             ],
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(30.r),
//             child: Padding(
//               padding: EdgeInsets.all(14.w),
//               child: Image.asset(
//                 'assets/images/app_logo.png',
//                 fit: BoxFit.contain,
//                 errorBuilder: (context, error, stackTrace) => Icon(
//                   Icons.lightbulb_outline_rounded,
//                   size: 54.w,
//                   color: AppColors.primary,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAppTitle() {
//     return FadeTransition(
//       opacity: _fadeAnimation,
//       child: Text(
//         'زكاة العلم',
//         style: AppTypography.arabicDisplay(
//           color: AppColors.primary,
//           fontSize: 36,
//         ),
//       ),
//     );
//   }

//   Widget _buildTagline() {
//     return FadeTransition(
//       opacity: _fadeAnimation,
//       child: Text(
//         'صدقة جارية بعلمك',
//         style: AppTypography.arabicBody(
//           color: AppColors.onSurfaceVariant,
//           fontSize: 16,
//         ),
//       ),
//     );
//   }

//   Widget _buildLoadingIndicator() {
//     return FadeTransition(
//       opacity: _fadeAnimation,
//       child: SizedBox(
//         width: 28.w,
//         height: 28.w,
//         child: CircularProgressIndicator(
//           strokeWidth: 2.5,
//           valueColor: AlwaysStoppedAnimation<Color>(
//             AppColors.primary.withValues(alpha: 0.8),
//           ),
//         ),
//       ),
//     );
//   }
// }
