import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/di/injection_container.dart';
import '../../features/favorites/domain/entities/favorite_item_entity.dart';
import '../../features/favorites/presentation/widgets/favorite_builder.dart';
import '../../features/favorites/presentation/widgets/favorite_mappers.dart';
import '../../features/study_tools/domain/entities/study_tool_entity.dart';
import '../../features/study_tools/presentation/cubit/study_tool_cubit.dart';
import '../../features/study_tools/presentation/widgets/edit_study_tool_sheet.dart';
import 'app_study_tool_card.dart';

class StudyToolEntityCard extends StatelessWidget {
  final StudyToolEntity tool;
  final int index;
  final String? categoryLabel;
  final VoidCallback? onReport;

  const StudyToolEntityCard({
    super.key,
    required this.tool,
    required this.index,
    this.categoryLabel,
    this.onReport,
  });

  bool get _isOwner {
    final currentId = Supabase.instance.client.auth.currentUser?.id;
    return currentId != null && currentId == tool.ownerId;
  }

  @override
  Widget build(BuildContext context) {
    return FavoriteBuilder(
      type: FavoriteType.tool,
      id: tool.id,
      toFavorite: tool.toFavorite,
      builder: (context, isFavorite, onToggle) => AppStudyToolCard(
        index: index,
        title: tool.title,
        subject: tool.subject,
        studyYear: tool.studyYear,
        university: tool.university,
        city: tool.city,
        pickupPlace: tool.pickupPlace,
        pickupNotes: tool.pickupNotes,
        isTaken: tool.isTaken,
        categoryLabel: categoryLabel,
        onReport: onReport,
        isFavorite: isFavorite,
        onFavoriteToggle: onToggle,

        // ── Auto: owner detection + handlers ──
        isOwner: _isOwner,
        onEdit: _isOwner
    ? () async {
        print('<<<<<<<<<<<[EDIT BUTTON PRESSED]>>>>>>>>>>>>>');
        try {
          final updated = await showEditStudyToolSheet(context, tool: tool);
          print('<<<<<<<<<<<[EDIT SHEET CLOSED - updated=$updated]>>>>>>>>>>>>>');
          if (updated != null) {
            sl<StudyToolCubit>().getStudyTools();
          }
        } catch (e, st) {
          print('<<<<<<<<<<<[EDIT ERROR]>>>>>>>>>>>>>');
          print('Error: $e');
          print('Stack: $st');
        }
      }
    : null,
        onDelete: _isOwner ? () => _confirmDelete(context) : null,
        onTake: !_isOwner && !tool.isTaken
            ? () => sl<StudyToolCubit>().takeStudyTool(toolId: tool.id)
            : null,
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
          'حذف الأداة',
          style: AppTypography.arabicTitle(color: cs.onSurface, fontSize: 17),
        ),
        content: Text(
          'هل أنت متأكد من حذف هذه الأداة؟ لا يمكن التراجع.',
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
    if (confirmed == true) {
      sl<StudyToolCubit>().deleteStudyTool(toolId: tool.id);
    }
  }
}