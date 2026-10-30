import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart'; // سننشئ هذا الملف للمكونات المشتركة

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go(AppRoutes.home);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: cs.error),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Stack(
            children: [
              // خلفية متدرجة تتوافق مع الثيم
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [cs.surface, cs.primary.withValues(alpha: 0.05)],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                    vertical: AppSpacing.screenVertical,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: AppSpacing.xl.h),
                        const AuthHeader(
                          title: 'auth.login',
                          subtitle: 'auth.login_subtitle',
                        ),
                        SizedBox(height: AppSpacing.xl.h),
                        _buildLoginCard(context, isLoading),
                        SizedBox(height: AppSpacing.lg),
                        _buildDivider(context),
                        SizedBox(height: AppSpacing.lg),
                        _buildSignUpLink(context),
                        SizedBox(height: AppSpacing.xl.h),
                      ],
                    ),
                  ),
                ),
              ),
              if (isLoading) _buildLoadingOverlay(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context, bool isLoading) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.08),
            blurRadius: 24.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            label: 'auth.email',
            hint: 'auth.email_hint',
            controller: _emailController,
            focusNode: _emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'validation.required'.tr();
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'validation.invalid_email'.tr();
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.md),
          AuthTextField(
            label: 'auth.password',
            hint: 'auth.password_hint',
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            isPassword: true,
            prefixIcon: Icons.lock_outline,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'validation.required'.tr();
              if (value.length < 8) return 'validation.password_short'.tr();
              return null;
            },
          ),
          SizedBox(height: AppSpacing.lg),
          AuthButton(
            text: 'auth.login_button',
            onPressed: _onLogin,
            isLoading: isLoading,
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(child: Divider(color: cs.outline)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'auth.or'.tr(),
            style: AppTypography.arabicCaption(color: cs.onSurfaceVariant),
          ),
        ),
        Expanded(child: Divider(color: cs.outline)),
      ],
    );
  }

  Widget _buildSignUpLink(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'auth.no_account'.tr(),
          style: AppTypography.arabicBody(color: cs.onSurfaceVariant),
        ),
        TextButton(
          onPressed: () => context.push(AppRoutes.register),
          child: Text(
            'auth.sign_up'.tr(),
            style: AppTypography.arabicLabel(color: cs.primary, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Positioned.fill(
      child: Container(
        color: cs.onSurface.withValues(alpha: 0.3),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
