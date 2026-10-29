import 'package:al_zakat_of_knowledge_app/app/theme/app_typography.dart';
import 'package:al_zakat_of_knowledge_app/features/reports/presentation/widgets/report_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/di/injection_container.dart';
import '../../features/articles/domain/entities/article_entity.dart';
import '../../features/articles/presentation/bloc/article_cubit.dart';
import '../../features/articles/presentation/bloc/article_state.dart';
import '../../features/articles/presentation/widgets/edit_article_sheet.dart';
import '../../features/favorites/presentation/cubit/toggle_cubit.dart';

class AppArticleCard extends StatelessWidget {
  final String title;
  final String body;
  final String? articleId;
  final String? authorId;
  final int? categoryId;
  final String? categoryLabel; // ← جديد
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onReport;

  const AppArticleCard({
    super.key,
    required this.title,
    required this.body,
    this.articleId,
    this.authorId,
    this.categoryId,
    this.onTap,
    this.categoryLabel, // ← جديد
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onReport,
  });

  bool get _isOwner {
    if (authorId == null) return false;
    final currentId = Supabase.instance.client.auth.currentUser?.id;
    return currentId != null && currentId == authorId;
  }

  bool get _hasOwnerActions => _isOwner && articleId != null;

  @override
  Widget build(BuildContext context) {
    final card = BlocProvider(
      create: (_) => ToggleCubit(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline
                  .withValues(alpha: 0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.surface
                    .withValues(alpha: 0.45),
                blurRadius: 20.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: 12.h),
              Text(
                title,
                style: AppTypography.arabicTitle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8.h),
              _ExpandableBody(body: body),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );

    if (!_hasOwnerActions) return card;

    return BlocProvider.value(
      value: sl<ArticleCubit>(),
      child: BlocListener<ArticleCubit, ArticleState>(
        listenWhen: (prev, curr) =>
            curr is ArticleUpdateSuccess ||
            curr is ArticleDeleteSuccess ||
            (curr is ArticleError &&
                (prev is ArticleUpdating || prev is ArticleDeleting)),
        listener: (ctx, state) {
          final cs = Theme.of(ctx).colorScheme;
          if (state is ArticleUpdateSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: const Text('تم تحديث المقالة'),
                backgroundColor: cs.primary,
              ),
            );
          } else if (state is ArticleDeleteSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: const Text('تم حذف المقالة'),
                backgroundColor: cs.primary,
              ),
            );
          } else if (state is ArticleError) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: cs.error),
            );
          }
        },
        child: card,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        InkWell(
          onTap: onFavoriteToggle,
          child: Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
            ),
            child: Icon(
              isFavorite ? Icons.bookmark : Icons.bookmark_border,
              color: isFavorite ? cs.primary : cs.onSurfaceVariant,
              size: 18.w,
            ),
          ),
        ),
        const Spacer(),
        if (categoryLabel != null && categoryLabel!.isNotEmpty) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
            ),
            child: Text(
              categoryLabel!,
              style: AppTypography.arabicCaption(
                color: cs.primary,
                fontSize: 11,
              ),
            ),
          ),
        ],
        SizedBox(width: 8.w),
        if (_hasOwnerActions)
          _ownerMenu(context)
        else if (articleId != null)
          _reportButton(context),
      ],
    );
  }

  Widget _ownerMenu(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: PopupMenuButton<String>(
        tooltip: '',
        padding: EdgeInsets.zero,
        icon: Icon(Icons.more_vert, color: cs.onSurfaceVariant, size: 20.w),
        color: cs.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        onSelected: (value) {
          if (value == 'edit') _openEditSheet(context);
          if (value == 'delete') _confirmDelete(context);
        },
        itemBuilder: (ctx) => [
          PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 18.w, color: cs.primary),
                SizedBox(width: 10.w),
                Text(
                  'تعديل',
                  style: AppTypography.arabicBody(
                    color: cs.onSurface,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline, size: 18.w, color: cs.error),
                SizedBox(width: 10.w),
                Text(
                  'حذف',
                  style: AppTypography.arabicBody(
                    color: cs.error,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportButton(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: 'report.title'.tr(),
      child: Material(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(10.r),
        child: InkWell(
          onTap: () {
            if (onReport != null) {
              onReport!();
            } else {
              showReportSheet(
                context: context,
                targetType: 'article',
                targetId: articleId!,
              );
            }
          },
          borderRadius: BorderRadius.circular(10.r),
          child: SizedBox(
            width: 36.w,
            height: 36.w,
            child: Icon(
              Icons.flag_outlined,
              color: cs.onSurfaceVariant,
              size: 18.w,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openEditSheet(BuildContext context) async {
    if (articleId == null || categoryId == null || authorId == null) return;
    await showEditArticleSheet(
      context,
      article: ArticleEntity(
        id: articleId!,
        authorId: authorId!,
        title: title,
        body: body,
        categoryId: categoryId!,
        imageUrl: null,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'حذف المقالة',
          style: AppTypography.arabicTitle(color: cs.onSurface, fontSize: 17),
        ),
        content: Text(
          'هل أنت متأكد من حذف هذه المقالة؟ لا يمكن التراجع.',
          style: AppTypography.arabicBody(
            color: cs.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'إلغاء',
              style: AppTypography.arabicLabel(
                color: cs.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'حذف',
              style: AppTypography.arabicLabel(color: cs.error, fontSize: 14),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && articleId != null) {
      sl<ArticleCubit>().deleteArticle(articleId: articleId!);
    }
  }
}

class _ExpandableBody extends StatelessWidget {
  final String body;
  const _ExpandableBody({required this.body});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bodyStyle = AppTypography.arabicBody(
      color: cs.onSurfaceVariant,
      fontSize: 13,
    );

    return BlocBuilder<ToggleCubit, bool>(
      builder: (context, isExpanded) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedCrossFade(
              firstChild: Text(
                body,
                style: bodyStyle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              secondChild: Text(body, style: bodyStyle),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
            SizedBox(height: 4.h),
            TextButton(
              onPressed: () => context.read<ToggleCubit>().toggle(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                isExpanded
                    ? 'article.show_less'.tr()
                    : 'article.read_more'.tr(),
                style: AppTypography.arabicLabel(
                  color: cs.primary,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
