import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/syrian_cities.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/network_info.dart';
import '../../../articles/domain/entities/category_entity.dart';
import '../../../articles/domain/usecases/get_categories_usecase.dart';
import '../session_cubit/session_cubit.dart';
import '../session_cubit/session_state.dart';
import 'pick_location_view.dart';

/// يفتح شيت تعديل الجلسة ويعيد true عند نجاح التحديث.
Future<bool> showEditSessionSheet(
  BuildContext context, {
  required String sessionId,
  required Map<String, dynamic> sessionData,
}) async {
  final updated = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => BlocProvider.value(
      value: sl<SessionCubit>(), // singleton — لا نغلقه
      child: _EditSessionSheet(sessionId: sessionId, sessionData: sessionData),
    ),
  );
  return updated ?? false;
}

class _EditSessionSheet extends StatefulWidget {
  final String sessionId;
  final Map<String, dynamic> sessionData;
  const _EditSessionSheet({required this.sessionId, required this.sessionData});

  @override
  State<_EditSessionSheet> createState() => _EditSessionSheetState();
}

class _EditSessionSheetState extends State<_EditSessionSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _seatsController;
  late final TextEditingController _placeController;
  late final TextEditingController _durationController;

  String? _selectedCity;

  List<CategoryEntity> _categories = const [];
  int? _selectedCategoryId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoadingCategories = true;
  String? _formError;
  bool _isSubmitting = false;
  LatLng? _pickedLocation;

  int get _bookedCount => widget.sessionData['booked_count'] as int? ?? 0;

  @override
  void initState() {
    super.initState();
    final d = widget.sessionData;
    _titleController = TextEditingController(
      text: d['title']?.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: d['description']?.toString() ?? '',
    );
    _seatsController = TextEditingController(
      text: (d['max_seats'] ?? 30).toString(),
    );
    _selectedCity = d['city']?.toString();
    _placeController = TextEditingController(
      text: d['place_name']?.toString() ?? '',
    );
    _durationController = TextEditingController(
      text: (d['duration_minutes'] ?? 90).toString(),
    );
    _selectedCategoryId = d['category_id'] as int?;

    final startLocal = DateTime.tryParse(d['starts_at']?.toString() ?? '')
        ?.toLocal();
    if (startLocal != null) {
      _selectedDate = startLocal;
      _selectedTime = TimeOfDay(
        hour: startLocal.hour,
        minute: startLocal.minute,
      );
    }
    final lat = (d['lat'] as num?)?.toDouble();
    final lng = (d['lng'] as num?)?.toDouble();
    if (lat != null && lng != null) {
      _pickedLocation = LatLng(lat, lng);
    }

    _loadCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _seatsController.dispose();
    _placeController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final isConnected = await sl<NetworkInfo>().isConnected;
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
      (f) => _showMessage(f.message),
      (list) => setState(() => _categories = list),
    );
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    setState(() => _formError = msg);
  }

  Future<void> _pickLocation() async {
    FocusScope.of(context).unfocus();

    // إن لم يختر المستخدم مدينة بعد → نطلب منه اختيارها أولاً
    if (_selectedCity == null && _pickedLocation == null) {
      _showMessage('اختر المحافظة أولاً ليتم تحديد موقعها على الخريطة');
      return;
    }

    // الأولوية: الموقع الذي اختاره المستخدم سابقاً، ثم مركز المدينة
    final initial = _pickedLocation ?? SyrianCities.centerOf(_selectedCity);

    final result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(builder: (_) => PickLocationPage(initial: initial)),
    );
    if (result != null && mounted) {
      setState(() {
        _pickedLocation = result;
        _formError = null;
      });
    }
  }

  Future<void> _submit() async {
    setState(() => _formError = null);
    if (!await sl<NetworkInfo>().isConnected) {
      _showMessage('create.error_offline'.tr());
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      _showMessage('يرجى تصحيح الحقول المظللة بالأحمر');
      return;
    }
    if (_selectedCategoryId == null) {
      _showMessage('create.category_required'.tr());
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      _showMessage('create.date_required'.tr());
      return;
    }
    if (_pickedLocation == null) {
      _showMessage('حدّد موقع المحاضرة على الخريطة أولاً');
      return;
    }

    if (_selectedCity == null) {
      _showMessage('create.city_required'.tr());
      return;
    }

    // ⬇️ هنا تضع التحقق ⬇️
    final cityCenter = SyrianCities.centerOf(_selectedCity);
    if (cityCenter != null && _pickedLocation != null) {
      final distance = const Distance().as(
        LengthUnit.Kilometer,
        cityCenter,
        _pickedLocation!,
      );
      if (distance > 100) {
        _showMessage(
          'الموقع المختار بعيد عن $_selectedCity (${distance.toStringAsFixed(0)} كم). '
          'تأكد من صحة الموقع.',
        );
        return;
      }
    }
    final startLocal = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    if (startLocal.isBefore(DateTime.now())) {
      _showMessage('يجب أن يكون الموعد في المستقبل');
      return;
    }

    final maxSeats = int.tryParse(_seatsController.text.trim()) ?? 30;
    if (maxSeats < _bookedCount) {
      _showMessage(
        'لا يمكن أن يقل عدد المقاعد عن الحجوزات الحالية ($_bookedCount)',
      );
      return;
    }

    final durationMinutes = int.tryParse(_durationController.text.trim()) ?? 90;

    setState(() => _isSubmitting = true);
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _isSubmitting) {
        setState(() => _isSubmitting = false);
        _showMessage('انتهت المهلة. تحقق من الاتصال وحاول مرة أخرى.');
      }
    });

    context.read<SessionCubit>().updateSession(
      sessionId: widget.sessionId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      categoryId: _selectedCategoryId!,
      city: _selectedCity ?? '',
      placeName: _placeController.text.trim(),
      startsAt: startLocal.toUtc().toIso8601String(),
      durationMinutes: durationMinutes,
      maxSeats: maxSeats,
      lat: _pickedLocation!.latitude,
      lng: _pickedLocation!.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocConsumer<SessionCubit, SessionState>(
      listener: (ctx, state) {
        if (state is SessionError) {
          if (mounted) setState(() => _isSubmitting = false);
          _showMessage(state.message);
        } else if (state is SessionUpdateSuccess &&
            state.session.id == widget.sessionId) {
          Navigator.pop(ctx, true);
        }
      },
      builder: (ctx, state) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
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
                      'تعديل المحاضرة',
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
                        if (v.trim().length < 3)
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
                    _cityDropdown(),
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
                        onTap: _isSubmitting ? null : () => _submit(),
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
            ),
          ),
        );
      },
    );
  }

  // ============ Widgets مساعدة (نسخة من create) ============
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

  Widget _dateTimePicker() {
    final cs = Theme.of(context).colorScheme;
    final dateText = _selectedDate == null
        ? ''
        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';
    final timeText = _selectedTime == null
        ? ''
        : _selectedTime!.format(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _field(
                label: 'create.date_label'.tr(),
                hint: dateText.isEmpty ? 'create.date_hint'.tr() : dateText,
                controller: TextEditingController(text: dateText),
                validator: (_) =>
                    _selectedDate == null ? 'create.date_required'.tr() : null,
                keyboardType: TextInputType.none,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _field(
                label: 'create.time_label'.tr(),
                hint: timeText.isEmpty ? 'create.time_hint'.tr() : timeText,
                controller: TextEditingController(text: timeText),
                validator: (_) =>
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
              child: _pickerButton(
                cs: cs,
                icon: Icons.calendar_today_outlined,
                label: 'create.date_picker'.tr(),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate:
                        (_selectedDate != null &&
                            !_selectedDate!.isBefore(DateTime.now()))
                        ? _selectedDate!
                        : DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _pickerButton(
                cs: cs,
                icon: Icons.access_time_outlined,
                label: 'create.time_picker'.tr(),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime ?? TimeOfDay.now(),
                  );
                  if (picked != null) {
                    setState(() => _selectedTime = picked);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _pickerButton({
    required ColorScheme cs,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: cs.outline),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: cs.primary, size: 20.w),
                  SizedBox(width: 8.w),
                  Text(
                    label,
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
                    items: _categories.map((c) {
                      return DropdownMenuItem<int>(
                        value: c.id,
                        child: Text(
                          c.nameFor(context.locale.languageCode),
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

  Widget _cityDropdown() {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'create.city_label'.tr(),
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
}
