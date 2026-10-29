import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/syrian_cities.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/widgets/success_dialog.dart';
import '../../../articles/domain/entities/category_entity.dart';
import '../../../articles/presentation/cubit/categories_cubit.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../cubit/study_tool_cubit.dart';
import '../cubit/study_tool_state.dart';

Future<bool> showCreateToolSheet(BuildContext context) async {
  final navigator = Navigator.of(context);

  final offered = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<StudyToolCubit>()),
        BlocProvider.value(value: sl<AuthCubit>()),
        BlocProvider.value(value: sl<CategoriesCubit>()),
      ],
      child: const _CreateToolSheet(),
    ),
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
  final _pickupPlaceController = TextEditingController();
  final _pickupNotesController = TextEditingController();

  int? _selectedCategoryId;
  String _selectedKind = 'book';
  String? _selectedCity;
  String? _formError;

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

  void _onSubmitTapped() {
    setState(() => _formError = null);
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _formError = 'يرجى تصحيح الحقول المظللة');
      return;
    }
    if (_selectedCategoryId == null) {
      setState(() => _formError = 'tool.category_required'.tr());
      return;
    }
    if (_selectedCity == null) {
      setState(() => _formError = 'tool.city_required'.tr());
      return;
    }
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      setState(() => _formError = 'tool.error_auth'.tr());
      return;
    }
    context.read<StudyToolCubit>().createStudyTool(
          ownerId: authState.user.id,
          title: _titleController.text.trim(),
          subject: _subjectController.text.trim(),
          studyYear: _studyYearController.text.trim(),
          university: _universityController.text.trim(),
          city: _selectedCity ?? '',
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
        if (state is StudyToolSuccess) {
          Navigator.pop(ctx, true);
        } else if (state is StudyToolError) {
          setState(() => _formError = state.message);
        }
      },
      builder: (ctx, state) {
        final isSubmitting = state is StudyToolSubmitting;

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
                  child: Column(
                    children: [
                      Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: cs.outline,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'tool.create_title'.tr(),
                              style: AppTypography.arabicHeadline(
                                color: cs.onSurface,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            icon: Icon(Icons.close, color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
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
                          if (_formError != null)
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
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      border: Border(
                        top: BorderSide(color: cs.outline.withValues(alpha: 0.2)),
                      ),
                    ),
                    child: Material(
                      color: isSubmitting
                          ? cs.surfaceContainerHighest
                          : cs.primary,
                      borderRadius: BorderRadius.circular(16.r),
                      child: InkWell(
                        onTap: () {
                          FocusScope.of(ctx).unfocus();
                          _onSubmitTapped();
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
        Text(label,
            style: AppTypography.arabicLabel(color: cs.onSurface, fontSize: 14)),
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
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
        Text('tool.kind_label'.tr(),
            style: AppTypography.arabicLabel(color: cs.onSurface, fontSize: 14)),
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