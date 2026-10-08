import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_typography.dart';
import 'success_dialog.dart';

/// Shows the session creation form as a modal bottom sheet.
void showCreateSessionSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _CreateSessionSheet(),
  );
}

class _CreateSessionSheet extends StatefulWidget {
  const _CreateSessionSheet();

  @override
  State<_CreateSessionSheet> createState() => _CreateSessionSheetState();
}

class _CreateSessionSheetState extends State<_CreateSessionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _placeController = TextEditingController();
  final _durationController = TextEditingController(text: '90');
  final _maxSeatsController = TextEditingController();
  String? _selectedCategory;
  DateTime? _selectedDateTime;

  final List<String> _categories = [
    'علوم شريعة', 'طب', 'برمجة', 'تجارة', 'تطوير ذاتي', 'أكاديمي',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _placeController.dispose();
    _durationController.dispose();
    _maxSeatsController.dispose();
    super.dispose();
  }

  void _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedDateTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('يرجى تحديد تاريخ ووقت الجلسة'), backgroundColor: Theme.of(context).colorScheme.error),
        );
        return;
      }
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
                Text('إنشاء جلسة علمية', style: AppTypography.arabicHeadline(color: cs.onSurface, fontSize: 20)),
                SizedBox(height: 20.h),
                _field(label: 'عنوان الجلسة', hint: 'مثال: شرح كتاب التوحيد', controller: _titleController,
                  validator: (v) => (v == null || v.isEmpty) ? 'العنوان مطلوب' : (v.length < 3 || v.length > 150) ? 'بين 3 و 150 حرف' : null),
                SizedBox(height: 12.h),
                _field(label: 'الوصف', hint: 'وصف تفصيلي', controller: _descriptionController, maxLines: 4,
                  validator: (v) => (v == null || v.isEmpty) ? 'الوصف مطلوب' : (v.length > 5000) ? 'أقل من 5000 حرف' : null),
                SizedBox(height: 12.h),
                _dropdown(cs),
                SizedBox(height: 12.h),
                _field(label: 'المدينة', hint: 'الرياض', controller: _cityController,
                  validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null),
                SizedBox(height: 12.h),
                _field(label: 'اسم المكان', hint: 'جامع الملك فهد', controller: _placeController,
                  validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null),
                SizedBox(height: 12.h),
                _dateTimeField(cs),
                SizedBox(height: 12.h),
                _field(label: 'المدة (دقائق)', hint: '90', controller: _durationController, keyboardType: TextInputType.number,
                  validator: (v) { final n = int.tryParse(v ?? ''); return (n == null || n <= 0) ? 'رقم موجب' : null; }),
                SizedBox(height: 12.h),
                _field(label: 'الحد الأقصى للمقاعد', hint: '30', controller: _maxSeatsController, keyboardType: TextInputType.number,
                  validator: (v) { final n = int.tryParse(v ?? ''); return (n == null || n <= 0) ? 'رقم أكبر من صفر' : null; }),
                SizedBox(height: 24.h),
                Material(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(16.r),
                  child: InkWell(
                    onTap: _submit,
                    borderRadius: BorderRadius.circular(16.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Center(child: Text('نشر الجلسة', style: AppTypography.arabicTitle(color: cs.onPrimary, fontSize: 18))),
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

  Widget _field({required String label, required String hint, required TextEditingController controller, int maxLines = 1, TextInputType? keyboardType, String? Function(String?)? validator}) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.arabicLabel(color: cs.onSurface, fontSize: 14)),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller, maxLines: maxLines, keyboardType: keyboardType,
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

  Widget _dateTimeField(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('تاريخ ووقت الجلسة', style: AppTypography.arabicLabel(color: cs.onSurface, fontSize: 14)),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: _pickDateTime,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: cs.outline)),
            child: Row(children: [
              Icon(Icons.calendar_today_outlined, color: cs.onSurfaceVariant, size: 20.w),
              SizedBox(width: 12.w),
              Text(
                _selectedDateTime != null
                    ? '${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} - ${_selectedDateTime!.hour}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}'
                    : 'اختر التاريخ والوقت',
                style: AppTypography.arabicBody(color: _selectedDateTime != null ? cs.onSurface : cs.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 16),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}
