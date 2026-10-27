// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';

// import '../../../../app/theme/app_typography.dart';
// import '../../../../core/constants/app_spacing.dart';
// import '../../../../shared/widgets/app_article_card.dart';
// import '../../../../shared/widgets/app_segmented_bar.dart';
// import '../../../../shared/widgets/app_session_card.dart';
// import '../../../../shared/widgets/app_study_tool_card.dart';
// import '../../../articles/domain/entities/article_entity.dart';
// import '../../../sessions/domain/entities/booking_entity.dart';
// import '../../../sessions/domain/entities/session_entity.dart';
// import '../../../study_tools/domain/entities/study_tool_entity.dart';

// class ProfileActivityTabs extends StatefulWidget {
//   final bool isOwnerProfile;
//   final bool isLoadingLectures;
//   final bool isLoadingArticles;
//   final bool isLoadingTools;
//   final bool isLoadingBookings;
//   final List<SessionEntity> lectures;
//   final List<ArticleEntity> articles;
//   final List<StudyToolEntity> tools;
//   final List<BookingEntity> bookings;

//   const ProfileActivityTabs({
//     super.key,
//     required this.isOwnerProfile,
//     required this.isLoadingLectures,
//     required this.isLoadingArticles,
//     required this.isLoadingTools,
//     required this.isLoadingBookings,
//     required this.lectures,
//     required this.articles,
//     required this.tools,
//     required this.bookings,
//   });

//   @override
//   State<ProfileActivityTabs> createState() => _ProfileActivityTabsState();
// }

// class _ProfileActivityTabsState extends State<ProfileActivityTabs> {
//   int _activityTab = 0;

//   static final List<String> _weekdays = [
//     'session.day_sunday'.tr(),
//     'session.day_monday'.tr(),
//     'session.day_tuesday'.tr(),
//     'session.day_wednesday'.tr(),
//     'session.day_thursday'.tr(),
//     'session.day_friday'.tr(),
//     'session.day_saturday'.tr(),
//   ];

//   static final List<String> _months = [
//     'session.month_january'.tr(),
//     'session.month_february'.tr(),
//     'session.month_march'.tr(),
//     'session.month_april'.tr(),
//     'session.month_may'.tr(),
//     'session.month_june'.tr(),
//     'session.month_july'.tr(),
//     'session.month_august'.tr(),
//     'session.month_september'.tr(),
//     'session.month_october'.tr(),
//     'session.month_november'.tr(),
//     'session.month_december'.tr(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'profile.dashboard'.tr(),
//             style: AppTypography.arabicTitle(
//               color: Theme.of(context).colorScheme.onSurface,
//               fontSize: 18,
//             ),
//           ),
//           SizedBox(height: 12.h),
//           AppSegmentedBar(
//             labels: widget.isOwnerProfile
//                 ? [
//                     'tabs.my_lectures'.tr(),
//                     'tabs.my_articles'.tr(),
//                     'tabs.my_tools'.tr(),
//                     'tabs.my_bookings'.tr(),
//                   ]
//                 // نصوص مؤقتة بالعربية لملف مستخدم آخر.
//                 : const ['المحاضرات', 'المقالات'],
//             icons: widget.isOwnerProfile
//                 ? const [
//                     Icons.groups_3,
//                     Icons.article_outlined,
//                     Icons.inventory_2_outlined,
//                     Icons.event_available,
//                   ]
//                 : const [Icons.groups_3, Icons.article_outlined],
//             selectedIndex: _activityTab,
//             onTabChanged: (index) {
//               setState(() {
//                 _activityTab = index;
//               });
//             },
//           ),
//           SizedBox(height: 16.h),
//           // قصر الارتفاع إلى ما يقارب ثلث الشاشة مع توفير سكرول داخلي مستقل
//           SizedBox(
//             height: 340.h,
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(16.r),
//               child: SingleChildScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 child: _buildTabContent(context),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTabContent(BuildContext context) {
//     if (!widget.isOwnerProfile) {
//       return _activityTab == 1
//           ? _buildPublicArticlesTab(context)
//           : _buildPublicLecturesTab(context);
//     }
//     switch (_activityTab) {
//       case 0:
//         return _buildLecturesTab(context);
//       case 1:
//         return _buildArticlesTab(context);
//       case 2:
//         return _buildToolsTab(context);
//       case 3:
//         return _buildBookingsTab(context);
//       default:
//         return _buildLecturesTab(context);
//     }
//   }

//   Widget _buildLecturesTab(BuildContext context) {
//     if (widget.isLoadingLectures) {
//       return const SizedBox(
//         height: 200,
//         child: Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (widget.lectures.isEmpty) {
//       final cs = Theme.of(context).colorScheme;
//       return Center(
//         child: Padding(
//           padding: EdgeInsets.symmetric(vertical: 40.h),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.groups_3, color: cs.onSurfaceVariant, size: 56.w),
//               SizedBox(height: 12.h),
//               Text(
//                 'profile.my_lectures_empty'.tr(),
//                 style: AppTypography.arabicTitle(
//                   color: cs.onSurface,
//                   fontSize: 16,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Column(
//       children: [
//         for (var i = 0; i < widget.lectures.length; i++) ...[
//           GestureDetector(
//             onTap: () => context.push(
//               '/session-details/${widget.lectures[i].id}?isPublisher=true',
//             ),
//             child: _ActivityCard(
//               status: widget.lectures[i].bookedCount >= 10
//                   ? 'profile.confirmed'.tr()
//                   : 'profile.pending'.tr(),
//               title: widget.lectures[i].title,
//               description: widget.lectures[i].description,
//               seats:
//                   '${widget.lectures[i].bookedCount}/${widget.lectures[i].maxSeats > 0 ? widget.lectures[i].maxSeats : 1}',
//               minSeats: 'profile.min_seats'.tr(namedArgs: {'value': '10'}),
//             ),
//           ),
//           if (i < widget.lectures.length - 1) SizedBox(height: 12.h),
//         ],
//       ],
//     );
//   }

//   Widget _buildArticlesTab(BuildContext context) {
//     if (widget.isLoadingArticles) {
//       return const SizedBox(
//         height: 200,
//         child: Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (widget.articles.isEmpty) {
//       final cs = Theme.of(context).colorScheme;
//       return Center(
//         child: Padding(
//           padding: EdgeInsets.symmetric(vertical: 40.h),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.article_outlined,
//                 color: cs.onSurfaceVariant,
//                 size: 56.w,
//               ),
//               SizedBox(height: 12.h),
//               Text(
//                 'profile.my_articles_empty'.tr(),
//                 style: AppTypography.arabicTitle(
//                   color: cs.onSurface,
//                   fontSize: 16,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//     return Column(
//       children: [
//         for (var i = 0; i < widget.articles.length; i++) ...[
//           AppArticleCard(
//             title: widget.articles[i].title,
//             body: widget.articles[i].body,
//             articleId: widget.articles[i].id,
//           ),
//           if (i < widget.articles.length - 1) SizedBox(height: 12.h),
//         ],
//       ],
//     );
//   }

//   Widget _buildToolsTab(BuildContext context) {
//     if (widget.isLoadingTools) {
//       return const SizedBox(
//         height: 200,
//         child: Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (widget.tools.isEmpty) {
//       final cs = Theme.of(context).colorScheme;
//       return Center(
//         child: Padding(
//           padding: EdgeInsets.symmetric(vertical: 40.h),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.inventory_2_outlined,
//                 color: cs.onSurfaceVariant,
//                 size: 56.w,
//               ),
//               SizedBox(height: 12.h),
//               Text(
//                 'profile.my_tools_empty'.tr(),
//                 style: AppTypography.arabicTitle(
//                   color: cs.onSurface,
//                   fontSize: 16,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Column(
//       children: [
//         for (var i = 0; i < widget.tools.length; i++) ...[
//           AppStudyToolCard(
//             index: i,
//             title: widget.tools[i].title,
//             subject: widget.tools[i].subject,
//             studyYear: widget.tools[i].studyYear,
//             university: widget.tools[i].university,
//             city: widget.tools[i].city,
//             pickupPlace: widget.tools[i].pickupPlace,
//             isTaken: widget.tools[i].isTaken,
//           ),
//           if (i < widget.tools.length - 1) SizedBox(height: 12.h),
//         ],
//       ],
//     );
//   }

//   Widget _buildBookingsTab(BuildContext context) {
//     if (widget.isLoadingBookings) {
//       return const SizedBox(
//         height: 200,
//         child: Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (widget.bookings.isEmpty) {
//       final cs = Theme.of(context).colorScheme;
//       return Center(
//         child: Padding(
//           padding: EdgeInsets.symmetric(vertical: 40.h),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.event_available,
//                 color: cs.onSurfaceVariant,
//                 size: 56.w,
//               ),
//               SizedBox(height: 12.h),
//               Text(
//                 'profile.my_bookings_empty'.tr(),
//                 style: AppTypography.arabicTitle(
//                   color: cs.onSurface,
//                   fontSize: 16,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Column(
//       children: [
//         for (var i = 0; i < widget.bookings.length; i++) ...[
//           _buildBookingCard(context, widget.bookings[i]),
//           if (i < widget.bookings.length - 1) SizedBox(height: 12.h),
//         ],
//       ],
//     );
//   }

//   Widget _buildBookingCard(BuildContext context, BookingEntity booking) {
//     final session = booking.session;
//     final startTime = DateTime.tryParse(session.startsAt)?.toLocal();
//     final bookedCount = session.bookedCount;
//     final maxSeats = session.maxSeats > 0 ? session.maxSeats : 1;
//     final factor = (bookedCount / maxSeats).clamp(0.0, 1.0).toDouble();
//     final percent = (bookedCount / maxSeats * 100).round();
//     final lecturer = session.lecturerName;
//     final location = [
//       session.placeName,
//       session.city,
//     ].where((part) => part.isNotEmpty).join(' — ');
//     String dateLabel = 'session.unspecified'.tr();
//     String timeLabel = 'session.unspecified'.tr();
//     if (startTime != null) {
//       dateLabel =
//           '${_weekdays[startTime.weekday % 7]} ${startTime.day} ${_months[startTime.month - 1]}';
//       final hour = startTime.hour;
//       final minute = startTime.minute;
//       timeLabel =
//           '${hour > 12 ? hour - 12 : hour}:${minute.toString().padLeft(2, '0')} ${hour >= 12 ? 'session.pm'.tr() : 'session.am'.tr()}';
//     }

//     return AppSessionCard(
//       sessionId: session.id,
//       title: session.title,
//       lecturerName: lecturer,
//       lecturerInitial: lecturer.isNotEmpty ? lecturer[0] : ' — ',
//       dateLabel: dateLabel,
//       timeLabel: timeLabel,
//       locationLabel: location,
//       mapPillLabel: location,
//       capacityFactor: factor,
//       percentLabel: '$percent%',
//       seatsLabel: '$bookedCount/$maxSeats',
//       ctaLabel: 'booking.booked'.tr(),
//       lat: session.lat,
//       lng: session.lng,
//     );
//   }

//   Widget _publicEmpty(BuildContext context, IconData icon, String text) {
//     final cs = Theme.of(context).colorScheme;
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.symmetric(vertical: 40.h),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, color: cs.onSurfaceVariant, size: 56.w),
//             SizedBox(height: 12.h),
//             Text(
//               text,
//               style: AppTypography.arabicTitle(
//                 color: cs.onSurface,
//                 fontSize: 16,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// محاضرات المحاضر الحقيقية (بدل البطاقات الوهمية).
//   Widget _buildPublicLecturesTab(BuildContext context) {
//     if (widget.isLoadingLectures) {
//       return const SizedBox(
//         height: 200,
//         child: Center(child: CircularProgressIndicator()),
//       );
//     }
//     if (widget.lectures.isEmpty) {
//       // نص مؤقت بالعربية. انقله إلى ملفات الترجمة لاحقاً.
//       return _publicEmpty(context, Icons.groups_3, 'لا توجد محاضرات قادمة');
//     }
//     return Column(
//       children: [
//         for (var i = 0; i < widget.lectures.length; i++) ...[
//           _buildSessionCard(context, widget.lectures[i]),
//           if (i < widget.lectures.length - 1) SizedBox(height: 12.h),
//         ],
//       ],
//     );
//   }

//   Widget _buildSessionCard(BuildContext context, SessionEntity session) {
//     final startTime = DateTime.tryParse(session.startsAt)?.toLocal();
//     final bookedCount = session.bookedCount;
//     final maxSeats = session.maxSeats > 0 ? session.maxSeats : 1;
//     final factor = (bookedCount / maxSeats).clamp(0.0, 1.0).toDouble();
//     final percent = (bookedCount / maxSeats * 100).round();
//     final lecturer = session.lecturerName;
//     final location = [
//       session.placeName,
//       session.city,
//     ].where((part) => part.isNotEmpty).join(' — ');

//     String dateLabel = 'session.unspecified'.tr();
//     String timeLabel = 'session.unspecified'.tr();
//     if (startTime != null) {
//       dateLabel =
//           '${_weekdays[startTime.weekday % 7]} ${startTime.day} ${_months[startTime.month - 1]}';
//       final hour = startTime.hour;
//       final minute = startTime.minute;
//       timeLabel =
//           '${hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)}:${minute.toString().padLeft(2, '0')} ${hour >= 12 ? 'session.pm'.tr() : 'session.am'.tr()}';
//     }

//     return AppSessionCard(
//       sessionId: session.id,
//       title: session.title,
//       lecturerName: lecturer,
//       lecturerInitial: lecturer.isNotEmpty ? lecturer[0] : ' — ',
//       dateLabel: dateLabel,
//       timeLabel: timeLabel,
//       locationLabel: location,
//       mapPillLabel: location,
//       capacityFactor: factor,
//       percentLabel: '$percent%',
//       seatsLabel: '$bookedCount/$maxSeats',
//       lat: session.lat,
//       lng: session.lng,
//     );
//   }

//   /// مقالات المحاضر الحقيقية.
//   Widget _buildPublicArticlesTab(BuildContext context) {
//     if (widget.isLoadingArticles) {
//       return const SizedBox(
//         height: 200,
//         child: Center(child: CircularProgressIndicator()),
//       );
//     }
//     if (widget.articles.isEmpty) {
//       // نص مؤقت بالعربية. انقله إلى ملفات الترجمة لاحقاً.
//       return _publicEmpty(
//         context,
//         Icons.article_outlined,
//         'لا توجد مقالات بعد',
//       );
//     }
//     return Column(
//       children: [
//         for (var i = 0; i < widget.articles.length; i++) ...[
//           AppArticleCard(
//             title: widget.articles[i].title,
//             body: widget.articles[i].body,
//             articleId: widget.articles[i].id,
//           ),
//           if (i < widget.articles.length - 1) SizedBox(height: 12.h),
//         ],
//       ],
//     );
//   }
// }

// class _ActivityCard extends StatelessWidget {
//   final String status;
//   final String title;
//   final String description;
//   final String seats;
//   final String minSeats;

//   const _ActivityCard({
//     required this.status,
//     required this.title,
//     required this.description,
//     required this.seats,
//     required this.minSeats,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surfaceContainerLow,
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(
//           color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
//             decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.primary
//                   .withValues(alpha: 0.1),
//               borderRadius: BorderRadius.circular(20.r),
//               border: Border.all(
//                 color: Theme.of(context).colorScheme.primary
//                     .withValues(alpha: 0.3),
//               ),
//             ),
//             child: Text(
//               status,
//               style: AppTypography.arabicCaption(
//                 color: Theme.of(context).colorScheme.primary,
//                 fontSize: 11,
//               ),
//             ),
//           ),
//           SizedBox(height: 12.h),
//           Text(
//             title,
//             style: AppTypography.arabicTitle(
//               color: Theme.of(context).colorScheme.onSurface,
//               fontSize: 15,
//             ),
//           ),
//           SizedBox(height: 4.h),
//           Text(
//             description,
//             style: AppTypography.arabicCaption(
//               color: Theme.of(context).colorScheme.onSurfaceVariant,
//               fontSize: 12,
//             ),
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//           SizedBox(height: 12.h),
//           Row(
//             children: [
//               Text(
//                 minSeats,
//                 style: AppTypography.arabicCaption(
//                   color: Theme.of(context).colorScheme.onSurfaceVariant,
//                   fontSize: 11,
//                 ),
//               ),
//               const Spacer(),
//               Text(
//                 seats,
//                 style: AppTypography.monoCaption(
//                   color: Theme.of(context).colorScheme.primary,
//                   fontSize: 12,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 12.h),
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.symmetric(vertical: 10.h),
//             decoration: BoxDecoration(
//               color: Colors.transparent,
//               borderRadius: BorderRadius.circular(12.r),
//               border: Border.all(color: Theme.of(context).colorScheme.outline),
//             ),
//             child: Center(
//               child: Text(
//                 'profile.cancel_48h'.tr(),
//                 style: AppTypography.arabicLabel(
//                   color: Theme.of(context).colorScheme.onSurfaceVariant,
//                   fontSize: 12,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
