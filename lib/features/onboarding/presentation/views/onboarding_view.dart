import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';

/// Onboarding — Stitch Design System: dark theme, neon emerald, glassmorphism.
class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      icon: Icons.groups_3,
      title: 'شارك علمك في مجالس حضورية',
      description:
      'أعلن عن دروسك ومحاضراتك العلمية في المساجد والمراكز وشارك العلم النافع لوجه الله تعالى ونيل الأجر.',
    ),
    _OnboardingPageData(
      icon: Icons.inventory_2,
      title: 'أوقف الكتب والأدوات الدراسية',
      description:
      'أعِر مراجعك العلمية وعتادك الدراسي لطلاب العلم المحتاجين، واجعل كتبك نافعة تدار بين الصدور.',
    ),
    _OnboardingPageData(
      icon: Icons.workspace_premium,
      title: 'أثر علمي باقٍ وصدقة جارية',
      description:
      'قال رسول الله ﷺ: «أو علم ينتفع به»؛ وثّق أثرك التعليمي واصنع بصمة مباركة يستمر أجرها بعد انقطاع العمل.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _onSkip() {
    context.go(AppRoutes.login);
  }

  void _onGetStarted() {
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPage(
                    data: _pages[index],
                    isActive: index == _currentPage,
                  );
                },
              ),
            ),
            _buildPageIndicator(),
            SizedBox(height: AppSpacing.lg),
            _buildBottomSection(),
            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          // Brand badge
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.background.withValues(alpha: 0.3),
                  blurRadius: 10.r,
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.auto_stories,
                    color: AppColors.primary,
                    size: 24.w,
                  ),
                ),
                Positioned(
                  top: -2.h,
                  right: -2.w,
                  child: Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.8),
                          blurRadius: 8.r,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'زكاة العلم',
                style: AppTypography.arabicTitle(
                  color: AppColors.onSurface,
                  fontSize: 16,
                ),
              ),
              Text(
                'صدقة جارية بعلمك',
                style: AppTypography.arabicCaption(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Skip button
          GestureDetector(
            onTap: _onSkip,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  Text(
                    'تخطي',
                    style: AppTypography.arabicLabel(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.arrow_left,
                    color: AppColors.onSurfaceVariant,
                    size: 16.w,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return SmoothPageIndicator(
      controller: _pageController,
      count: _pages.length,
      effect: WormEffect(
        dotHeight: 8.w,
        dotWidth: 8.w,
        spacing: 8.w,
        activeDotColor: AppColors.primary,
        dotColor: AppColors.surfaceContainerHighest,
      ),
    );
  }

  Widget _buildBottomSection() {
    final isLastPage = _currentPage == _pages.length - 1;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        children: [
          // Primary CTA button
          GestureDetector(
            onTap: isLastPage ? _onGetStarted : () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.45),
                    blurRadius: 20.r,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  isLastPage ? 'ابدأ الآن' : 'التالي',
                  style: AppTypography.arabicHeadline(
                    color: AppColors.onPrimary,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          // Login link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'لديك حساب مسجل بالفعل؟',
                style: AppTypography.arabicBody(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                onTap: () => context.go(AppRoutes.login),
                child: Text(
                  ' تسجيل الدخول',
                  style: AppTypography.arabicBody(
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Onboarding page data model.
class _OnboardingPageData {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// Individual onboarding page — Stitch Type 1 Luminous Focus card.
class _OnboardingPage extends StatelessWidget {
  final _OnboardingPageData data;
  final bool isActive;

  const _OnboardingPage({
    required this.data,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Stage showcase card (Container Type 1)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 24.r,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                // Icon with pulse ring
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 96.w,
                      height: 96.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 20.r,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 56.w,
                          height: 56.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.5),
                                blurRadius: 12.r,
                              ),
                            ],
                          ),
                          child: Icon(
                            data.icon,
                            color: AppColors.onPrimary,
                            size: 28.w,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                // Step counter
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'المرحلة ${isActive ? "١" : "١"} من ٣',
                        style: AppTypography.monoCaption(
                          color: AppColors.primary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                // Title
                Text(
                  data.title,
                  style: AppTypography.arabicHeadline(
                    color: AppColors.onSurface,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                // Description
                Text(
                  data.description,
                  style: AppTypography.arabicBody(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
