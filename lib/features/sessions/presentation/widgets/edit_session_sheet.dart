import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/syrian_cities.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/network_info.dart';
import '../../../articles/presentation/cubit/categories_cubit.dart';
import '../session_cubit/session_cubit.dart';
import '../session_cubit/session_state.dart';
import 'pick_location_view.dart';
import 'session_form_fields.dart';

Future<bool> showEditSessionSheet(
  BuildContext context, {
  required String sessionId,
  required Map<String, dynamic> sessionData,
}) async {
  final updated = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<SessionCubit>()),
        BlocProvider.value(value: sl<CategoriesCubit>()),
      ],
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
  int? _selectedCategoryId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  LatLng? _pickedLocation;
  String? _formError;
  bool _isSubmitting = false;

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
    _placeController = TextEditingController(
      text: d['place_name']?.toString() ?? '',
    );
    _durationController = TextEditingController(
      text: (d['duration_minutes'] ?? 90).toString(),
    );

    final rawCity = d['city']?.toString();
    _selectedCity = (rawCity != null && SyrianCities.all.contains(rawCity))
        ? rawCity
        : null;
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

  void _showMessage(String message) {
    if (!mounted) return;
    setState(() => _formError = message);
  }

  Future<void> _pickLocation() async {
    FocusScope.of(context).unfocus();
    if (_selectedCity == null && _pickedLocation == null) {
      _showMessage('create.city_required'.tr());
      return;
    }
    final initial = _pickedLocation ?? SyrianCities.centerOf(_selectedCity);
    final result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(builder: (_) => PickLocationPage(initial: initial)),
    );
    if (!mounted) return; // ✅
    if (result != null) {
      setState(() {
        _pickedLocation = result;
        _formError = null;
      });
    }
  }

  Future<void> _submit() async {
    setState(() => _formError = null);

    final isConnected = await sl<NetworkInfo>().isConnected;
    if (!mounted) return; // ✅ إصلاح use_build_context_synchronously
    if (!isConnected) {
      _showMessage('create.error_offline'.tr());
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      _showMessage('create.form_invalid'.tr());
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
      _showMessage('create.location_required'.tr());
      return;
    }
    if (_selectedCity == null) {
      _showMessage('create.city_required'.tr());
      return;
    }

    final cityCenter = SyrianCities.centerOf(_selectedCity);
    if (cityCenter != null) {
      final distance = const Distance().as(
        LengthUnit.Kilometer,
        cityCenter,
        _pickedLocation!,
      );
      if (distance > 100) {
        _showMessage(
          'create.location_too_far'.tr(
            namedArgs: {
              'city': _selectedCity!,
              'distance': distance.toStringAsFixed(0),
            },
          ),
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
      _showMessage('create.date_past'.tr());
      return;
    }

    final maxSeats = int.tryParse(_seatsController.text.trim()) ?? 30;
    if (maxSeats < _bookedCount) {
      _showMessage(
        'create.seats_less_than_booked'.tr(
          namedArgs: {'count': _bookedCount.toString()},
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _isSubmitting) {
        setState(() => _isSubmitting = false);
        _showMessage('create.timeout'.tr());
      }
    });

    context.read<SessionCubit>().updateSession(
      sessionId: widget.sessionId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      categoryId: _selectedCategoryId!,
      city: _selectedCity!,
      placeName: _placeController.text.trim(),
      startsAt: startLocal.toUtc().toIso8601String(),
      durationMinutes: int.tryParse(_durationController.text.trim()) ?? 90,
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
                      'session.edit_title'.tr(),
                      style: AppTypography.arabicHeadline(
                        color: cs.onSurface,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 20.h),

                    SessionFormTextField(
                      label: 'create.title_label'.tr(),
                      hint: 'create.title_hint'.tr(),
                      controller: _titleController,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'create.title_required'.tr();
                        }
                        if (v.trim().length < 3) {
                          return 'create.title_length'.tr();
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),

                    SessionFormTextField(
                      label: 'create.description_label'.tr(),
                      hint: 'create.description_hint'.tr(),
                      controller: _descriptionController,
                      maxLines: 3,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'create.description_required'.tr()
                          : null,
                    ),
                    SizedBox(height: 12.h),

                    SessionFormTextField(
                      label: 'create.seats_label'.tr(),
                      hint: 'create.seats_hint'.tr(),
                      controller: _seatsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ], // 👈 هنا
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'create.seats_required'.tr();
                        }
                        final val = int.tryParse(v.trim());
                        if (val == null || val < 1 || val > 1000) {
                          return 'create.seats_invalid'.tr();
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),

                    SessionCityDropdown(
                      selectedCity: _selectedCity,
                      onChanged: (v) => setState(() => _selectedCity = v),
                    ),
                    SizedBox(height: 12.h),

                    SessionFormTextField(
                      label: 'create.place_label'.tr(),
                      hint: 'create.place_hint'.tr(),
                      controller: _placeController,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'create.place_required'.tr()
                          : null,
                    ),
                    SizedBox(height: 12.h),

                    SessionLocationPicker(
                      picked: _pickedLocation,
                      onTap: _pickLocation,
                    ),
                    SizedBox(height: 12.h),

                    SessionFormTextField(
                      label: 'create.duration_label'.tr(),
                      hint: 'create.duration_hint'.tr(),
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ], // 👈 هنا
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'create.duration_required'.tr();
                        }
                        final val = int.tryParse(v.trim());
                        if (val == null || val < 15 || val > 480) {
                          return 'create.duration_invalid'.tr();
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),

                    SessionDateTimePicker(
                      selectedDate: _selectedDate,
                      selectedTime: _selectedTime,
                      onDateChanged: (d) => setState(() => _selectedDate = d),
                      onTimeChanged: (t) => setState(() => _selectedTime = t),
                    ),
                    SizedBox(height: 12.h),

                    SessionCategoryDropdown(
                      selectedCategoryId: _selectedCategoryId,
                      onChanged: (v) => setState(() => _selectedCategoryId = v),
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

                    SizedBox(height: 24.h),
                    Material(
                      color: _isSubmitting
                          ? cs.surfaceContainerHighest
                          : cs.primary,
                      borderRadius: BorderRadius.circular(16.r),
                      child: InkWell(
                        onTap: _isSubmitting
                            ? null
                            : () {
                                FocusScope.of(context).unfocus();
                                _submit();
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
                                    'create.save_changes'.tr(),
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
}
