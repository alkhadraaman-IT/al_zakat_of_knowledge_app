import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/failures.dart';
import '../../../articles/domain/entities/category_entity.dart';
import '../../../articles/domain/usecases/get_categories_usecase.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../content_creation/presentation/widgets/success_dialog.dart';
import '../../domain/usecases/create_study_tool_usecase.dart';
import '../bloc/study_tool_cubit.dart';

Future<bool> showCreateToolSheet(BuildContext context) async {
  print('<<<<<<<<<<<[showCreateToolSheet]>>>>>>>>>>>>>');
  final navigator = Navigator.of(context);

  final offered = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _CreateToolSheet(),
  );

  if (offered == true && navigator.mounted) {
    showSuccessDialog(navigator.context);
  }

  return offered ?? false;
}

class _CreateToolSheet extends StatefulWidget {
  const _CreateToolSheet();

  @override
  State<_CreateToolSheet> createState() => _CreateToolSheetState();
}

class _CreateToolSheetState extends State<_CreateToolSheet> {
  static const List<String> _kinds = ['book', 'stationery', 'notes', 'other'];

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  final _studyYearController = TextEditingController();
  final _universityController = TextEditingController();
  final _cityController = TextEditingController();
  final _pickupPlaceController = TextEditingController();
  final _pickupNotesController = TextEditingController();

  List<CategoryEntity> _categories = const [];
  int? _selectedCategoryId;
  String _selectedKind = 'book';
  bool _isSubmitting = false;

  @override
  void initState() {
    print('<<<<<<<<<<<[initState]>>>>>>>>>>>>>');
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    print('<<<<<<<<<<<[dispose]>>>>>>>>>>>>>');
    _titleController.dispose();
    _subjectController.dispose();
    _studyYearController.dispose();
    _universityController.dispose();
    _cityController.dispose();
    _pickupPlaceController.dispose();
    _pickupNotesController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    print('<<<<<<<<<<<[_loadCategories]>>>>>>>>>>>>>');
    final result = await sl<GetCategoriesUseCase>()();
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _categories = _fallbackCategories()),
      (categories) => setState(() {
        _categories = categories.isEmpty ? _fallbackCategories() : categories;
      }),
    );
  }

  List<CategoryEntity> _fallbackCategories() {
    print('<<<<<<<<<<<[_fallbackCategories]>>>>>>>>>>>>>');
    return const [
      CategoryEntity(
        id: 1,
        nameAr: 'علوم شريعة',
        nameEn: 'Islamic Sciences',
        sortOrder: 1,
      ),
      CategoryEntity(id: 2, nameAr: 'طب', nameEn: 'Medicine', sortOrder: 2),
      CategoryEntity(
        id: 3,
        nameAr: 'برمجة',
        nameEn: 'Programming',
        sortOrder: 3,
      ),
      CategoryEntity(id: 4, nameAr: 'تجارة', nameEn: 'Commerce', sortOrder: 4),
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

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      _showMessage('tool.form_invalid'.tr());
      return;
    }

    if (_selectedCategoryId == null) {
      _showMessage('tool.category_required'.tr());
      return;
    }

    final ownerId = _resolveOwnerId();
    if (ownerId == null) {
      _showMessage('tool.error_auth'.tr());
      return;
    }

    // استدعاء الـ StudyToolCubit بدلاً من الـ UseCase مباشرة
    context.read<StudyToolCubit>().createStudyTool(
      ownerId: ownerId,
      title: _titleController.text.trim(),
      subject: _subjectController.text.trim(),
      studyYear: _studyYearController.text.trim(),
      university: _universityController.text.trim(),
      city: _cityController.text.trim(),
      pickupPlace: _pickupPlaceController.text.trim(),
      pickupNotes: _pickupNotesController.text.trim(),
      categoryId: _selectedCategoryId!,
      kind: _selectedKind,
    );
  }

  String? _resolveOwnerId() {
    print('<<<<<<<<<<<[_resolveOwnerId]>>>>>>>>>>>>>');
    final state = context.read<AuthCubit>().state;
    if (state is AuthAuthenticated) return state.user.id;
    return null;
  }

  String _friendlyError(Failure failure) {
    print('<<<<<<<<<<<[_friendlyError]>>>>>>>>>>>>>');
    if (failure is NetworkFailure) return 'tool.error_offline'.tr();
    switch (failure.code) {
      case '23503':
        return 'tool.error_invalid_category'.tr();
      case '23505':
        return 'tool.error_duplicate'.tr();
      case '42501':
        return 'tool.error_permission'.tr();
      default:
        return 'tool.error_publish'.tr();
    }
  }

  void _showMessage(String message) {
    print('<<<<<<<<<<<[_showMessage]>>>>>>>>>>>>>');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('<<<<<<<<<<<[build]>>>>>>>>>>>>>');
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
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
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 20.h),
              decoration: BoxDecoration(
                color: cs.outline,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Text(
              'tool.create_title'.tr(),
              style: AppTypography.arabicHeadline(
                color: cs.onSurface,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 20.h),
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
                      _field(
                        label: 'tool.city_label'.tr(),
                        hint: 'tool.city_hint'.tr(),
                        controller: _cityController,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'tool.city_required'.tr()
                            : null,
                      ),
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
                      _dropdown(cs),
                      SizedBox(height: 12.h),
                      _kindDropdown(cs),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Material(
              color: cs.primary,
              borderRadius: BorderRadius.circular(16.r),
              child: InkWell(
                onTap: _isSubmitting
                    ? null
                    : () async {
                        print(
                          '<<<<<<<<<<<[ON_SUBMIT_BUTTON_TAPPED]>>>>>>>>>>>>>',
                        );
                        print('isSubmitting=$_isSubmitting');
                        FocusScope.of(context).unfocus();
                        await _submit();
                      },
                borderRadius: BorderRadius.circular(16.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Center(
                    child: _isSubmitting
                        ? SizedBox(
                            height: 20.w,
                            width: 20.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: cs.onPrimary,
                            ),
                          )
                        : Text(
                            'tool.submit'.tr(),
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
  }

  Widget _field({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    print('<<<<<<<<<<<[_field]>>>>>>>>>>>>>');
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

  Widget _dropdown(ColorScheme cs) {
    print('<<<<<<<<<<<[_dropdown]>>>>>>>>>>>>>');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'tool.category_label'.tr(),
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
            child: DropdownButton<int>(
              value: _selectedCategoryId,
              isExpanded: true,
              hint: Text(
                'tool.category_hint'.tr(),
                style: AppTypography.arabicBody(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  fontSize: 16,
                ),
              ),
              items: _categories.map((category) {
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
  }

  Widget _kindDropdown(ColorScheme cs) {
    print('<<<<<<<<<<<[_kindDropdown]>>>>>>>>>>>>>');
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
