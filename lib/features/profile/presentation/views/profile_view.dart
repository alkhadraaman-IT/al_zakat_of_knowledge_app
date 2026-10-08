import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../shared/widgets/app_article_card.dart';
import '../../../../shared/widgets/app_segmented_bar.dart';
import '../../../../shared/widgets/app_session_card.dart';
import '../../../../shared/widgets/app_study_tool_card.dart';
import '../../../../shared/widgets/app_top_header.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../widgets/edit_profile_sheet.dart';

/// Profile screen — Stitch Design System.
/// Strict OLED dark theme (#0B1120 canvas, #0F172A surface).
/// Settings section uses Material widget (not Container) for correct ink splash rendering.
class ProfileView extends StatefulWidget {
  /// Optional viewed-user id — set when navigating to `/profile/:id`
  /// (e.g. from a session lecturer card).
  final String? userId;

  const ProfileView({super.key, this.userId});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  int _activityTab = 0;
  final Set<int> _selectedInterests = {0, 4}; // Default: طبي, أكاديمي

  /// Editable display name and bio — the owner's raw user data
  /// (content, not UI chrome — intentionally not localized).
  String _name = 'أبو عبدالله المالكي';
  String _bio = 'طالب علم — جامعة الملك سعود';

  /// True when viewing the signed-in owner's own profile
  /// (no `:id` param). Public lecturer profiles (`/profile/:id`)
  /// hide owner-only tabs and actions to protect privacy.
  bool get _isOwnerProfile => widget.userId == null;

  static final List<String> _interestCategories = [
    'profile.interest_medical'.tr(),
    'profile.interest_programming'.tr(),
    'profile.interest_commercial'.tr(),
    'profile.interest_self_dev'.tr(),
    'profile.interest_academic'.tr(),
    'profile.interest_sharia'.tr(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTopHeader(
                context: context,
                onBack: Navigator.canPop(context)
                    ? () => Navigator.maybePop(context)
                    : null,
              ),
              SizedBox(height: AppSpacing.md),
              _buildProfileCard(context),
              SizedBox(height: AppSpacing.lg),
              _buildActivityDashboard(context),
              if (_isOwnerProfile) ...[
                SizedBox(height: AppSpacing.lg),
                _buildInterestsSection(context),
                SizedBox(height: AppSpacing.lg),
                _buildSettingsSection(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              blurRadius: 24.r,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primaryContainer,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                        blurRadius: 16.r,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _name.trim().isNotEmpty ? _name.trim()[0] : 'ع',
                      style: AppTypography.arabicDisplay(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 28,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _name,
                        style: AppTypography.arabicHeadline(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _bio,
                        style: AppTypography.arabicBody(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 18.w,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '٤.٩',
                            style: AppTypography.monoLabel(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              '٣٢٤ نقطة وقف',
                              style: AppTypography.arabicCaption(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_isOwnerProfile)
                  GestureDetector(
                    onTap: () => showEditProfileSheet(context, onNameSaved: (name) => setState(() => _name = name)),
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(
                        Icons.edit_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20.w,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: _SocialButton(
                    icon: Icons.code,
                    label: 'GitHub',
                    onTap: () => _showProfileLinksSheet(context),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _SocialButton(
                    icon: Icons.link,
                    label: 'LinkedIn',
                    onTap: () => _showProfileLinksSheet(context),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _SocialButton(
                    icon: Icons.description_outlined,
                    label: 'profile.cv'.tr(),
                    isPrimary: true,
                    onTap: () => _showProfileLinksSheet(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityDashboard(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'profile.dashboard'.tr(),
            style: AppTypography.arabicTitle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 12.h),
          AppSegmentedBar(
             labels: _isOwnerProfile
                 ? [
               'tabs.my_lectures'.tr(),
               'tabs.my_articles'.tr(),
               'tabs.my_tools'.tr(),
               'tabs.my_bookings'.tr(),
             ]
                 : [
                   'tabs.my_lectures'.tr(),
                   'tabs.my_articles'.tr(),
                 ],
             icons: _isOwnerProfile
                 ? const [
               Icons.groups_3,
               Icons.article_outlined,
               Icons.inventory_2_outlined,
               Icons.event_available,
             ]
                 : const [
                   Icons.groups_3,
                   Icons.article_outlined,
                 ],
            selectedIndex: _activityTab,
            onTabChanged: (index) {
              setState(() {
                _activityTab = index;
              });
            },
          ),
          SizedBox(height: 16.h),
          _buildTabContent(),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    // Public lecturer profile — public knowledge content only.
    if (!_isOwnerProfile) {
      return _activityTab == 1
          ? _buildPublicArticlesTab()
          : _buildPublicLecturesTab();
    }
    switch (_activityTab) {
      case 0:
        return _buildLecturesTab();
      case 1:
        return _buildArticlesTab();
      case 2:
        return _buildToolsTab();
      case 3:
        return _buildBookingsTab();
      default:
        return _buildLecturesTab();
    }
  }

  Widget _buildLecturesTab() {
    // Mock session ids — replace with real model ids when wired to backend.
    const sessionId1 = 'mock-lecture-1';
    const sessionId2 = 'mock-lecture-2';
    return Column(
      children: [
        GestureDetector(
          onTap: () => context.push('/session-details/$sessionId1?isPublisher=true'),
          child: _ActivityCard(
            status: 'profile.confirmed'.tr(),
            title: 'أصول الفقه العظيم — المجلس الثالث',
            description: 'دراسة تحليلية تأصيلية تتناول مباحث الإجماع والقياس',
            seats: '38/38',
            minSeats: 'profile.min_seats'.tr(namedArgs: {'value': '١٨'}),
          ),
        ),
        SizedBox(height: 12.h),
        GestureDetector(
          onTap: () => context.push('/session-details/$sessionId2?isPublisher=true'),
          child: _ActivityCard(
            status: 'profile.pending'.tr(),
            title: 'شرح كتاب التوحيد — درس جديد',
            description: 'شرح مبسط لكتاب التوحيد للشيخ محمد بن عبد الوهاب',
            seats: '42/59',
            minSeats: 'profile.min_seats'.tr(namedArgs: {'value': '١٥'}),
          ),
        ),
      ],
    );
  }

  Widget _buildArticlesTab() {
    return Column(
      children: [
        AppArticleCard(index: 0),
        SizedBox(height: 12.h),
        AppArticleCard(index: 1),
      ],
    );
  }

  Widget _buildToolsTab() {
    return Column(
      children: [
        AppStudyToolCard(index: 0),
        SizedBox(height: 12.h),
        AppStudyToolCard(index: 1),
      ],
    );
  }

  Widget _buildBookingsTab() {
    return Column(
      children: [
        const AppSessionCard(
          sessionId: 'mock-booking-1',
          title: 'أصول الفقه العظيم — المجلس الثالث',
          dateLabel: 'السبت، ١٠ أكتوبر',
          timeLabel: 'بعد المغرب',
          locationLabel: 'مسجد الراجحي — الرياض',
          mapPillLabel: 'مسجد الراجحي — الرياض',
        ),
        SizedBox(height: 12.h),
        const AppSessionCard(
          sessionId: 'mock-booking-2',
          title: 'شرح كتاب التوحيد — درس جديد',
          lecturerName: 'د. محمد العتيبي',
          lecturerInitial: 'م',
          dateLabel: 'الأحد، ١١ أكتوبر',
          timeLabel: 'بعد العشاء',
          locationLabel: 'جامع الملك فهد — الرياض',
          mapPillLabel: 'جامع الملك فهد — الرياض',
        ),
      ],
    );
  }

  /// Public lecturer profile — public sessions rendered
  /// with the exact Home Page session card (AppSessionCard).
  Widget _buildPublicLecturesTab() {
    return Column(
      children: [
        const AppSessionCard(
          sessionId: 'mock-public-1',
          title: 'أصول الفقه العظيم — المجلس الثالث',
          dateLabel: 'السبت، ١٠ أكتوبر',
          timeLabel: 'بعد المغرب',
          locationLabel: 'مسجد الراجحي — الرياض',
          mapPillLabel: 'مسجد الراجحي — الرياض',
        ),
        SizedBox(height: 12.h),
        const AppSessionCard(
          sessionId: 'mock-public-2',
          title: 'شرح كتاب التوحيد — درس جديد',
          lecturerName: 'د. محمد العتيبي',
          lecturerInitial: 'م',
          dateLabel: 'الأحد، ١١ أكتوبر',
          timeLabel: 'بعد العشاء',
          locationLabel: 'جامع الملك فهد — الرياض',
          mapPillLabel: 'جامع الملك فهد — الرياض',
        ),
        SizedBox(height: 12.h),
        const AppSessionCard(
          sessionId: 'mock-public-3',
          title: 'فقه المعاملات — المجلس الأول',
          lecturerName: 'د. سعد العتيبي',
          lecturerInitial: 'د',
          dateLabel: 'الجمعة، ٩ أكتوبر',
          timeLabel: 'بعد العصر',
          locationLabel: 'مسجد الجامعة — الرياض',
          mapPillLabel: 'مسجد الجامعة — الرياض',
        ),
      ],
    );
  }

  /// Public lecturer profile — published articles/reflections
  /// rendered with the shared article card (AppArticleCard).
  Widget _buildPublicArticlesTab() {
    return Column(
      children: [
        AppArticleCard(index: 0),
        SizedBox(height: 12.h),
        AppArticleCard(index: 1),
      ],
    );
  }

  /// Interests / Categories section — horizontal scrollable filter chips.
  Widget _buildInterestsSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'profile.interests'.tr(),
            style: AppTypography.arabicTitle(
              color: colorScheme.onSurface,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: List.generate(_interestCategories.length, (index) {
              final isSelected = _selectedInterests.contains(index);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedInterests.remove(index);
                    } else {
                      _selectedInterests.add(index);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary.withValues(alpha: 0.15)
                        : colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary.withValues(alpha: 0.5)
                          : colorScheme.outline,
                    ),
                  ),
                  child: Text(
                    _interestCategories[index],
                    style: AppTypography.arabicLabel(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Settings section — uses Material widget for correct ink splash rendering.
  /// Background color belongs to Material, NOT a child Container.
  Widget _buildSettingsSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'profile.settings'.tr(),
            style: AppTypography.arabicTitle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 12.h),
          Material(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16.r),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SettingsItem(
                  icon: Icons.dark_mode_outlined,
                  title: 'profile.night_mode'.tr(),
                  trailing: BlocBuilder<ThemeCubit, ThemeModeState>(
                    builder: (context, themeState) {
                      return Switch.adaptive(
                        value: themeState == ThemeModeState.dark,
                        activeThumbColor: Theme.of(context).colorScheme.primary,
                        activeTrackColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                        inactiveThumbColor: Theme.of(context).colorScheme.onSurfaceVariant,
                        inactiveTrackColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        onChanged: (_) {
                          context.read<ThemeCubit>().toggleTheme();
                        },
                      );
                    },
                  ),
                ),
                Divider(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  height: 1,
                  indent: 56.w,
                ),
                _SettingsItem(
                  icon: Icons.language_outlined,
                  title: 'profile.language'.tr(),
                  subtitle: context.locale.languageCode == 'ar'
                      ? 'profile.language_ar'.tr()
                      : 'profile.language_en'.tr(),
                  onTap: () => _showLanguageSheet(context),
                ),
                Divider(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  height: 1,
                  indent: 56.w,
                ),
                _SettingsItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'profile.privacy'.tr(),
                  onTap: () {},
                ),
                Divider(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  height: 1,
                  indent: 56.w,
                ),
                _SettingsItem(
                  icon: Icons.bug_report_outlined,
                  title: 'profile.report_bug'.tr(),
                  onTap: () {},
                ),
                Divider(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  height: 1,
                  indent: 56.w,
                ),
                _SettingsItem(
                  icon: Icons.delete_outline,
                  title: 'profile.delete_account'.tr(),
                  titleColor: Theme.of(context).colorScheme.error,
                  iconColor: Theme.of(context).colorScheme.error,
                  onTap: () {},
                ),
                Divider(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  height: 1,
                  indent: 56.w,
                ),
                _SettingsItem(
                  icon: Icons.logout,
                  title: 'profile.logout'.tr(),
                  onTap: () => _handleLogout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Language picker sheet — switches the app locale
  /// between Arabic and English via easy_localization.
  Future<void> _showLanguageSheet(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetCtx) {
        final sheetCs = Theme.of(sheetCtx).colorScheme;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: AppSpacing.sm),
              Text(
                'profile.language_sheet_title'.tr(),
                style: AppTypography.arabicTitle(
                  color: sheetCs.onSurface,
                  fontSize: 17,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              _languageOption(
                sheetCs,
                label: 'profile.language_ar'.tr(),
                isSelected: context.locale.languageCode == 'ar',
                onTap: () {
                  context.setLocale(const Locale('ar'));
                  Navigator.pop(sheetCtx);
                },
              ),
              _languageOption(
                sheetCs,
                label: 'profile.language_en'.tr(),
                isSelected: context.locale.languageCode == 'en',
                onTap: () {
                  context.setLocale(const Locale('en'));
                  Navigator.pop(sheetCtx);
                },
              ),
              SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }

  /// Single language row in the language picker sheet.
  Widget _languageOption(
    ColorScheme cs, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? cs.primary : cs.onSurfaceVariant,
        size: 22.w,
      ),
      title: Text(
        label,
        style: AppTypography.arabicBody(
          color: isSelected ? cs.primary : cs.onSurface,
          fontSize: 15,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: cs.primary, size: 22.w)
          : null,
    );
  }

  /// Sign out — clears the session/auth state via AuthBloc
  /// (Supabase session + local storage) and lands on the login route.
  void _handleLogout(BuildContext context) {
    context.read<AuthBloc>().add(const AuthSignOutRequested());
    context.go(AppRoutes.login);
  }

  /// Professional links sheet — the lecturer's academic
  /// summary, CV, and external links (GitHub / LinkedIn).
  Future<void> _showProfileLinksSheet(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetCtx) {
        final sheetCs = Theme.of(sheetCtx).colorScheme;
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: sheetCs.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'profile.about_title'.tr(),
                  style: AppTypography.arabicTitle(
                    color: sheetCs.onSurface,
                    fontSize: 17,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  _bio,
                  style: AppTypography.arabicBody(
                    color: sheetCs.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                Text(
                  'profile.links'.tr(),
                  style: AppTypography.arabicLabel(
                    color: sheetCs.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                _LinkRow(
                  colorScheme: sheetCs,
                  icon: Icons.description_outlined,
                  label: 'profile.cv'.tr(),
                  url: 'https://cv.almaliki.dev',
                ),
                SizedBox(height: AppSpacing.sm),
                _LinkRow(
                  colorScheme: sheetCs,
                  icon: Icons.code,
                  label: 'GitHub',
                  url: 'https://github.com/almaliki',
                ),
                SizedBox(height: AppSpacing.sm),
                _LinkRow(
                  colorScheme: sheetCs,
                  icon: Icons.link,
                  label: 'LinkedIn',
                  url: 'https://linkedin.com/in/almaliki',
                ),
                SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Link row widget — external link with a copy affordance.
class _LinkRow extends StatelessWidget {
  final ColorScheme colorScheme;
  final IconData icon;
  final String label;
  final String url;

  const _LinkRow({
    required this.colorScheme,
    required this.icon,
    required this.label,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: url));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('share.copied'.tr()),
            backgroundColor: colorScheme.primary,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary, size: 20.w),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                label,
                style: AppTypography.arabicBody(
                  color: colorScheme.onSurface,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(
              Icons.copy_outlined,
              color: colorScheme.onSurfaceVariant,
              size: 18.w,
            ),
          ],
        ),
      ),
    );
  }
}

/// Social button widget — dark theme.
class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback? onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    this.isPrimary = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: isPrimary
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isPrimary
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isPrimary ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
            size: 16.w,
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              label,
              style: AppTypography.arabicCaption(
                color: isPrimary
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      ),
    );
  }
}

/// Activity card widget — dark theme.
class _ActivityCard extends StatelessWidget {
  final String status;
  final String title;
  final String description;
  final String seats;
  final String minSeats;

  const _ActivityCard({
    required this.status,
    required this.title,
    required this.description,
    required this.seats,
    required this.minSeats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              status,
              style: AppTypography.arabicCaption(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 11,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: AppTypography.arabicTitle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            description,
            style: AppTypography.arabicCaption(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Text(
                minSeats,
                style: AppTypography.arabicCaption(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Text(
                seats,
                style: AppTypography.monoCaption(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Center(
              child: Text(
                'profile.cancel_48h'.tr(),
                style: AppTypography.arabicLabel(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Settings item widget.
class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? titleColor;
  final Color? iconColor;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.titleColor,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: iconColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
        size: 24.w,
      ),
      title: Text(
        title,
        style: AppTypography.arabicBody(
          color: titleColor ?? Theme.of(context).colorScheme.onSurface,
          fontSize: 16,
        ),
      ),
      trailing:
          trailing ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: AppTypography.arabicCaption(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              SizedBox(width: 8.w),
              Icon(
                Icons.chevron_left,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20.w,
              ),
            ],
          ),
    );
  }
}
