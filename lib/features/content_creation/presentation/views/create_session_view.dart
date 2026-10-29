// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import '../../../profile/presentation/widgets/profile_guard.dart';
// import '../../../../app/theme/app_typography.dart';
// import '../../../../core/constants/app_spacing.dart';
// import '../widgets/success_dialog.dart';

// /// Create Session screen — for creating a new lecture/study session.
// /// Fields: Title, Description, Category, City, Place, DateTime, Duration, Max seats.
// class CreateSessionView extends StatefulWidget {
//   const CreateSessionView({super.key});

//   @override
//   State<CreateSessionView> createState() => _CreateSessionViewState();
// }

// class _CreateSessionViewState extends State<CreateSessionView> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _cityController = TextEditingController();
//   final _placeController = TextEditingController();
//   final _durationController = TextEditingController(text: '90');
//   final _maxSeatsController = TextEditingController();

//   String? _selectedCategory;
//   DateTime? _selectedDateTime;

//   final List<String> _categories = [
//     'علوم شريعة',
//     'طب',
//     'برمجة',
//     'تجارة',
//     'تطوير ذاتي',
//     'أكاديمي',
//   ];

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descriptionController.dispose();
//     _cityController.dispose();
//     _placeController.dispose();
//     _durationController.dispose();
//     _maxSeatsController.dispose();
//     super.dispose();
//   }

//   void _pickDateTime() async {
//     final date = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now().add(const Duration(days: 1)),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//     );
//     if (date != null && mounted) {
//       final time = await showTimePicker(
//         context: context,
//         initialTime: TimeOfDay.now(),
//       );
//       if (time != null) {
//         setState(() {
//           _selectedDateTime = DateTime(
//             date.year,
//             date.month,
//             date.day,
//             time.hour,
//             time.minute,
//           );
//         });
//       }
//     }
//   }

//   Future<void> _submit() async {
//     if (_formKey.currentState?.validate() ?? false) {
//       if (_selectedDateTime == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('يرجى تحديد تاريخ ووقت الجلسة'),
//             backgroundColor: Theme.of(context).colorScheme.error,
//           ),
//         );
//         return;
//       }
//       // Incomplete-profile guard (backend specification).
//       if (!await ensureProfileComplete(context)) return;
//       if (!context.mounted) return;
//       // TODO: Insert into Supabase sessions table
//       showSuccessDialog(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     return Scaffold(
//       backgroundColor: colorScheme.surface,
//       appBar: AppBar(
//         backgroundColor: colorScheme.surface,
//         foregroundColor: colorScheme.onSurface,
//         elevation: 0,
//         centerTitle: true,
//         title: Text(
//           'إنشاء جلسة علمية',
//           style: AppTypography.arabicTitle(
//             color: colorScheme.onSurface,
//             fontSize: 20,
//           ),
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(AppSpacing.screenHorizontal),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Title field
//                 _buildField(
//                   label: 'عنوان الجلسة',
//                   hint: 'مثال: شرح كتاب التوحيد',
//                   controller: _titleController,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'العنوان مطلوب';
//                     }
//                     if (value.length < 3 || value.length > 150) {
//                       return 'العنوان يجب أن يكون بين 3 و 150 حرف';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 16.h),
//                 // Description field
//                 _buildField(
//                   label: 'الوصف',
//                   hint: 'وصف تفصيلي للجلسة العلمية',
//                   controller: _descriptionController,
//                   maxLines: 5,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'الوصف مطلوب';
//                     }
//                     if (value.length < 1 || value.length > 5000) {
//                       return 'الوصف يجب أن يكون بين 1 و 5000 حرف';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 16.h),
//                 // Category dropdown
//                 _buildDropdown(
//                   label: 'التصنيف',
//                   hint: 'اختر التصنيف',
//                   value: _selectedCategory,
//                   items: _categories,
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedCategory = value;
//                     });
//                   },
//                 ),
//                 SizedBox(height: 16.h),
//                 // City field
//                 _buildField(
//                   label: 'المدينة',
//                   hint: 'مثال: الرياض',
//                   controller: _cityController,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'المدينة مطلوبة';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 16.h),
//                 // Place field
//                 _buildField(
//                   label: 'اسم المكان',
//                   hint: 'مثال: جامع الملك فهد',
//                   controller: _placeController,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'اسم المكان مطلوب';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 16.h),
//                 // DateTime picker
//                 _buildDateTimeField(colorScheme),
//                 SizedBox(height: 16.h),
//                 // Duration field
//                 _buildField(
//                   label: 'المدة (بالدقائق)',
//                   hint: '90',
//                   controller: _durationController,
//                   keyboardType: TextInputType.number,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'المدة مطلوبة';
//                     }
//                     final duration = int.tryParse(value);
//                     if (duration == null || duration <= 0) {
//                       return 'المدة يجب أن تكون رقم موجب';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 16.h),
//                 // Max seats field
//                 _buildField(
//                   label: 'الحد الأقصى للمقاعد',
//                   hint: 'مثال: 30',
//                   controller: _maxSeatsController,
//                   keyboardType: TextInputType.number,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'الحد الأقصى مطلوب';
//                     }
//                     final seats = int.tryParse(value);
//                     if (seats == null || seats <= 0) {
//                       return 'يجب أن يكون رقم أكبر من صفر';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 32.h),
//                 // Submit button
//                 _buildSubmitButton(colorScheme),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildField({
//     required String label,
//     required String hint,
//     required TextEditingController controller,
//     int maxLines = 1,
//     TextInputType? keyboardType,
//     String? Function(String?)? validator,
//   }) {
//     final colorScheme = Theme.of(context).colorScheme;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: AppTypography.arabicLabel(
//             color: colorScheme.onSurface,
//             fontSize: 14,
//           ),
//         ),
//         SizedBox(height: 8.h),
//         TextFormField(
//           controller: controller,
//           maxLines: maxLines,
//           keyboardType: keyboardType,
//           style: AppTypography.arabicBody(
//             color: colorScheme.onSurface,
//             fontSize: 16,
//           ),
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: AppTypography.arabicBody(
//               color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
//               fontSize: 16,
//             ),
//             filled: true,
//             fillColor: colorScheme.surfaceContainerLow,
//             contentPadding: EdgeInsets.symmetric(
//               horizontal: 16.w,
//               vertical: 14.h,
//             ),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.r),
//               borderSide: BorderSide(color: colorScheme.outline),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.r),
//               borderSide: BorderSide(color: colorScheme.outline),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.r),
//               borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
//             ),
//             errorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.r),
//               borderSide: BorderSide(color: colorScheme.error),
//             ),
//           ),
//           validator: validator,
//         ),
//       ],
//     );
//   }

//   Widget _buildDropdown({
//     required String label,
//     required String hint,
//     required String? value,
//     required List<String> items,
//     required ValueChanged<String?> onChanged,
//   }) {
//     final colorScheme = Theme.of(context).colorScheme;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: AppTypography.arabicLabel(
//             color: colorScheme.onSurface,
//             fontSize: 14,
//           ),
//         ),
//         SizedBox(height: 8.h),
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 16.w),
//           decoration: BoxDecoration(
//             color: colorScheme.surfaceContainerLow,
//             borderRadius: BorderRadius.circular(12.r),
//             border: Border.all(color: colorScheme.outline),
//           ),
//           child: DropdownButtonHideUnderline(
//             child: DropdownButton<String>(
//               value: value,
//               hint: Text(
//                 hint,
//                 style: AppTypography.arabicBody(
//                   color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
//                   fontSize: 16,
//                 ),
//               ),
//               isExpanded: true,
//               items: items.map((item) {
//                 return DropdownMenuItem<String>(
//                   value: item,
//                   child: Text(
//                     item,
//                     style: AppTypography.arabicBody(
//                       color: colorScheme.onSurface,
//                       fontSize: 16,
//                     ),
//                   ),
//                 );
//               }).toList(),
//               onChanged: onChanged,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDateTimeField(ColorScheme colorScheme) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'تاريخ ووقت الجلسة',
//           style: AppTypography.arabicLabel(
//             color: colorScheme.onSurface,
//             fontSize: 14,
//           ),
//         ),
//         SizedBox(height: 8.h),
//         GestureDetector(
//           onTap: _pickDateTime,
//           child: Container(
//             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
//             decoration: BoxDecoration(
//               color: colorScheme.surfaceContainerLow,
//               borderRadius: BorderRadius.circular(12.r),
//               border: Border.all(color: colorScheme.outline),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.calendar_today_outlined,
//                   color: colorScheme.onSurfaceVariant,
//                   size: 20.w,
//                 ),
//                 SizedBox(width: 12.w),
//                 Text(
//                   _selectedDateTime != null
//                       ? '${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} - ${_selectedDateTime!.hour}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}'
//                       : 'اختر التاريخ والوقت',
//                   style: AppTypography.arabicBody(
//                     color: _selectedDateTime != null
//                         ? colorScheme.onSurface
//                         : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
//                     fontSize: 16,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSubmitButton(ColorScheme colorScheme) {
//     return Material(
//       color: colorScheme.primary,
//       borderRadius: BorderRadius.circular(16.r),
//       child: InkWell(
//         onTap: _submit,
//         borderRadius: BorderRadius.circular(16.r),
//         child: Padding(
//           padding: EdgeInsets.symmetric(vertical: 16.h),
//           child: Center(
//             child: Text(
//               'نشر الجلسة',
//               style: AppTypography.arabicTitle(
//                 color: colorScheme.onPrimary,
//                 fontSize: 18,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
