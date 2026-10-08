import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_typography.dart';
import 'success_dialog.dart';

/// Shows the article creation form as a modal bottom sheet.
void showCreateArticleSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _CreateArticleSheet(),
  );
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
  String? _selectedCategory;

  final List<String> _categories = [
    'علوم شريعة', 'طب', 'برمجة', 'تجارة', 'تطوير ذاتي', 'أكاديمي',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      // image_url left null as per spec
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
                Text('إنشاء مقال نافع', style: AppTypography.arabicHeadline(color: cs.onSurface, fontSize: 20)),
                SizedBox(height: 20.h),
                _field(label: 'عنوان المقال', hint: 'مثال: فوائد طلب العلم', controller: _titleController,
                  validator: (v) => (v == null || v.isEmpty) ? 'العنوان مطلوب' : (v.length < 3 || v.length > 200) ? 'بين 3 و 200 حرف' : null),
                SizedBox(height: 12.h),
                _field(label: 'محتوى المقال', hint: 'اكتب المقال هنا...', controller: _bodyController, maxLines: 8,
                  validator: (v) => (v == null || v.isEmpty) ? 'المحتوى مطلوب' : (v.length > 20000) ? 'أقل من 20000 حرف' : null),
                SizedBox(height: 12.h),
                _dropdown(cs),
                SizedBox(height: 24.h),
                Material(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(16.r),
                  child: InkWell(
                    onTap: _submit,
                    borderRadius: BorderRadius.circular(16.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Center(child: Text('نشر المقال', style: AppTypography.arabicTitle(color: cs.onPrimary, fontSize: 18))),
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
        Text('التصنيف', style: AppTypography.arabicLabel(color: cs.onSurface, fontSize: 14)),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: cs.outline)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory, isExpanded: true,
              hint: Text('اختر التصنيف', style: AppTypography.arabicBody(color: cs.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 16)),
              items: _categories.map((i) => DropdownMenuItem(value: i, child: Text(i, style: AppTypography.arabicBody(color: cs.onSurface, fontSize: 16)))).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v),
            ),
          ),
        ),
      ],
    );
  }
}
