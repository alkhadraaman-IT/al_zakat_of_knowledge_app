import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/syrian_cities.dart';
import '../../../../core/di/injection_container.dart';
import '../../../articles/domain/entities/category_entity.dart';
import '../../../articles/presentation/cubit/categories_cubit.dart';
import '../../domain/entities/study_tool_entity.dart';
import '../cubit/study_tool_cubit.dart';
import '../cubit/study_tool_state.dart';

Future<StudyToolEntity?> showEditStudyToolSheet(
  BuildContext context, {
  required StudyToolEntity tool,
}) async {
  return await showModalBottomSheet<StudyToolEntity>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<StudyToolCubit>()),
        BlocProvider.value(value: sl<CategoriesCubit>()),
      ],
      child: _EditStudyToolSheet(tool: tool),
    ),
  );
}

class _EditStudyToolSheet extends StatefulWidget {
  final StudyToolEntity tool;
  const _EditStudyToolSheet({required this.tool});

  @override
  State<_EditStudyToolSheet> createState() => _EditStudyToolSheetState();
}

class _EditStudyToolSheetState extends State<_EditStudyToolSheet> {
  static const List<String> _kinds = ['book', 'stationery', 'notes', 'other'];

 

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _subjectController;
  late final TextEditingController _studyYearController;
  late final TextEditingController _universityController;
  late final TextEditingController _pickupPlaceController;
  late final TextEditingController _pickupNotesController;

  int? _selectedCategoryId;
  late String _selectedKind;
  String? _selectedCity;
  String? _formError;

  @override
  void initState() {
    super.initState();
    final t = widget.tool;
    _titleController = TextEditingController(text: t.title);
    _subjectController = TextEditingController(text: t.subject);
    _studyYearController = TextEditingController(text: t.studyYear);
    _universityController = TextEditingController(text: t.university);
    _pickupPlaceController = TextEditingController(text: t.pickupPlace);
    _pickupNotesController = TextEditingController(text: t.pickupNotes);
    _selectedCategoryId = t.categoryId;
    _selectedKind = _kinds.contains(t.kind) ? t.kind : 'book';

    // ✅ تهيئة المدينة الحالية (إن كانت ضمن القائمة)
    final rawCity = t.city;
    _selectedCity =
        (rawCity.isNotEmpty && SyrianCities.all.contains(rawCity))
            ? rawCity
            : null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _studyYearController.dispose();
    _universityController.dispose();
    _pickupPlaceController.dispose();
    _pickupNotesController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _formError = null);
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _formError = 'يرجى تصحيح الحقول المظللة');
      return;
    }
    if (_selectedCategoryId == null) {
      setState(() => _formError = 'tool.category_required'.tr());
      return;
    }
    // ✅ التحقق من المدينة
    if (_selectedCity == null) {
      setState(() => _formError = 'tool.city_required'.tr());
      return;
    }
    context.read<StudyToolCubit>().updateStudyTool(
          toolId: widget.tool.id,
          title: _titleController.text.trim(),
          subject: _subjectController.text.trim(),
          studyYear: _studyYearController.text.trim(),
          university: _universityController.text.trim(),
          city: _selectedCity ?? '', // ✅ بدل _cityController
          pickupPlace: _pickupPlaceController.text.trim(),
          pickupNotes: _pickupNotesController.text.trim(),
          categoryId: _selectedCategoryId!,
          kind: _selectedKind,
        );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocConsumer<StudyToolCubit, StudyToolState>(
      listener: (ctx, state) {
        if (state is StudyToolUpdateSuccess) {
          Navigator.pop(ctx, state.tool);
        } else if (state is StudyToolError) {
          setState(() => _formError = state.message);
        }
      },
      builder: (ctx, state) {
        final isSubmitting = state is StudyToolUpdating;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
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
                        'تعديل الأداة',
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
                          _field(
                            label: 'tool.title_label'.tr(),
                            hint: 'tool.title_hint'.tr(),
                            controller: _titleController,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'tool.title_required'.tr();
                              if (v.trim().length < 3 || v.trim().length > 150)
                                return 'tool.title_length'.tr();
                              return null;
                            },
                          ),
                          SizedBox(height: 12.h),
                          _field(
                            label: 'tool.subject_label'.tr(),
                            hint: 'tool.subject_hint'.tr(),
                            controller: _subjectController,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'tool.subject_required'.tr()
                                : null,
                          ),
                          SizedBox(height: 12.h),
                          _field(
                            label: 'tool.study_year_label'.tr(),
                            hint: 'tool.study_year_hint'.tr(),
                            controller: _studyYearController,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'tool.study_year_required'.tr()
                                : null,
                          ),
                          SizedBox(height: 12.h),
                          _field(
                            label: 'tool.university_label'.tr(),
                            hint: 'tool.university_hint'.tr(),
                            controller: _universityController,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'tool.university_required'.tr()
                                : null,
                          ),
                          SizedBox(height: 12.h),
                          _cityDropdown(),
                          SizedBox(height: 12.h),
                          _field(
                            label: 'tool.pickup_place_label'.tr(),
                            hint: 'tool.pickup_place_hint'.tr(),
                            controller: _pickupPlaceController,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'tool.pickup_place_required'.tr()
                                : null,
                          ),
                          SizedBox(height: 12.h),
                          _field(
                            label: 'tool.pickup_notes_label'.tr(),
                            hint: 'tool.pickup_notes_hint'.tr(),
                            controller: _pickupNotesController,
                            maxLines: 3,
                          ),
                          SizedBox(height: 12.h),
                          _categoryDropdown(cs),
                          SizedBox(height: 12.h),
                          _kindDropdown(cs),
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
                  color: isSubmitting
                      ? cs.surfaceContainerHighest
                      : cs.primary,
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
                                'حفظ التعديلات',
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

  Widget _field({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.arabicLabel(color: cs.onSurface, fontSize: 14),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: AppTypography.arabicBody(color: cs.onSurface, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.arabicBody(
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
              fontSize: 16,
            ),
            filled: true,
            fillColor: cs.surfaceContainerLow,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: cs.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: cs.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: cs.primary, width: 1.5),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _cityDropdown() {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'tool.city_label'.tr(),
          style: AppTypography.arabicLabel(color: cs.onSurface, fontSize: 14),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: cs.outline),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCity,
              isExpanded: true,
              hint: Text(
                'اختر المحافظة',
                style: AppTypography.arabicBody(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  fontSize: 16,
                ),
              ),
              items: SyrianCities.all.map((city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Text(
                    city,
                    style: AppTypography.arabicBody(
                      color: cs.onSurface,
                      fontSize: 16,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedCity = v),
            ),
          ),
        ),
      ],
    );
  }

  Widget _categoryDropdown(ColorScheme cs) {
    return BlocBuilder<CategoriesCubit, List<CategoryEntity>>(
      builder: (context, categories) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'tool.category_label'.tr(),
              style: AppTypography.arabicLabel(
                color: cs.onSurface,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: cs.outline),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: categories.any((c) => c.id == _selectedCategoryId)
                      ? _selectedCategoryId
                      : null,
                  isExpanded: true,
                  hint: Text(
                    'tool.category_hint'.tr(),
                    style: AppTypography.arabicBody(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                      fontSize: 16,
                    ),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(
                        category.nameFor(context.locale.languageCode),
                        style: AppTypography.arabicBody(
                          color: cs.onSurface,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedCategoryId = v),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _kindDropdown(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'tool.kind_label'.tr(),
          style: AppTypography.arabicLabel(color: cs.onSurface, fontSize: 14),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: cs.outline),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedKind,
              isExpanded: true,
              items: _kinds.map((kind) {
                return DropdownMenuItem<String>(
                  value: kind,
                  child: Text(
                    'tool.kind_$kind'.tr(),
                    style: AppTypography.arabicBody(
                      color: cs.onSurface,
                      fontSize: 16,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (v) =>
                  setState(() => _selectedKind = v ?? _selectedKind),
            ),
          ),
        ),
      ],
    );
  }
}