import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../profile/presentation/widgets/profile_guard.dart';
import '../../../../app/theme/app_typography.dart';
import 'success_dialog.dart';

/// Shows the material/tool creation form as a modal bottom sheet.
void showCreateMaterialSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _CreateMaterialSheet(),
  );
}

class _CreateMaterialSheet extends StatefulWidget {
  const _CreateMaterialSheet();

  @override
  State<_CreateMaterialSheet> createState() => _CreateMaterialSheetState();
}

class _CreateMaterialSheetState extends State<_CreateMaterialSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  final _studyYearController = TextEditingController();
  final _cityController = TextEditingController();
  final _pickupPlaceController = TextEditingController();
  final _pickupNotesController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _studyYearController.dispose();
    _cityController.dispose();
    _pickupPlaceController.dispose();
    _pickupNotesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Incomplete-profile guard (backend specification).
      if (!await ensureProfileComplete(context)) return;
      if (!context.mounted) return;
      Navigator.pop(context);
      showSuccessDialog(context);
    }
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
                Container(
                  width: 40.w, height: 4.h,
                  margin: EdgeInsets.only(bottom: 20.h),
                  decoration: BoxDecoration(color: cs.outline, borderRadius: BorderRadius.circular(2.r)),
                ),
                Text('نشر أداة دراسية', style: AppTypography.arabicHeadline(color: cs.onSurface, fontSize: 20)),
                SizedBox(height: 20.h),
                _field(label: 'العنوان', hint: 'مثال: حقيبة طالب العلم', controller: _titleController,
                  validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : (v.length < 3 || v.length > 150) ? 'بين 3 و 150 حرف' : null),
                SizedBox(height: 12.h),
                _field(label: 'المادة الدراسية', hint: 'مثال: كتب التوحيد', controller: _subjectController,
                  validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null),
                SizedBox(height: 12.h),
                _field(label: 'السنة الدراسية', hint: 'مثال: السنة الأولى', controller: _studyYearController,
                  validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null),
                SizedBox(height: 12.h),
                _field(label: 'المدينة', hint: 'الرياض', controller: _cityController,
                  validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null),
                SizedBox(height: 12.h),
                _field(label: 'مكان الاستلام', hint: 'مكتبة الجامعة', controller: _pickupPlaceController,
                  validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null),
                SizedBox(height: 12.h),
                _field(label: 'ملاحظات الاستلام', hint: 'تفاصيل إضافية (اختياري)', controller: _pickupNotesController, maxLines: 3),
                SizedBox(height: 24.h),
                Material(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(16.r),
                  child: InkWell(
                    onTap: _submit,
                    borderRadius: BorderRadius.circular(16.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Center(child: Text('نشر الأداة', style: AppTypography.arabicTitle(color: cs.onPrimary, fontSize: 18))),
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
}
