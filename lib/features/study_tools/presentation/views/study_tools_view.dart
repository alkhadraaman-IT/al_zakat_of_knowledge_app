import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_state_views.dart';
import '../../../../shared/widgets/session_entity_card.dart';
import '../../../articles/domain/entities/category_entity.dart';
import '../../../articles/presentation/cubit/categories_cubit.dart';
import '../../../reports/presentation/widgets/report_sheet.dart';
import '../../domain/entities/study_tool_entity.dart';
import '../bloc/study_tool_cubit.dart';
import '../bloc/study_tool_state.dart';
import '../widgets/create_study_tool_sheet.dart';

/// Study materials list screen.
///
/// لا يوجد setState: القائمة من [StudyToolCubit]، التصنيفات من
/// [CategoriesCubit]، والمفضلة من [FavoritesCubit] (داخل StudyToolEntityCard).
///
/// يحتاج Providers فوقه (BlocProvider.value):
///  - StudyToolCubit  - CategoriesCubit
///
/// StatefulWidget فقط حتى نستدعي التحميل الأولي بـ initState.
class StudyToolsView extends StatefulWidget {
  const StudyToolsView({super.key});

  @override
  State<StudyToolsView> createState() => _StudyToolsViewState();
}

class _StudyToolsViewState extends State<StudyToolsView> {
  @override
  void initState() {
    super.initState();
    context.read<StudyToolCubit>().getStudyTools();
  }

  Future<void> _showCreateToolSheet() async {
    final offered = await showCreateToolSheet(context);
    if (!context.mounted) return;
    if (offered) {
      context.read<StudyToolCubit>().getStudyTools();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'study_tools.title'.tr(),
          style: AppTypography.arabicTitle(color: cs.onSurface, fontSize: 20),
        ),
      ),
      body: BlocBuilder<StudyToolCubit, StudyToolState>(
        // Submitting / Success (من الـ sheet) ما بتغيّر الواجهة:
        // القائمة الحالية بتضل ظاهرة بدل ما نحتفظ بنسخة بـ State محلي.
        buildWhen: (_, current) =>
            current is! StudyToolSubmitting && current is! StudyToolSuccess,
        builder: (context, state) {
          if (state is StudyToolError) {
            return AppErrorState(
              title: 'study_tools.error_loading'.tr(),
              message: state.message,
              retryLabel: 'study_tools.retry'.tr(),
              onRetry: () => context.read<StudyToolCubit>().getStudyTools(),
            );
          }
          if (state is StudyToolLoaded) {
            if (state.tools.isEmpty) {
              return AppEmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'study_tools.empty'.tr(),
                hint: 'study_tools.empty_hint'.tr(),
              );
            }
            return _ToolsList(tools: state.tools);
          }
          return const AppLoadingState();
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_study_tool',
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        onPressed: _showCreateToolSheet,
        child: Icon(Icons.add, size: 28.w),
      ),
    );
  }
}

class _ToolsList extends StatelessWidget {
  final List<StudyToolEntity> tools;
  const _ToolsList({required this.tools});

  @override
  Widget build(BuildContext context) {
    final languageCode = context.locale.languageCode;

    // يعيد بناء القائمة فقط عند وصول/تغيّر التصنيفات.
return BlocBuilder<CategoriesCubit, List<CategoryEntity>>(
      builder: (context, _) {
        final categories = context.read<CategoriesCubit>();
        return ListView.separated(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.md,
          ),
          itemCount: tools.length,
          separatorBuilder: (_, _) => SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final tool = tools[index];
            return StudyToolEntityCard(
              key: ValueKey(tool.id),
              tool: tool,
              index: index,
              categoryLabel: categories.nameOf(tool.categoryId, languageCode),
              onReport: () {
                showReportSheet(
                  context: context,
                  targetType: 'study_tool',
                  targetId: tool.id,
                );
              },
            );
          },
        );
      },
    );
  }
}