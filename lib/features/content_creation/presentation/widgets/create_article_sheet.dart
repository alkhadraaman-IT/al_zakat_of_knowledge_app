import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/di/injection_container.dart';
import '../../../articles/domain/entities/category_entity.dart';
import '../../../articles/domain/usecases/get_categories_usecase.dart';
import '../../../articles/presentation/bloc/article_cubit.dart';
import '../../../articles/presentation/bloc/article_state.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'success_dialog.dart';

/// Shows the article creation form as a modal bottom sheet.
///
/// Returns `true` when an article was successfully published
/// (after the dua success dialog is dismissed) — the caller
/// can use it to refresh its content list.
///
/// Optional [onSuccess] callback is invoked after a successful
/// publication (after the dua dialog is dismissed) — the caller
/// can use it to reload its articles list.
Future<bool> showCreateArticleSheet(
  BuildContext context, {
  VoidCallback? onSuccess,
}) async {
  // 1. نحفظ الـ Navigator المستقر قبل فتح الشاشة
  final navigator = Navigator.of(context);
  final articleCubit = sl<ArticleCubit>();

  final published = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => BlocProvider.value(
      value: articleCubit,
      child: const _CreateArticleSheet(),
    ),
  );

  // 2. إذا تم النشر بنجاح، نستخدم سياق الـ Navigator المحفوظ لإظهار الدعاء وتحديث القائمة
  if (published == true) {
    showSuccessDialog(navigator.context);
    onSuccess?.call();
  }

  return published ?? false;
}
class _CreateArticleSheet extends StatefulWidget {
  const _CreateArticleSheet();

  @override
  State<_CreateArticleSheet> createState() => _CreateArticleSheetState();
}

class _CreateArticleSheetState extends State<_CreateArticleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  List<CategoryEntity> _categories = const [];
  int? _selectedCategoryId;
  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  /// Loads the content categories from the `categories`
  /// table — falls back to the built-in taxonomy when
  /// the backend is unreachable.
  Future<void> _loadCategories() async {
    final result = await sl<GetCategoriesUseCase>()();
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _categories = _fallbackCategories()),
      (categories) => setState(() {
        _categories =
            categories.isEmpty ? _fallbackCategories() : categories;
      }),
    );
  }

  /// Built-in taxonomy fallback (mirrors the seeded
  /// `categories` rows) — used only when the table
  /// cannot be read.
  List<CategoryEntity> _fallbackCategories() {
    return const [
      CategoryEntity(
        id: 1,
        nameAr: 'علوم شريعة',
        nameEn: 'Islamic Sciences',
        sortOrder: 1,
      ),
      CategoryEntity(
        id: 2,
        nameAr: 'طب',
        nameEn: 'Medicine',
        sortOrder: 2,
      ),
      CategoryEntity(
        id: 3,
        nameAr: 'برمجة',
        nameEn: 'Programming',
        sortOrder: 3,
      ),
      CategoryEntity(
        id: 4,
        nameAr: 'تجارة',
        nameEn: 'Commerce',
        sortOrder: 4,
      ),
      CategoryEntity(
        id: 5,
        nameAr: 'تطوير ذاتي',
        nameEn: 'Self Development',
        sortOrder: 5,
      ),
      CategoryEntity(
        id: 6,
        nameAr: 'أكاديمي',
        nameEn: 'Academic',
        sortOrder: 6,
      ),
    ];
  }

  /// Publishes the article through [ArticleCubit] so the
  /// shared articles feed stays in sync. On success the
  /// sheet closes with `true` — the outer
  /// [showCreateArticleSheet] wrapper then shows the dua
  /// dialog and refreshes the list.
  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedCategoryId == null) {
      _showMessage('article.category_required'.tr());
      return;
    }

    final authorId = _resolveAuthorId();
    if (authorId == null) {
      _showMessage('article.error_auth'.tr());
      return;
    }

    setState(() => _isPublishing = true);

    // Publish through the cubit (not the use case directly)
    // so the shared articles feed updates automatically.
    await context.read<ArticleCubit>().createArticle(
          authorId: authorId,
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
          categoryId: _selectedCategoryId!,
        );

    if (!mounted) return;
    setState(() => _isPublishing = false);

    // The cubit's terminal state decides the outcome: only an
    // ArticleError fails — every other terminal state is a
    // success, so pop strictly with `true` and let the wrapper
    // below trigger the dua dialog and refresh the feed.
    final state = context.read<ArticleCubit>().state;
    if (state is ArticleError) {
      _showMessage(_friendlyError(state));
    } else {
      Navigator.pop(context, true);
    }
  }

  /// Current auth user id — the article's `author_id`.
  String? _resolveAuthorId() {
    final state = context.read<AuthCubit>().state;
    if (state is AuthAuthenticated) return state.user.id;
    return null;
  }

  /// Friendly localized message for a failed publication —
  /// maps the backend (Postgrest) SQLSTATE code, falling
  /// back to the exact failure message, then to the
  /// generic publish error.
  String _friendlyError(ArticleError state) {
    switch (state.code) {
      case '23503': // foreign-key violation — unknown category
        return 'article.error_invalid_category'.tr();
      case '23505': // unique violation
        return 'article.error_duplicate'.tr();
      case '42501': // RLS permission denied
        return 'article.error_permission'.tr();
      default:
        return state.message.isNotEmpty
            ? state.message
            : 'article.error_publish'.tr();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.all(20.w),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    margin: EdgeInsets.only(bottom: 20.h),
                    decoration: BoxDecoration(
                      color: cs.outline,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                Text('article.create_title'.tr(), style: AppTypography.arabicHeadline(color: cs.onSurface, fontSize: 20)),
                SizedBox(height: 20.h),
                _field(label: 'article.title_label'.tr(), hint: 'article.title_hint'.tr(), controller: _titleController,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'article.title_required'.tr();
                    final length = v.trim().length;
                    if (length < 3 || length > 200) return 'article.title_length'.tr();
                    return null;
                  }),
                SizedBox(height: 12.h),
                _field(label: 'article.body_label'.tr(), hint: 'article.body_hint'.tr(), controller: _bodyController, maxLines: 8,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'article.body_required'.tr();
                    if (v.trim().length > 20000) return 'article.body_too_long'.tr();
                    return null;
                  }),
                SizedBox(height: 12.h),
                _dropdown(cs),
                SizedBox(height: 24.h),
                Material(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(16.r),
                  child: InkWell(
                    onTap: _isPublishing ? null : _submit,
                    borderRadius: BorderRadius.circular(16.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Center(
                        child: _isPublishing
                            ? SizedBox(
                                height: 20.w,
                                width: 20.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: cs.onPrimary,
                                ),
                              )
                            : Text('article.publish'.tr(), style: AppTypography.arabicTitle(color: cs.onPrimary, fontSize: 18)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({required String label, required String hint, required TextEditingController controller, int maxLines = 1, String? Function(String?)? validator}) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.arabicLabel(color: cs.onSurface, fontSize: 14)),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller, maxLines: maxLines,
          style: AppTypography.arabicBody(color: cs.onSurface, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.arabicBody(color: cs.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 16),
            filled: true, fillColor: cs.surfaceContainerLow,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: cs.outline)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: cs.outline)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: cs.primary, width: 1.5)),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _dropdown(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('article.category_label'.tr(), style: AppTypography.arabicLabel(color: cs.onSurface, fontSize: 14)),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: cs.outline)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedCategoryId, isExpanded: true,
              hint: Text('article.category_hint'.tr(), style: AppTypography.arabicBody(color: cs.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 16)),
              items: _categories.map((category) {
                return DropdownMenuItem<int>(
                  value: category.id,
                  child: Text(category.nameFor(context.locale.languageCode), style: AppTypography.arabicBody(color: cs.onSurface, fontSize: 16)),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedCategoryId = v),
            ),
          ),
        ),
      ],
    );
  }
}
