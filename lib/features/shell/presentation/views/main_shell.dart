import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../articles/presentation/bloc/article_cubit.dart';
import '../../../../shared/widgets/app_top_header.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../content_creation/presentation/widgets/content_type_selector.dart';
import '../../../favorites/presentation/views/favorites_view.dart';
import '../../../home/presentation/views/home_view.dart';

/// Main navigation shell — Stitch Design System.
/// True persistent shell: Top Header Bar and Bottom Navigation Dock remain
/// 100% fixed across all main tabs. Body content swaps dynamically.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  /// Body content screens — swapped dynamically via IndexedStack.
  /// Top header and bottom nav remain fixed.
  final List<Widget> _screens = const [
    HomeView(),
    FavoritesView(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // AuthCubit handles navigation via GoRouter refresh
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        // ── Fixed Top Header Bar (persistent) ──────────────────
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(64.h),
          child: SafeArea(
            bottom: false,
            child: _buildTopHeader(context),
          ),
        ),
        // ── Dynamic Body Content (swaps on tab change) ─────────
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        // ── Fixed Bottom Navigation Dock (persistent) ─────────
        bottomNavigationBar: _buildBottomNavDock(context),
      ),
    );
  }

  /// Fixed Top Header Bar — standard AppTopHeader with bell + avatar trailing.
  Widget _buildTopHeader(BuildContext context) {
    return AppTopHeader(
      context: context,
      trailing: Row(
        children: [
          // Notification bell — navigates to notifications
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
          // Avatar — navigates to Profile
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
                    blurRadius: 12.r,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'ع',
                  style: AppTypography.arabicTitle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Fixed Bottom Navigation Dock — never destroyed, always visible.
  /// RTL layout: Favorites (left) | Plus (center, FIXED) | Home (right).
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
          BoxShadow(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
            blurRadius: 35.r,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Favorites tab (left side in RTL)
          _NavItem(
            icon: Icons.bookmark_outline,
            label: '',
            // label: 'المفضلة',
            isActive: _currentIndex == 1,
            onTap: () => setState(() => _currentIndex = 1),
          ),

          // Center raised add dome — FIXED position, never shifts
          SizedBox(
            width: 56.w,
            child: Transform.translate(
              offset: Offset(0, -20.h),
              child: GestureDetector(
                onTap: () => showContentTypeSelector(
                  context,
                  // Refresh the feed through the cubit once an
                  // article is published — the BlocConsumer in
                  // HomeView rebuilds with the new list.
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

          // Home tab (right side in RTL)
          _NavItem(
            icon: Icons.home_outlined,
            label: '',
            // label: 'الرئيسية',
            isActive: _currentIndex == 0,
            onTap: () => setState(() => _currentIndex = 0),
          ),
        ],
      ),
    );
  }
}

/// Navigation item widget.
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
