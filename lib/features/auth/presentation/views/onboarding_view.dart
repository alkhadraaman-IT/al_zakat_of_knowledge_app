import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../widgets/onboarding_page.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      imagePath: 'assets/images/onboarding_teach.png',
      title: 'onboarding.quote_1'.tr(),
      description: 'onboarding.body_1'.tr(),
      badge: 'onboarding.badge_1'.tr(),
    ),
    OnboardingPageData(
      imagePath: 'assets/images/onboarding_tools.png',
      title: 'onboarding.quote_2'.tr(),
      description: 'onboarding.body_2'.tr(),
      badge: 'onboarding.badge_2'.tr(),
    ),
    OnboardingPageData(
      imagePath: 'assets/images/onboarding_articles.png',
      title: 'onboarding.quote_3'.tr(),
      description: 'onboarding.body_3'.tr(),
      badge: 'onboarding.badge_3'.tr(),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) => setState(() => _currentPage = page);

  Future<void> _completeOnboarding() async {
    await sl<AuthLocalDataSource>().setOnboardingCompleted(true);
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(cs),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) =>
                    OnboardingPage(data: _pages[index]),
              ),
            ),
            _buildPageIndicator(cs),
            SizedBox(height: AppSpacing.lg),
            _buildBottomSection(cs),
            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(ColorScheme cs) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          // 👇 الشعار (logo.png) بدل الأيقونة
          Container(
            width: 36.w,
            height: 36.w,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
            ),
            child: Image.asset(
              'assets/images/logo_app.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.lightbulb_outline_rounded,
                color: cs.primary,
                size: 20.w,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            'app.name'.tr(),
            style: AppTypography.arabicTitle(
              color: cs.onSurface,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _completeOnboarding,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
              ),
              child: Text(
                'onboarding.skip'.tr(),
                style: AppTypography.arabicLabel(
                  color: cs.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(ColorScheme cs) {
    return SmoothPageIndicator(
      controller: _pageController,
      count: _pages.length,
      effect: ExpandingDotsEffect(
        dotHeight: 8.h,
        dotWidth: 8.w,
        expansionFactor: 3,
        spacing: 6.w,
        activeDotColor: cs.primary,
        dotColor: cs.surfaceContainerHighest,
      ),
    );
  }

  Widget _buildBottomSection(ColorScheme cs) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: GestureDetector(
        onTap: isLastPage
            ? _completeOnboarding
            : () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.primary, cs.primaryContainer],
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: 0.35),
                blurRadius: 20.r,
              ),
            ],
          ),
          child: Center(
            child: Text(
              isLastPage
                  ? 'onboarding.get_started'.tr()
                  : 'onboarding.next'.tr(),
              style: AppTypography.arabicHeadline(
                color: cs.onPrimary,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}