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

  final List<OnboardingPageData> _pages = const [
    OnboardingPageData(
      imagePath: 'assets/images/onboarding_teach.png',
      title: 'قال رسول الله ﷺ: «خَيْرُ النَّاسِ أَنْفَعُهُمْ لِلنَّاسِ»',
      description:
          'نظّم وأعلن عن لقاءات تجمع طلاب العلم في الجامعة أو المعهد أو أي مكان آخر، وشارك المعرفة النافعة لوجه الله تعالى واجعل علمك يثمر أجراً.',
      badge: 'تيسير العلم لطلابه',
    ),
    OnboardingPageData(
      imagePath: 'assets/images/onboarding_tools.png',
      title: 'قال رسول الله ﷺ: «وَاللهُ فِي عَوْنِ الْعَبْدِ مَا كَانَ الْعَبْدُ فِي عَوْنِ أَخِيهِ»',
      description:
          'لا تترك مراجعك ومعداتك الدراسية عرضة للغبار. شاركها مع طلاب علم آخرين، واجعلها وسيلة للنفع بعد انتهائك منها.',
      badge: 'تبادل الموارد، تعزيز المعرفة',
    ),
    OnboardingPageData(
      imagePath: 'assets/images/onboarding_articles.png',
      title: 'قال رسول الله ﷺ: «إِذَا مَاتَ الْإِنْسَانُ انْقَطَعَ عَنْهُ عَمَلُهُ إِلا مِنْ ثَلاثَةٍ: إِلا مِنْ صَدَقَةٍ جَارِيَةٍ، أَوْ عِلْمٍ يُنْتَفَعُ بِهِ...»',
      description:
          'اكتب مقالات نافعة وشارك خبراتك العلمية لتكون لك صدقة جارية يستمر أجرها ونفعها.',
      badge: 'عِلْمٌ يُنْتَفَعُ بِهِ',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) => setState(() => _currentPage = page);

  Future<void> _completeOnboarding() async {
    // ✅ نستخدم AuthLocalDataSource (نفس الـ key الذي يفحصه Splash)
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
          Icon(
            Icons.lightbulb_outline_rounded,
            color: cs.primary,
            size: 26.w,
          ),
          SizedBox(width: 8.w),
          Text(
            'زكاة العلم',
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
                'تخطي',
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
              isLastPage ? 'ابدأ الآن' : 'التالي',
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