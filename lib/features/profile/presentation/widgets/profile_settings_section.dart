import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';

class ProfileSettingsSection extends StatelessWidget {
  const ProfileSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
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
                // _SettingsItem(
                //   icon: Icons.privacy_tip_outlined,
                //   title: 'profile.privacy'.tr(),
                //   onTap: () {},
                // ),
                // Divider(
                //   color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                //   height: 1,
                //   indent: 56.w,
                // ),
                // _SettingsItem(
                //   icon: Icons.bug_report_outlined,
                //   title: 'profile.report_bug'.tr(),
                //   onTap: () {},
                // ),
                // Divider(
                //   color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                //   height: 1,
                //   indent: 56.w,
                // ),
                // _SettingsItem(
                //   icon: Icons.delete_outline,
                //   title: 'profile.delete_account'.tr(),
                //   titleColor: Theme.of(context).colorScheme.error,
                //   iconColor: Theme.of(context).colorScheme.error,
                //   onTap: () {},
                // ),
                // Divider(
                //   color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                //   height: 1,
                //   indent: 56.w,
                // ),
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
                context: context,
                label: 'profile.language_ar'.tr(),
                isSelected: context.locale.languageCode == 'ar',
                onTap: () {
                  context.setLocale(const Locale('ar'));
                  Navigator.pop(sheetCtx);
                },
              ),
              _languageOption(
                sheetCs,
                context: context,
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

  Widget _languageOption(
    ColorScheme cs, {
    required BuildContext context,
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
      trailing: isSelected ? Icon(Icons.check, color: cs.primary, size: 22.w) : null,
    );
  }

  void _handleLogout(BuildContext context) {
    context.read<AuthCubit>().signOut();
    // context.go(AppRoutes.login);
  }
}

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
      trailing: trailing ??
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