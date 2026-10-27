import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/widgets/app_search_bar.dart';
import '../../../../shared/widgets/app_segmented_bar.dart';
import '../../../../shared/widgets/app_session_card.dart';
import '../../../../shared/widgets/app_study_tool_card.dart';
import '../../../../shared/widgets/app_top_header.dart';
import '../../../articles/domain/entities/article_entity.dart';
import '../../../sessions/domain/entities/session_entity.dart';
import '../../../study_tools/domain/entities/study_tool_entity.dart';
import '../../presentation/bloc/search_cubit.dart';
import '../../presentation/bloc/search_state.dart';
import '../../../../shared/widgets/app_article_card.dart';

/// Search screen — Stitch Design System with tab switching and dynamic filtering.
class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    print('<<<<<<<<<<<[SearchView.dispose]>>>>>>>>>>>>>');
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('<<<<<<<<<<<[SearchView.build]>>>>>>>>>>>>>');
    return BlocProvider(
      create: (_) => sl<SearchCubit>()..load(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTopHeader(
                    context: context,
                    onBack: () => Navigator.of(context).pop(),
                    trailing: null,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                      vertical: AppSpacing.md,
                    ),
                    child: AppSearchBar(
                      controller: _searchController,
                      onChanged: (value) {
                        context.read<SearchCubit>().setQuery(value);
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.tune,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        onPressed: () => _showFilterBottomSheet(context),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                    ),
                    child: BlocBuilder<SearchCubit, SearchState>(
                      builder: (context, state) {
                        final selectedTab = state is SearchLoaded
                            ? state.selectedTab
                            : 0;
                        return AppSegmentedBar(
                          labels: [
                            'tabs.lectures'.tr(),
                            'tabs.articles'.tr(),
                            'tabs.tools'.tr(),
                          ],
                          selectedIndex: selectedTab,
                          onTabChanged: (index) =>
                              context.read<SearchCubit>().setTab(index),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: BlocBuilder<SearchCubit, SearchState>(
                      builder: (context, state) {
                        if (state is SearchLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (state is SearchError) {
                          return _buildErrorState(context, state);
                        }

                        if (state is SearchLoaded) {
                          final isQueryEmpty = _searchController.text
                              .trim()
                              .isEmpty;
                          switch (state.selectedTab) {
                            case 0:
                              return state.sessions.isEmpty
                                  ? _buildEmptyState(context, 0, isQueryEmpty)
                                  : _buildSessionResults(state.sessions);
                            case 1:
                              return state.articles.isEmpty
                                  ? _buildEmptyState(context, 1, isQueryEmpty)
                                  : _buildArticleResults(state.articles);
                            case 2:
                              return state.tools.isEmpty
                                  ? _buildEmptyState(context, 2, isQueryEmpty)
                                  : _buildToolResults(state.tools);
                            default:
                              return _buildEmptyState(
                                context,
                                state.selectedTab,
                                isQueryEmpty,
                              );
                          }
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final cubit = context.read<SearchCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return SearchFilterBottomSheet(cubit: cubit);
      },
    );
  }

  Widget _buildErrorState(BuildContext context, SearchError state) {
    final cs = Theme.of(context).colorScheme;
    final cubit = context.read<SearchCubit>();
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: cs.error, size: 56.w),
            SizedBox(height: 12.h),
            Text(
              state.message.tr(),
              style: AppTypography.arabicCaption(
                color: cs.onSurfaceVariant,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            Material(
              color: cs.primary,
              borderRadius: BorderRadius.circular(12.r),
              child: InkWell(
                onTap: () => cubit.retry(),
                borderRadius: BorderRadius.circular(12.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, color: cs.onPrimary, size: 18.w),
                      SizedBox(width: 8.w),
                      Text(
                        'sessions.retry'.tr(),
                        style: AppTypography.arabicLabel(
                          color: cs.onPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    int selectedTab,
    bool isQueryEmpty,
  ) {
    String key;
    if (isQueryEmpty) {
      key = 'search.no_data_available';
    } else {
      switch (selectedTab) {
        case 0:
          key = 'search.no_lectures';
          break;
        case 1:
          key = 'search.no_articles';
          break;
        case 2:
          key = 'search.no_tools';
          break;
        default:
          key = 'search.no_results';
      }
    }
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Text(
          key.tr(),
          style: AppTypography.arabicTitle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSessionResults(List<SessionEntity> sessions) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.md,
      ),
      itemCount: sessions.length,
      separatorBuilder: (_, _) => SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) =>
          _buildSessionCard(context, sessions[index]),
    );
  }

  Widget _buildSessionCard(BuildContext context, SessionEntity session) {
    final startTime = DateTime.tryParse(session.startsAt)?.toLocal();
    final bookedCount = session.bookedCount;
    final maxSeats = session.maxSeats > 0 ? session.maxSeats : 1;
    final factor = (bookedCount / maxSeats).clamp(0.0, 1.0).toDouble();
    final percent = (bookedCount / maxSeats * 100).round();
    final lecturer = session.lecturerName;
    final location = [
      session.placeName,
      session.city,
    ].where((part) => part.isNotEmpty).join(' — ');

    String dateLabel = 'session.unspecified'.tr();
    String timeLabel = 'session.unspecified'.tr();
    if (startTime != null) {
      dateLabel = _formatDate(startTime);
      final hour = startTime.hour;
      final minute = startTime.minute;
      timeLabel =
          '${hour > 12 ? hour - 12 : hour}:${minute.toString().padLeft(2, '0')} '
          '${hour >= 12 ? 'session.pm'.tr() : 'session.am'.tr()}';
    }

    return AppSessionCard(
      sessionId: session.id,
      title: session.title,
      lecturerName: lecturer.isNotEmpty ? lecturer : 'session.unspecified'.tr(),
      lecturerInitial: lecturer.isNotEmpty ? lecturer[0] : '—',
      dateLabel: dateLabel,
      timeLabel: timeLabel,
      locationLabel: location.isNotEmpty
          ? location
          : 'session.unspecified'.tr(),
      mapPillLabel: location.isNotEmpty ? location : 'session.unspecified'.tr(),
      capacityFactor: factor,
      percentLabel: '$percent%',
      seatsLabel: '$bookedCount/$maxSeats',
      lat: session.lat,
      lng: session.lng,
    );
  }

  String _formatDate(DateTime value) {
    const weekdays = <String>[
      'session.day_sunday',
      'session.day_monday',
      'session.day_tuesday',
      'session.day_wednesday',
      'session.day_thursday',
      'session.day_friday',
      'session.day_saturday',
    ];
    const months = <String>[
      'session.month_january',
      'session.month_february',
      'session.month_march',
      'session.month_april',
      'session.month_may',
      'session.month_june',
      'session.month_july',
      'session.month_august',
      'session.month_september',
      'session.month_october',
      'session.month_november',
      'session.month_december',
    ];
    final weekdayKey = weekdays[value.weekday % 7];
    final monthKey = months[value.month - 1];
    return '${weekdayKey.tr()} ${value.day} ${monthKey.tr()}';
  }

  Widget _buildArticleResults(List<ArticleEntity> articles) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.md,
      ),
      itemCount: articles.length,
      separatorBuilder: (_, _) => SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final article = articles[index];
        return AppArticleCard(title: article.title, body: article.body);
      },
    );
  }

  Widget _buildToolResults(List<StudyToolEntity> tools) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.md,
      ),
      itemCount: tools.length,
      separatorBuilder: (_, _) => SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final tool = tools[index];
        return AppStudyToolCard(
          index: index,
          title: tool.title,
          subject: tool.subject,
          studyYear: tool.studyYear,
          university: tool.university,
          city: tool.city,
          pickupPlace: tool.pickupPlace,
          isTaken: tool.isTaken,
        );
      },
    );
  }
}

/// Professional Filter BottomSheet with dynamic database categories and action buttons.
class SearchFilterBottomSheet extends StatefulWidget {
  final SearchCubit cubit;

  const SearchFilterBottomSheet({super.key, required this.cubit});

  @override
  State<SearchFilterBottomSheet> createState() =>
      _SearchFilterBottomSheetState();
}

class _SearchFilterBottomSheetState extends State<SearchFilterBottomSheet> {
  String? _selectedCategory;
  String? _selectedLocation;
  bool? _isAvailable;
  DateTime? _selectedDate;

  static const List<String> _syrianGovernorates = [
    'دمشق',
    'ريف دمشق',
    'حلب',
    'حمص',
    'حماة',
    'اللاذقية',
    'طرطوس',
    'إدلب',
    'درعا',
    'السويداء',
    'القنيطرة',
    'دير الزور',
    'الرقة',
    'الحسكة',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.cubit.category;
    _selectedLocation = widget.cubit.location;
    _isAvailable = widget.cubit.isAvailable;
    _selectedDate = widget.cubit.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    print('<<<<<<<<<<<[SearchFilterBottomSheet.build]>>>>>>>>>>>>>');
    final selectedTab = widget.cubit.selectedTab;
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
        left: AppSpacing.screenHorizontal,
        right: AppSpacing.screenHorizontal,
        top: AppSpacing.md,
      ),
      constraints: BoxConstraints(maxHeight: 520.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'search.filter.title'.tr(),
                style: AppTypography.arabicTitle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: _buildFilterContent(context, selectedTab),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    print(
                      '<<<<<<<<<<<[SearchFilterBottomSheet.clearFilters]>>>>>>>>>>>>>',
                    );
                    setState(() {
                      _selectedCategory = null;
                      _selectedLocation = null;
                      _isAvailable = null;
                      _selectedDate = null;
                    });
                    widget.cubit.clearFilters();
                  },
                  child: Text('search.filter.clear'.tr()),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    print(
                      '<<<<<<<<<<<[SearchFilterBottomSheet.applyFilters]>>>>>>>>>>>>>',
                    );
                    widget.cubit.applyFilters(
                      category: _selectedCategory,
                      selectedDate: _selectedDate,
                      location: _selectedLocation,
                      isAvailable: _isAvailable,
                    );
                    Navigator.pop(context);
                  },
                  child: Text('search.filter.apply'.tr()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterContent(BuildContext context, int selectedTab) {
    if (selectedTab == 0) {
      return _buildSessionsFilterSheet(context);
    } else if (selectedTab == 1) {
      return _buildArticlesFilterSheet(context);
    } else {
      return _buildToolsFilterSheet(context);
    }
  }

  Widget _buildSessionsFilterSheet(BuildContext context) {
    // Fallback to all categories if sessionCategories is empty
    final categoryIds = widget.cubit.sessionCategories.isNotEmpty
        ? widget.cubit.sessionCategories
        : widget.cubit.categories.map((c) => c.id).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            Icons.calendar_today,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            'search.filter.date'.tr(),
            style: AppTypography.arabicBody(fontSize: 14),
          ),
          trailing: Text(
            _selectedDate != null
                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                : 'search.filter.select_date'.tr(),
            style: AppTypography.arabicBody(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 12,
            ),
          ),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) setState(() => _selectedDate = picked);
          },
        ),
        const Divider(),
        Text(
          'search.filter.location'.tr(),
          style: AppTypography.arabicCaption(fontSize: 12),
        ),
        SizedBox(height: 6.h),
        DropdownButtonFormField<String>(
          initialValue: _selectedLocation,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: 'search.filter.location_hint'.tr(),
            border: const OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 8.h,
            ),
          ),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                'search.filter.all'.tr(),
                style: AppTypography.arabicBody(fontSize: 14),
              ),
            ),
            ..._syrianGovernorates.map(
              (gov) => DropdownMenuItem<String>(
                value: gov,
                child: Text(gov, style: AppTypography.arabicBody(fontSize: 14)),
              ),
            ),
          ],
          onChanged: (val) => setState(() => _selectedLocation = val),
        ),
        if (categoryIds.isNotEmpty) ...[
          const Divider(),
          Text(
            'search.filter.category'.tr(),
            style: AppTypography.arabicCaption(fontSize: 12),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: categoryIds.map((catId) {
              final isSelected = _selectedCategory == catId.toString();
              return _buildFilterChip(
                context,
                _categoryLabel(context, catId),
                isSelected,
                () {
                  setState(
                    () => _selectedCategory = isSelected
                        ? null
                        : catId.toString(),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildArticlesFilterSheet(BuildContext context) {
    final categoryIds = widget.cubit.articleCategories.isNotEmpty
        ? widget.cubit.articleCategories
        : widget.cubit.categories.map((c) => c.id).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (categoryIds.isNotEmpty) ...[
          Text(
            'search.filter.category'.tr(),
            style: AppTypography.arabicCaption(fontSize: 12),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: categoryIds.map((catId) {
              final isSelected = _selectedCategory == catId.toString();
              return _buildFilterChip(
                context,
                _categoryLabel(context, catId),
                isSelected,
                () {
                  setState(
                    () => _selectedCategory = isSelected
                        ? null
                        : catId.toString(),
                  );
                },
              );
            }).toList(),
          ),
        ] else ...[
          Text(
            'search.filter.no_filters_article'.tr(),
            style: AppTypography.arabicBody(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildToolsFilterSheet(BuildContext context) {
    final categoryIds = widget.cubit.toolCategories.isNotEmpty
        ? widget.cubit.toolCategories
        : widget.cubit.categories.map((c) => c.id).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'search.filter.availability'.tr(),
          style: AppTypography.arabicCaption(fontSize: 12),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _buildFilterChip(
              context,
              'search.filter.all'.tr(),
              _isAvailable == null,
              () {
                setState(() => _isAvailable = null);
              },
            ),
            _buildFilterChip(
              context,
              'search.filter.available'.tr(),
              _isAvailable == true,
              () {
                setState(() => _isAvailable = true);
              },
            ),
            _buildFilterChip(
              context,
              'search.filter.taken'.tr(),
              _isAvailable == false,
              () {
                setState(() => _isAvailable = false);
              },
            ),
          ],
        ),
        if (categoryIds.isNotEmpty) ...[
          const Divider(),
          Text(
            'search.filter.category'.tr(),
            style: AppTypography.arabicCaption(fontSize: 12),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: categoryIds.map((catId) {
              final isSelected = _selectedCategory == catId.toString();
              return _buildFilterChip(
                context,
                _categoryLabel(context, catId),
                isSelected,
                () {
                  setState(
                    () => _selectedCategory = isSelected
                        ? null
                        : catId.toString(),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.1),
      backgroundColor: theme.colorScheme.surface,
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: AppTypography.arabicBody(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface,
        fontSize: 12,
      ),
    );
  }

  String _categoryLabel(BuildContext context, int catId) {
    for (final category in widget.cubit.categories) {
      if (category.id == catId) {
        return category.nameFor(context.locale.languageCode);
      }
    }
    return '$catId';
  }
}
