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
import '../widgets/auth_text_field.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _universityController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final _fullNameFocusNode = FocusNode();
  final _universityFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _acceptedTerms = false;
  bool _termsError = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _universityController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameFocusNode.dispose();
    _universityFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _onRegister() {
    setState(() => _termsError = !_acceptedTerms);
    if (_formKey.currentState?.validate() ?? false) {
      if (_acceptedTerms) {
        context.read<AuthCubit>().signUp(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              fullName: _fullNameController.text.trim(),
              university: _universityController.text.trim(),
            );
      }
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
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: IconButton(
                            onPressed: () => context.pop(),
                            icon: Icon(Icons.arrow_back, color: cs.onSurface),
                            style: IconButton.styleFrom(
                              backgroundColor: cs.surfaceContainerLow,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.lg),
                        const AuthHeader(
                          icon: Icons.person_add_outlined,
                          title: 'auth.sign_up',
                          subtitle: 'auth.create_new_account',
                        ),
                        SizedBox(height: AppSpacing.xl),
                        _buildFormCard(context),
                        SizedBox(height: AppSpacing.lg),
                        _buildTermsCharter(context),
                        SizedBox(height: AppSpacing.lg),
                        AuthButton(
                          text: 'auth.sign_up_button',
                          onPressed: _onRegister,
                          isLoading: isLoading,
                          isPrimary: true,
                        ),
                        SizedBox(height: AppSpacing.xl),
                        _buildLoginLink(context),
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

  Widget _buildFormCard(BuildContext context) {
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
            label: 'auth.full_name',
            hint: 'auth.full_name_hint',
            controller: _fullNameController,
            focusNode: _fullNameFocusNode,
            prefixIcon: Icons.person_outline,
            validator: (v) => (v == null || v.isEmpty) ? 'validation.required'.tr() : (v.length < 3 ? 'validation.name_short'.tr() : null),
          ),
          SizedBox(height: AppSpacing.md),
          AuthTextField(
            label: 'auth.university',
            hint: 'auth.university_hint',
            controller: _universityController,
            focusNode: _universityFocusNode,
            prefixIcon: Icons.account_balance_outlined,
            validator: (v) => (v == null || v.isEmpty) ? 'validation.university_required'.tr() : null,
          ),
          SizedBox(height: AppSpacing.md),
          AuthTextField(
            label: 'auth.email',
            hint: 'auth.email_hint',
            controller: _emailController,
            focusNode: _emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) return 'validation.required'.tr();
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'validation.invalid_email'.tr();
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
            validator: (value) => (value == null || value.length < 8) ? 'validation.password_short'.tr() : null,
          ),
          SizedBox(height: AppSpacing.md),
          AuthTextField(
            label: 'auth.confirm_password',
            hint: 'auth.confirm_password_hint',
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocusNode,
            isPassword: true,
            prefixIcon: Icons.lock_outline,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) return 'validation.required'.tr();
              if (value != _passwordController.text) return 'validation.password_mismatch'.tr();
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCharter(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => setState(() { _acceptedTerms = !_acceptedTerms; _termsError = false; }),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: _acceptedTerms ? cs.primary.withValues(alpha: 0.05) : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: _termsError ? cs.error : (_acceptedTerms ? cs.primary : cs.outline)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24.w, height: 24.w,
              child: Checkbox(
                value: _acceptedTerms,
                onChanged: (v) => setState(() { _acceptedTerms = v ?? false; _termsError = false; }),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('auth.terms_agreement'.tr(), style: AppTypography.arabicLabel(color: cs.onSurface, fontSize: 14)),
                  SizedBox(height: AppSpacing.xs),
                  Text('auth.terms_description'.tr(), style: AppTypography.arabicCaption(color: cs.onSurfaceVariant, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('auth.has_account'.tr(), style: AppTypography.arabicBody(color: cs.onSurfaceVariant)),
        TextButton(
          onPressed: () => context.pop(),
          child: Text('auth.already_have_account'.tr(), style: AppTypography.arabicLabel(color: cs.primary, fontSize: 14)),
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