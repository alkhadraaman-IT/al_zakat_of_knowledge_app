import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';

/// Academic registration screen — modern card-based design.
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
    setState(() {
      _termsError = !_acceptedTerms;
    });

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
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go(AppRoutes.home);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Stack(
            children: [
              // Background gradient
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.backgroundGradient,
                  ),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                    vertical: AppSpacing.screenVertical,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildBackButton(),
                        SizedBox(height: AppSpacing.lg),
                        _buildHeader(),
                        SizedBox(height: AppSpacing.xl),
                        _buildFormCard(),
                        SizedBox(height: AppSpacing.lg),
                        _buildTermsCharter(),
                        SizedBox(height: AppSpacing.lg),
                        _buildRegisterButton(isLoading),
                        SizedBox(height: AppSpacing.xl),
                        _buildLoginLink(),
                      ],
                    ),
                  ),
                ),
              ),
              if (isLoading) _buildLoadingOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(
          Icons.arrow_back,
          color: AppColors.onSurface,
          size: 24.w,
        ),
        style: IconButton.styleFrom(
          backgroundColor: AppColors.surface,
          padding: EdgeInsets.all(12.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 88.w,
          height: 88.w,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 24.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Icon(
            Icons.person_add_outlined,
            size: 44.w,
            color: AppColors.onPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        Text(
          'auth.sign_up'.tr(),
          style: AppTypography.arabicDisplay(
            color: AppColors.onSurface,
            fontSize: 32,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          'auth.create_new_account'.tr(),
          style: AppTypography.arabicBody(
            color: AppColors.onSurfaceVariant,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 24.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFullNameField(),
          SizedBox(height: AppSpacing.md),
          _buildUniversityField(),
          SizedBox(height: AppSpacing.md),
          _buildEmailField(),
          SizedBox(height: AppSpacing.md),
          _buildPasswordField(),
          SizedBox(height: AppSpacing.md),
          _buildConfirmPasswordField(),
        ],
      ),
    );
  }

  Widget _buildFullNameField() {
    return _ModernTextField(
      label: 'auth.full_name'.tr(),
      hint: 'auth.full_name_hint'.tr(),
      controller: _fullNameController,
      focusNode: _fullNameFocusNode,
      prefixIcon: Icons.person_outline,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'validation.required'.tr();
        }
        if (value.length < 3) {
          return 'validation.name_short'.tr();
        }
        return null;
      },
    );
  }

  Widget _buildUniversityField() {
    return _ModernTextField(
      label: 'auth.university'.tr(),
      hint: 'auth.university_hint'.tr(),
      controller: _universityController,
      focusNode: _universityFocusNode,
      prefixIcon: Icons.account_balance_outlined,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'validation.university_required'.tr();
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return _ModernTextField(
      label: 'auth.email'.tr(),
      hint: 'auth.email_hint'.tr(),
      controller: _emailController,
      focusNode: _emailFocusNode,
      keyboardType: TextInputType.emailAddress,
      prefixIcon: Icons.email_outlined,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'validation.required'.tr();
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'validation.invalid_email'.tr();
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return _ModernTextField(
      label: 'auth.password'.tr(),
      hint: 'auth.password_hint'.tr(),
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      isPassword: true,
      prefixIcon: Icons.lock_outline,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'validation.required'.tr();
        }
        if (value.length < 8) {
          return 'validation.password_short'.tr();
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return _ModernTextField(
      label: 'auth.confirm_password'.tr(),
      hint: 'auth.confirm_password_hint'.tr(),
      controller: _confirmPasswordController,
      focusNode: _confirmPasswordFocusNode,
      isPassword: true,
      prefixIcon: Icons.lock_outline,
      textInputAction: TextInputAction.done,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'validation.required'.tr();
        }
        if (value != _passwordController.text) {
          return 'validation.password_mismatch'.tr();
        }
        return null;
      },
    );
  }

  Widget _buildTermsCharter() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _acceptedTerms = !_acceptedTerms;
          _termsError = false;
        });
      },
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: _acceptedTerms
              ? AppColors.primary.withValues(alpha: 0.05)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: _termsError
                ? AppColors.error
                : _acceptedTerms
                    ? AppColors.primary
                    : AppColors.outline,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24.w,
              height: 24.w,
              child: Checkbox(
                value: _acceptedTerms,
                onChanged: (value) {
                  setState(() {
                    _acceptedTerms = value ?? false;
                    _termsError = false;
                  });
                },
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'auth.terms_agreement'.tr(),
                    style: AppTypography.arabicLabel(
                      color: AppColors.onSurface,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'auth.terms_description'.tr(),
                    style: AppTypography.arabicCaption(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterButton(bool isLoading) {
    return _ModernButton(
      text: 'auth.sign_up_button'.tr(),
      onPressed: _onRegister,
      isLoading: isLoading,
      isPrimary: true,
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'auth.has_account'.tr(),
          style: AppTypography.arabicBody(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: () => context.pop(),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'auth.already_have_account'.tr(),
            style: AppTypography.arabicLabel(
              color: AppColors.primary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: AppColors.onSurface.withValues(alpha: 0.3),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

/// Modern text field with card-based styling.
class _ModernTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputType keyboardType;
  final bool isPassword;
  final IconData prefixIcon;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;

  const _ModernTextField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.focusNode,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    required this.prefixIcon,
    this.textInputAction = TextInputAction.next,
    this.validator,
  });

  @override
  State<_ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<_ModernTextField> {
  bool _obscureText = true;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = widget.focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTypography.arabicLabel(
            color: AppColors.onSurface,
            fontSize: 14,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: _hasFocus
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 12.r,
                      spreadRadius: 1.r,
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            obscureText: _obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            style: AppTypography.arabicBody(fontSize: 16),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTypography.arabicBody(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                fontSize: 16,
              ),
              prefixIcon: Icon(
                widget.prefixIcon,
                color: _hasFocus ? AppColors.primary : AppColors.onSurfaceVariant,
                size: 22.w,
              ),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.onSurfaceVariant,
                        size: 22.w,
                      ),
                      onPressed: () => setState(() => _obscureText = !_obscureText),
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surfaceVariant,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.error, width: 1.5),
              ),
            ),
            validator: widget.validator,
          ),
        ),
      ],
    );
  }
}

/// Modern button with gradient and shadow.
class _ModernButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPrimary;

  const _ModernButton({
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
  });

  @override
  State<_ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<_ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => _controller.forward(),
      onTapUp: isDisabled ? null : (_) => _controller.reverse(),
      onTapCancel: isDisabled ? null : () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: 56.h,
              decoration: BoxDecoration(
                gradient: widget.isPrimary && !isDisabled
                    ? AppColors.primaryGradient
                    : null,
                color: widget.isPrimary
                    ? null
                    : (isDisabled ? AppColors.surfaceVariant : AppColors.surface),
                borderRadius: BorderRadius.circular(16.r),
                border: widget.isPrimary
                    ? null
                    : Border.all(
                        color: isDisabled ? AppColors.outline : AppColors.primary,
                        width: 1.5,
                      ),
                boxShadow: widget.isPrimary && !isDisabled
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 16.r,
                          offset: Offset(0, 4.h),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isDisabled ? null : widget.onPressed,
                  borderRadius: BorderRadius.circular(16.r),
                  child: Center(
                    child: widget.isLoading
                        ? SizedBox(
                            width: 24.w,
                            height: 24.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.isPrimary
                                    ? AppColors.onPrimary
                                    : AppColors.primary,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.text,
                                style: AppTypography.button(
                                  color: widget.isPrimary
                                      ? AppColors.onPrimary
                                      : AppColors.primary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
