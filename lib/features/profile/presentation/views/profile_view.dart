import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_refresh.dart';   // ✅ جديد
import '../../../../shared/widgets/app_top_header.dart';
import '../../../articles/presentation/bloc/article_cubit.dart';
import '../../../articles/presentation/cubit/categories_cubit.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../study_tools/presentation/cubit/study_tool_cubit.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/profile_activity_tabs.dart';
import '../widgets/profile_card.dart';
import '../widgets/profile_interests_section.dart';
import '../widgets/profile_settings_section.dart';

class ProfileView extends StatelessWidget {
  final String? userId;

  const ProfileView({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<FavoritesCubit>()),
        BlocProvider.value(value: sl<StudyToolCubit>()),
        BlocProvider.value(value: sl<ArticleCubit>()),
        BlocProvider.value(value: sl<CategoriesCubit>()),
        BlocProvider(
          create: (context) {
            final authState = context.read<AuthCubit>().state;
            String? authUserId;
            if (authState is AuthAuthenticated) {
              authUserId = authState.user.id;
            }
            return ProfileCubit(userId: userId)..loadProfileData(authUserId);
          },
        ),
      ],
      // ✅ نلفّ الجسم بمستمع إشارة التحديث
      child: const _ProfileRefreshListener(
        child: _ProfileViewBody(),
      ),
    );
  }
}

/// يستمع إلى [AppRefresh.profile] ويعيد جلب بيانات البروفايل
/// عند إشارة تحديث (مثل حذف محاضرة من شاشة أخرى).
class _ProfileRefreshListener extends StatefulWidget {
  final Widget child;

  const _ProfileRefreshListener({required this.child});

  @override
  State<_ProfileRefreshListener> createState() =>
      _ProfileRefreshListenerState();
}

class _ProfileRefreshListenerState extends State<_ProfileRefreshListener> {
  @override
  void initState() {
    super.initState();
    AppRefresh.profile.addListener(_onRefreshRequested);
  }

  @override
  void dispose() {
    AppRefresh.profile.removeListener(_onRefreshRequested);
    super.dispose();
  }

  void _onRefreshRequested() {
    if (!mounted) return;
    final cubit = context.read<ProfileCubit>();

    // نُعيد الجلب فقط لبروفايل المالك
    // (البروفايل العام لا يتأثر بحذف المحاضرات من مالك آخر)
    if (cubit.userId != null) return;

    final authState = context.read<AuthCubit>().state;
    String? authUserId;
    if (authState is AuthAuthenticated) authUserId = authState.user.id;

    cubit.loadProfileData(authUserId);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _ProfileViewBody extends StatelessWidget {
  const _ProfileViewBody();

  String? _resolveAuthUserId(BuildContext context) {
    final state = context.read<AuthCubit>().state;
    if (state is AuthAuthenticated) return state.user.id;
    return null;
  }

  Future<void> _openUrl(
    BuildContext context,
    String urlString, {
    bool isPdf = false,
  }) async {
    String formattedUrl = urlString.trim();
    if (!formattedUrl.startsWith('http://') &&
        !formattedUrl.startsWith('https://')) {
      formattedUrl = 'https://$formattedUrl';
    }

    final Uri url = Uri.parse(formattedUrl);

    try {
      if (isPdf) {
        await launchUrl(url, mode: LaunchMode.inAppWebView);
      } else {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('profile.link_open_failed'.tr())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileCubit>();
    final isOwnerProfile = cubit.userId == null;
    final authUserId = _resolveAuthUserId(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading || state is ProfileInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProfileLoaded) {
              if (state.publicNotFound) {
                return Column(
                  children: [
                    AppTopHeader(
                      context: context,
                      onBack: Navigator.canPop(context)
                          ? () => Navigator.maybePop(context)
                          : null,
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: Center(
                          child: Text(
                            'profile.not_found'.tr(),
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              final profile = state.profile;
              return SingleChildScrollView(
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
                    ProfileCard(
                      name: profile?.name ?? '',
                      email: '',
                      city: profile?.city ?? '',
                      university: profile?.university ?? '',
                      photoUrl: profile?.photoUrl,
                      cvPdfUrl: profile?.cvPdfUrl,
                      githubUrl: profile?.githubUrl,
                      linkedInUrl: profile?.linkedinUrl,
                      isOwnerProfile: isOwnerProfile,
                      onProfileUpdated: () => cubit.loadProfileData(authUserId),
                      onOpenUrl: (url, {isPdf = false}) =>
                          _openUrl(context, url, isPdf: isPdf),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    ProfileActivityTabs(
                      isOwnerProfile: isOwnerProfile,
                      isLoadingLectures: false,
                      isLoadingArticles: false,
                      isLoadingTools: false,
                      isLoadingBookings: false,
                      lectures: state.lectures,
                      articles: state.articles,
                      tools: state.tools,
                      bookings: state.bookings,
                    ),
                    if (isOwnerProfile) ...[
                      SizedBox(height: AppSpacing.lg),
                      ProfileInterestsSection(
                        isLoadingCategories: false,
                        categories: state.categories,
                        selectedCategoryIds: state.selectedCategoryIds,
                        userId: authUserId,
                        onCategoryToggled: (catId, isSelected) {
                          if (authUserId != null) {
                            cubit.toggleCategoryInterest(catId, authUserId);
                          }
                        },
                      ),
                      SizedBox(height: AppSpacing.lg),
                      const ProfileSettingsSection(),
                    ],
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}