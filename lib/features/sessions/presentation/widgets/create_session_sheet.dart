import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/network_info.dart';
import '../../../articles/domain/entities/category_entity.dart';
import '../../../articles/domain/usecases/get_categories_usecase.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../content_creation/presentation/widgets/success_dialog.dart';
import '../session_cubit/session_cubit.dart';
import '../session_cubit/session_state.dart';

import 'package:latlong2/latlong.dart';

import '../../../profile/presentation/widgets/profile_guard.dart';
import 'pick_location_view.dart';

/// Shows the session creation form as a modal bottom sheet.
Future<bool> showCreateSessionSheet(BuildContext context) async {
  // لا ينشر جلسة إلا من أكمل ملفه (الجامعة والمدينة ورابط LinkedIn أو CV).
  if (!await ensureProfileComplete(context)) return false;
  if (!context.mounted) return false;

  final created = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    // SessionCubit مسجَّل كـ singleton في injection_container، فنستعمل .value
    // حتى لا يُغلقه BlocProvider عند إغلاق النافذة (وإلا يتعطل بعد أول استخدام).
    builder: (context) => BlocProvider.value(
      value: sl<SessionCubit>(),
      child: const _CreateSessionSheet(),
    ),
  );

  if (created == true && context.mounted) {
    await showDuaSuccessDialog(context);
  }

  return created ?? false;
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
  final _seatsController = TextEditingController();
  final _cityController = TextEditingController();
  final _placeController = TextEditingController();
  final _durationController = TextEditingController();

  List<CategoryEntity> _categories = const [];
  int? _selectedCategoryId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoadingCategories = true;

  /// رسالة خطأ تظهر داخل النموذج نفسه (الـ SnackBar يختفي خلف الـ bottom sheet).
  String? _formError;

  /// حالة الإرسال محلية: لا نعتمد على حالة SessionCubit لأنه singleton
  /// وقد تبقى حالته (SessionSubmitting) عالقة من محاولة سابقة فيتعطل الزر.
  bool _isSubmitting = false;

  /// موقع المحاضرة المختار من الخريطة.
  LatLng? _pickedLocation;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _seatsController.dispose();
    _cityController.dispose();
    _placeController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  /// جلب التصنيفات مباشرة من قاعدة البيانات مع فحص الاتصال بالإنترنت
  Future<void> _loadCategories() async {
    final networkInfo = sl<NetworkInfo>();
    final isConnected = await networkInfo.isConnected;

    if (!isConnected) {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
        _showMessage('create.error_offline'.tr());
      }
      return;
    }

    final result = await sl<GetCategoriesUseCase>()();
    if (!mounted) return;

    setState(() => _isLoadingCategories = false);
    result.fold(
      (failure) => _showMessage(failure.message),
      (categories) => setState(() => _categories = categories),
    );
  }

  Future<void> _submit(BuildContext context) async {
    print('<<<<<<<<<<<[CreateSession._submit]>>>>>>>>>>>>>');
    if (mounted) setState(() => _formError = null);
    // فحص الاتصال بالشبكة قبل البدء بالتنفيذ
    final networkInfo = sl<NetworkInfo>();
    if (!await networkInfo.isConnected) {
      _showMessage('create.error_offline'.tr());
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      // رسالة مؤقتة بالعربية. استبدلها بمفتاح ترجمة إن أردت.
      _showMessage('يرجى تصحيح الحقول المظللة بالأحمر');
      return;
    }
    if (_selectedCategoryId == null) {
      _showMessage('create.category_required'.tr());
      return;
    }
    if (_selectedDate == null) {
      _showMessage('create.date_required'.tr());
      return;
    }
    if (_selectedTime == null) {
      _showMessage('create.time_required'.tr());
      return;
    }

    if (_pickedLocation == null) {
      _showMessage('حدّد موقع المحاضرة على الخريطة أولاً');
      return;
    }

    final ownerId = _resolveOwnerId(context);
    if (ownerId == null) {
      _showMessage('create.error_auth'.tr());
      return;
    }

    final startDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    final startsAt = startDateTime.toUtc().toIso8601String();
    final durationMinutes = int.tryParse(_durationController.text.trim()) ?? 90;

    // إرسال طلب الإنشاء عبر SessionCubit
    setState(() => _isSubmitting = true);
    // صمام أمان: إن لم يصل رد خلال 30 ثانية نعيد تفعيل الزر.
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _isSubmitting) {
        setState(() => _isSubmitting = false);
        _showMessage('انتهت المهلة. تحقق من الاتصال وحاول مرة أخرى.');
      }
    });
    context.read<SessionCubit>().createSession(
      publisherId: ownerId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      categoryId: _selectedCategoryId!,
      city: _cityController.text.trim(),
      placeName: _placeController.text.trim(),
      startsAt: startsAt,
      durationMinutes: durationMinutes,
      maxSeats: int.tryParse(_seatsController.text.trim()) ?? 30,
      lat: _pickedLocation!.latitude,
      lng: _pickedLocation!.longitude,
    );
  }

  Future<void> _pickLocation() async {
    FocusScope.of(context).unfocus();
    final result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => PickLocationPage(initial: _pickedLocation),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _pickedLocation = result;
        _formError = null;
      });
    }
  }

  Widget _locationPicker() {
    final cs = Theme.of(context).colorScheme;
    final picked = _pickedLocation;
    return InkWell(
      onTap: _pickLocation,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: picked == null
                ? cs.outline.withValues(alpha: 0.4)
                : cs.primary,
          ),
        ),
        child: Row(
          children: [
            Icon(
              picked == null
                  ? Icons.add_location_alt_outlined
                  : Icons.check_circle,
              color: picked == null ? cs.onSurfaceVariant : cs.primary,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                // نصوص مؤقتة بالعربية. انقلها إلى ملفات الترجمة لاحقاً.
                picked == null
                    ? 'حدّد موقع المحاضرة على الخريطة'
                    : 'تم تحديد الموقع (اضغط للتعديل)',
                style: AppTypography.arabicBody(
                  color: cs.onSurface,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(Icons.chevron_left, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  String? _resolveOwnerId(BuildContext context) {
    final state = context.read<AuthCubit>().state;
    if (state is AuthAuthenticated) return state.user.id;
    return null;
  }

  /// يعرض الرسالة داخل النموذج فوق زر الإرسال. الـ SnackBar العادي
  /// يظهر خلف الـ modal bottom sheet فلا يراه المستخدم.
  void _showMessage(String message) {
    print('<<<<<<<<<<<[CreateSession message]>>>>>>>>>>>>>');
    print(message);
    if (!mounted) return;
    setState(() => _formError = message);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocConsumer<SessionCubit, SessionState>(
      listener: (context, state) {
        print('<<<<<<<<<<<[CreateSession state]>>>>>>>>>>>>>');
        print(state.runtimeType);
        if (state is SessionError) {
          if (mounted) setState(() => _isSubmitting = false);
          _showMessage(state.message);
        } else if (state is SessionSuccess) {
          Navigator.pop(context, true);
        }
      },
      builder: (context, state) {
        final isSubmitting = _isSubmitting;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
                    // مقبض السحب (Drag Handle)
                    Center(
                      child: Container(
                        width: 32.w,
                        height: 3.5.h,
                        margin: EdgeInsets.only(bottom: 16.h),
                        decoration: BoxDecoration(
                          color: cs.outline.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                      ),
                    ),
                    Text(
                      'create.session_title'.tr(),
                      style: AppTypography.arabicHeadline(
                        color: cs.onSurface,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    _field(
                      label: 'create.title_label'.tr(),
                      hint: 'create.title_hint'.tr(),
                      controller: _titleController,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'create.title_required'.tr();
                        final length = v.trim().length;
                        if (length < 3 || length > 150)
                          return 'create.title_length'.tr();
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),
                    _field(
                      label: 'create.description_label'.tr(),
                      hint: 'create.description_hint'.tr(),
                      controller: _descriptionController,
                      maxLines: 3,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'create.description_required'.tr()
                          : null,
                    ),
                    SizedBox(height: 12.h),
                    _field(
                      label: 'create.seats_label'.tr(),
                      hint: 'create.seats_hint'.tr(),
                      controller: _seatsController,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'create.seats_required'.tr();
                        final val = int.tryParse(v.trim());
                        if (val == null || val < 1 || val > 1000)
                          return 'create.seats_invalid'.tr();
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),
                    _field(
                      label: 'create.city_label'.tr(),
                      hint: 'create.city_hint'.tr(),
                      controller: _cityController,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'create.city_required'.tr()
                          : null,
                    ),
                    SizedBox(height: 12.h),
                    _field(
                      label: 'create.place_label'.tr(),
                      hint: 'create.place_hint'.tr(),
                      controller: _placeController,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'create.place_required'.tr()
                          : null,
                    ),
                    SizedBox(height: 12.h),
                    _locationPicker(),
                    SizedBox(height: 12.h),
                    _field(
                      label: 'create.duration_label'.tr(),
                      hint: 'create.duration_hint'.tr(),
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'create.duration_required'.tr();
                        final val = int.tryParse(v.trim());
                        if (val == null || val < 15 || val > 480)
                          return 'create.duration_invalid'.tr();
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),
                    _dateTimePicker(),
                    SizedBox(height: 12.h),
                    _categoryDropdown(),
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
                    SizedBox(height: 24.h),
                    Material(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(16.r),
                      child: InkWell(
                        onTap: isSubmitting
                            ? null
                            : () async {
                                print(
                                  '<<<<<<<<<<<[CreateSession button tapped]>>>>>>>>>>>>>',
                                );
                                FocusScope.of(context).unfocus();
                                await _submit(context);
                              },
                        borderRadius: BorderRadius.circular(16.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: Center(
                            child: isSubmitting
                                ? SizedBox(
                                    height: 20.w,
                                    width: 20.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: cs.onPrimary,
                                    ),
                                  )
                                : Text(
                                    'create.submit'.tr(),
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

  Widget _dateTimePicker() {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _field(
                label: 'create.date_label'.tr(),
                hint: _selectedDate != null
                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                    : 'create.date_hint'.tr(),
                controller: TextEditingController(
                  text: _selectedDate != null
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : '',
                ),
                validator: (v) =>
                    _selectedDate == null ? 'create.date_required'.tr() : null,
                keyboardType: TextInputType.none,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _field(
                label: 'create.time_label'.tr(),
                hint: _selectedTime != null
                    ? _selectedTime!.format(context)
                    : 'create.time_hint'.tr(),
                controller: TextEditingController(
                  text: _selectedTime != null
                      ? _selectedTime!.format(context)
                      : '',
                ),
                validator: (v) =>
                    _selectedTime == null ? 'create.time_required'.tr() : null,
                keyboardType: TextInputType.none,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: cs.outline),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            _selectedDate ??
                            DateTime.now().add(const Duration(days: 2)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null)
                        setState(() => _selectedDate = picked);
                    },
                    borderRadius: BorderRadius.circular(12.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              color: cs.primary,
                              size: 20.w,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'create.date_picker'.tr(),
                              style: AppTypography.arabicLabel(
                                color: cs.primary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: cs.outline),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                  child: InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime ?? TimeOfDay.now(),
                      );
                      if (picked != null)
                        setState(() => _selectedTime = picked);
                    },
                    borderRadius: BorderRadius.circular(12.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_outlined,
                              color: cs.primary,
                              size: 20.w,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'create.time_picker'.tr(),
                              style: AppTypography.arabicLabel(
                                color: cs.primary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _categoryDropdown() {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'create.category_label'.tr(),
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
          child: _isLoadingCategories
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  child: Center(
                    child: SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.primary,
                      ),
                    ),
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedCategoryId,
                    isExpanded: true,
                    hint: Text(
                      'create.category_hint'.tr(),
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
}
