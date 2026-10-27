import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';

/// Onboarding — Modern Full-Screen Stitch Dark Theme.
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
      imagePath: 'assets/images/onboarding_teach.png',
      title: 'قال رسول الله ﷺ: «خَيْرُ النَّاسِ أَنْفَعُهُمْ لِلنَّاسِ»',
      description:
          'نظّم وأعلن عن لقاءات تجمع طلاب العلم في الجامعة أو المعهد أو أي مكان آخر، وشارك المعرفة النافعة لوجه الله تعالى واجعل علمك يثمر أجراً.',
      badge: 'تيسير العلم لطلابه',
      isHadith: true,
    ),
    _OnboardingPageData(
      imagePath: 'assets/images/onboarding_tools.png',
      title: 'قال رسول الله ﷺ: «وَاللهُ فِي عَوْنِ الْعَبْدِ مَا كَانَ الْعَبْدُ فِي عَوْنِ أَخِيهِ»',
      description:
          'لا تترك مراجعك ومعداتك الدراسية عرضة للغبار. شاركها مع طلاب علم آخرين، واجعلها وسيلة للنفع بعد انتهائك منها.',
      badge: 'تبادل الموارد، تعزيز المعرفة',
      isHadith: true,
    ),
    _OnboardingPageData(
      imagePath: 'assets/images/onboarding_articles.png',
      title: 'قال رسول الله ﷺ: «إِذَا مَاتَ الْإِنْسَانُ انْقَطَعَ عَنْهُ عَمَلُهُ إِلا مِنْ ثَلاثَةٍ: إِلا مِنْ صَدَقَةٍ جَارِيَةٍ، أَوْ عِلْمٍ يُنْتَفَعُ بِهِ...»',
      description:
          'اكتب مقالات نافعة وشارك خبراتك العلمية لتكون لك صدقة جارية يستمر أجرها ونفعها.',
      badge: 'عِلْمٌ يُنْتَفَعُ بِهِ',
      isHadith: true,
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

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (!mounted) return;
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
                  return _OnboardingPage(data: _pages[index]);
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
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: AppColors.primary,
                size: 26.w,
              ),
              SizedBox(width: 8.w),
              Text(
                'زكاة العلم',
                style: AppTypography.arabicTitle(
                  color: AppColors.onSurface,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const Spacer(),
          // زر التخطي
          GestureDetector(
            onTap: _completeOnboarding,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.outline.withValues(alpha: 0.15),
                ),
              ),
              child: Text(
                'تخطي',
                style: AppTypography.arabicLabel(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 13,
                ),
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
      effect: ExpandingDotsEffect(
        dotHeight: 8.h,
        dotWidth: 8.w,
        expansionFactor: 3,
        spacing: 6.w,
        activeDotColor: AppColors.primary,
        dotColor: AppColors.surfaceContainerHighest,
      ),
    );
  }

  Widget _buildBottomSection() {
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
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
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
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final String imagePath;
  final String title;
  final String description;
  final String badge;
  final bool isHadith;

  const _OnboardingPageData({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.badge,
    this.isHadith = false,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingPageData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // عرض الصورة بدلاً من الأيقونة مع هالة خلفية أنيقة
          Container(
            height: 220.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: AppColors.outline.withValues(alpha: 0.1),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: Image.asset(
                data.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // عنصر احتياطي في حال لم تكن الصورة مرفوعة بعد لتجنب انهيار الواجهة
                  return Icon(
                    Icons.image_outlined,
                    size: 64.w,
                    color: AppColors.primary.withValues(alpha: 0.5),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 32.h),
          // شارة تعبيرية أنيقة
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              data.badge,
              style: AppTypography.arabicCaption(
                color: AppColors.primary,
                fontSize: 13,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          // العنوان (الحديث الشريف)
          Text(
            data.title,
            style: AppTypography.arabicHeadline(
              color: AppColors.onSurface,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 14.h),
          // الوصف
          Text(
            data.description,
            style: AppTypography.arabicBody(
              color: AppColors.onSurfaceVariant,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}