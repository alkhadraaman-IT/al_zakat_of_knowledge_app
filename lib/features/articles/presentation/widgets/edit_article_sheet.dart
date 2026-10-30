import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/di/injection_container.dart';
import '../../../articles/domain/entities/article_entity.dart';
import '../../../articles/presentation/cubit/categories_cubit.dart';
import '../bloc/article_cubit.dart';
import '../bloc/article_state.dart';
import '../widgets/article_form_fields.dart'; // 👈 المكونات المشتركة

Future<void> showEditArticleSheet(
  BuildContext context, {
  required ArticleEntity article,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<ArticleCubit>()),
        BlocProvider.value(value: sl<CategoriesCubit>()),
      ],
      child: _EditArticleSheet(article: article),
    ),
  );
}

class _EditArticleSheet extends StatefulWidget {
  final ArticleEntity article;
  const _EditArticleSheet({required this.article});

  @override
  State<_EditArticleSheet> createState() => _EditArticleSheetState();
}

class _EditArticleSheetState extends State<_EditArticleSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  int? _selectedCategoryId;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.article.title);
    _bodyController = TextEditingController(text: widget.article.body);
    _selectedCategoryId = widget.article.categoryId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _formError = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedCategoryId == null) {
      setState(() => _formError = 'article.category_required'.tr());
      return;
    }
    context.read<ArticleCubit>().updateArticle(
          articleId: widget.article.id,
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
          categoryId: _selectedCategoryId!,
        );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocConsumer<ArticleCubit, ArticleState>(
      listener: (ctx, state) {
        if (state is ArticleUpdateSuccess) {
          Navigator.pop(ctx);
        } else if (state is ArticleError) {
          setState(() => _formError = state.message);
        }
      },
      builder: (ctx, state) {
        final isSubmitting = state is ArticleUpdating;

        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.9,
            ),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: cs.outline,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'article.edit_title'.tr(),
                        style: AppTypography.arabicHeadline(
                          color: cs.onSurface,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: Icon(Icons.close, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Flexible(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 👈 استخدام المكونات المشتركة
                          ArticleTextField(
                            label: 'article.title_label'.tr(),
                            controller: _titleController,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'article.title_required'.tr()
                                : null,
                          ),
                          SizedBox(height: 12.h),
                          ArticleTextField(
                            label: 'article.body_label'.tr(),
                            controller: _bodyController,
                            maxLines: 6,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'article.body_required'.tr()
                                : null,
                          ),
                          SizedBox(height: 12.h),
                          ArticleCategoryDropdown(
                            selectedCategoryId: _selectedCategoryId,
                            onChanged: (v) =>
                                setState(() => _selectedCategoryId = v),
                          ),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_formError != null) ...[
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: cs.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      _formError!,
                      style: AppTypography.arabicBody(
                        color: cs.error,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 16.h),
                Material(
                  color: isSubmitting ? cs.surfaceContainerHighest : cs.primary,
                  borderRadius: BorderRadius.circular(16.r),
                  child: InkWell(
                    onTap: isSubmitting
                        ? null
                        : () {
                            FocusScope.of(context).unfocus();
                            _submit();
                          },
                    borderRadius: BorderRadius.circular(16.r),
                    child: SizedBox(
                      height: 56.h,
                      child: Center(
                        child: isSubmitting
                            ? SizedBox(
                                height: 22.w,
                                width: 22.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: cs.onSurfaceVariant,
                                ),
                              )
                            : Text(
                                'article.save_changes'.tr(),
                                style: AppTypography.arabicTitle(
                                  color: cs.onPrimary,
                                  fontSize: 18,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}