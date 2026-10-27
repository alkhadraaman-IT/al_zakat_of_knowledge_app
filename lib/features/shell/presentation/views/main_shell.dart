import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState; // 1. أضف مكتبة سوبابيس

import '../../../../app/theme/app_typography.dart';
import '../../../articles/presentation/bloc/article_cubit.dart';
import '../../../../shared/widgets/app_top_header.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../content_creation/presentation/widgets/content_type_selector.dart';
import '../../../favorites/presentation/views/favorites_view.dart';
import '../../../home/presentation/views/home_view.dart';

/// Main navigation shell — Stitch Design System.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  
  // متغيرات لتخزين بيانات البروفايل (الاسم والصورة من جدول profiles مباشرة)
  String? _profileName;
  String? _profilePhotoUrl;

  final List<Widget> _screens = const [
    HomeView(),
    FavoritesView(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserProfile(); // جلب بيانات البروفايل عند فتح الشل
  }

  /// جلب بيانات البروفايل من جدول profiles تماماً مثل صفحة البروفايل
  Future<void> _fetchUserProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final response = await Supabase.instance.client
          .from('profiles')
          .select('name, photo_url')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null && mounted) {
        setState(() {
          _profileName = response['name']?.toString();
          _profilePhotoUrl = response['photo_url']?.toString();
        });
      }
    } catch (e) {
      debugPrint('<<<<<<<<< MainShell Profile Fetch Error: $e >>>>>>>>>');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _fetchUserProfile(); // إعادة الجلب عند تسجيل الدخول
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(64.h),
          child: SafeArea(
            bottom: false,
            child: _buildTopHeader(context),
          ),
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: _buildBottomNavDock(context),
      ),
    );
  }

  /// Fixed Top Header Bar — يعرض الصورة أو الحرف الأول من جدول profiles
  Widget _buildTopHeader(BuildContext context) {
    // استخدام الاسم من البروفايل، وإلا كبديل من الـ AuthCubit
    final authState = context.watch<AuthCubit>().state;
    String? fallbackName;
    if (authState is AuthAuthenticated) {
      fallbackName = authState.user.fullName;
    }

    final displayName = _profileName ?? fallbackName;
    final String userInitial = (displayName != null && displayName.trim().isNotEmpty) 
        ? displayName.trim()[0] 
        : 'م';

    return AppTopHeader(
      context: context,
      trailing: Row(
        children: [
          // Notification bell
          GestureDetector(
            onTap: () => context.push('/notifications'),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.6),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.notifications_outlined,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20.w,
                    ),
                  ),
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surface,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Avatar — يعرض الصورة الحقيقية من جدول profiles أو الحرف الأول
          GestureDetector(
            onTap: () async {
              await context.push('/profile');
              _fetchUserProfile(); // تحديث الصورة عند العودة من صفحة البروفايل في حال تم تغييرها
            },
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 12.r,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: (_profilePhotoUrl != null && _profilePhotoUrl!.trim().isNotEmpty)
                    ? Image.network(
                        _profilePhotoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(
                            userInitial,
                            style: AppTypography.arabicTitle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          userInitial,
                          style: AppTypography.arabicTitle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 18,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavDock(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        bottom: 24.h,
      ),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 20.r,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavItem(
            icon: Icons.bookmark_outline,
            label: '',
            isActive: _currentIndex == 1,
            onTap: () => setState(() => _currentIndex = 1),
          ),
          SizedBox(
            width: 56.w,
            child: Transform.translate(
              offset: Offset(0, -20.h),
              child: GestureDetector(
                onTap: () => showContentTypeSelector(
                  context,
                  onArticleCreated: () {
                    if (mounted) {
                      context.read<ArticleCubit>().getArticles();
                    }
                  },
                ),
                child: Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                        blurRadius: 20.r,
                        spreadRadius: 0,
                      ),
                    ],
                    border: Border.all(color: Theme.of(context).colorScheme.surface, width: 4),
                  ),
                  child: Icon(
                    Icons.add,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 32.w,
                  ),
                ),
              ),
            ),
          ),
          _NavItem(
            icon: Icons.home_outlined,
            label: '',
            isActive: _currentIndex == 0,
            onTap: () => setState(() => _currentIndex = 0),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
          border: isActive
              ? Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 22.w,
            ),
            if (isActive) ...[
              SizedBox(width: 8.w),
              Text(
                label,
                style: AppTypography.arabicLabel(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}