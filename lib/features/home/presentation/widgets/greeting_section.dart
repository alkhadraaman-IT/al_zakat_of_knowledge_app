import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class GreetingSection extends StatelessWidget {
  const GreetingSection();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'home.greeting'.tr(),
            style: AppTypography.arabicBody(
              color: cs.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  final userName = state is AuthAuthenticated
                      ? state.user.fullName.split(' ').first
                      : 'home.guest_name'.tr();
                  return Text(
                    userName,
                    style: AppTypography.arabicHeadline(
                      color: cs.onSurface,
                      fontSize: 24,
                    ),
                  );
                },
              ),
              SizedBox(width: 8.w),
              Text('👋', style: TextStyle(fontSize: 24.sp)),
            ],
          ),
        ],
      ),
    );
  }
}
