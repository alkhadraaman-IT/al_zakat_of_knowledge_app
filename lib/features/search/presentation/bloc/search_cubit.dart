import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../articles/domain/entities/article_entity.dart';
import '../../../articles/domain/entities/category_entity.dart';
import '../../../articles/domain/usecases/get_articles_usecase.dart';
import '../../../articles/domain/usecases/get_categories_usecase.dart';
import '../../../sessions/domain/entities/session_entity.dart';
import '../../../sessions/domain/usecases/get_sessions_usecase.dart';
import '../../../study_tools/domain/entities/study_tool_entity.dart';
import '../../../study_tools/domain/usecases/get_study_tools_usecase.dart';
import '../../presentation/bloc/search_state.dart';

/// Cubit powering the Search screen — fetches the
/// published sessions, articles and study tools once,
/// then filters them in-memory for the query,
/// selected tab, and applied advanced filters.
class SearchCubit extends Cubit<SearchState> {
  final GetSessionsUseCase _getSessionsUseCase;
  final GetArticlesUseCase _getArticlesUseCase;
  final GetStudyToolsUseCase _getStudyToolsUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;

  SearchCubit({
    required GetSessionsUseCase getSessionsUseCase,
    required GetArticlesUseCase getArticlesUseCase,
    required GetStudyToolsUseCase getStudyToolsUseCase,
    required GetCategoriesUseCase getCategoriesUseCase,
  })  : _getSessionsUseCase = getSessionsUseCase,
        _getArticlesUseCase = getArticlesUseCase,
        _getStudyToolsUseCase = getStudyToolsUseCase,
        _getCategoriesUseCase = getCategoriesUseCase,
        super(const SearchInitial());

  List<SessionEntity> _allSessions = const [];
  List<ArticleEntity> _allArticles = const [];
  List<StudyToolEntity> _allTools = const [];

  // Expose lists for dynamic UI filters
  List<SessionEntity> get allSessions => _allSessions;
  List<ArticleEntity> get allArticles => _allArticles;
  List<StudyToolEntity> get allTools => _allTools;

  String _query = '';
  int _selectedTab = 0;

  // Advanced filtering parameters
  String? _category;
  String? _location;
  bool? _isAvailable;
  DateTime? _selectedDate;

  bool _loaded = false;
  bool _loading = false;

  // Dynamic categories extracted from database (categoryId values)
  List<int> _sessionCategories = [];
  List<int> _articleCategories = [];
  List<int> _toolCategories = [];

  // Full category taxonomy (`categories` table rows) — used by the
  // UI to resolve localized names (nameAr / nameEn) from categoryId.
  List<CategoryEntity> _categories = const [];

  // Exposed getters for UI layer access
  int get selectedTab => _selectedTab;
  String? get category => _category;
  String? get location => _location;
  bool? get isAvailable => _isAvailable;
  DateTime? get selectedDate => _selectedDate;

  // Dynamic category getters for UI
  List<int> get sessionCategories => _sessionCategories;
  List<int> get articleCategories => _articleCategories;
  List<int> get toolCategories => _toolCategories;
  List<CategoryEntity> get categories => _categories;

  String _norm(String value) => value.trim().toLowerCase();

  /// Extracts unique category IDs from a list of entities.
  /// Returns a sorted list of distinct categoryId values.
  List<int> _extractCategories<T>(List<T> entities, int Function(T) getCategoryId) {
    print('<<<<<<<<<<<[SearchCubit._extractCategories]>>>>>>>>>>>>>');
    final Set<int> categories = {};
    for (final entity in entities) {
      final catId = getCategoryId(entity);
      if (catId > 0) {
        categories.add(catId);
      }
    }
    final sorted = categories.toList()..sort();
    print('Extracted ${sorted.length} categories: $sorted');
    return sorted;
  }

  /// Built-in taxonomy fallback (mirrors the seeded `categories` rows) —
  /// used only when the `categories` table cannot be read.
  List<CategoryEntity> _fallbackCategories() {
    return const [
      CategoryEntity(
        id: 1,
        nameAr: 'علوم شريعة',
        nameEn: 'Islamic Sciences',
        sortOrder: 1,
      ),
      CategoryEntity(
        id: 2,
        nameAr: 'طب',
        nameEn: 'Medicine',
        sortOrder: 2,
      ),
      CategoryEntity(
        id: 3,
        nameAr: 'برمجة',
        nameEn: 'Programming',
        sortOrder: 3,
      ),
      CategoryEntity(
        id: 4,
        nameAr: 'تجارة',
        nameEn: 'Commerce',
        sortOrder: 4,
      ),
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

  /// Loads every published content type once.
  Future<void> load() async {
    print('<<<<<<<<<<<[SearchCubit.load]>>>>>>>>>>>>>');
    if (_loading) return;
    _loading = true;
    emit(const SearchLoading());

    try {
      // Load the category taxonomy first — a failure here must not
      // block the search results, so it falls back to the seeded rows.
      final categoriesResult = await _getCategoriesUseCase();
      categoriesResult.fold(
        (f) {
          // Keep search working with the built-in taxonomy.
          _categories = _fallbackCategories();
        },
        (v) {
          _categories = v.isEmpty ? _fallbackCategories() : v;
        },
      );

      // Load sessions
      final sessionsResult = await _getSessionsUseCase();
      Failure? failure;
      sessionsResult.fold(
        (f) => {
          failure = f,
          _loading = false,
          emit(SearchError(message: failure!.message, code: failure!.code)),
        },
        (v) => {
          _allSessions = v,
          _sessionCategories = _extractCategories(v, (s) => s.categoryId),
        },
      );
      if (failure != null) return;

      // Load articles
      final articlesResult = await _getArticlesUseCase();
      failure = null;
      articlesResult.fold(
        (f) => {
          failure = f,
          _loading = false,
          emit(SearchError(message: failure!.message, code: failure!.code)),
        },
        (v) => {
          _allArticles = v,
          _articleCategories = _extractCategories(v, (a) => a.categoryId),
        },
      );
      if (failure != null) return;

      // Load tools
      final toolsResult = await _getStudyToolsUseCase();
      failure = null;
      toolsResult.fold(
        (f) => {
          failure = f,
          _loading = false,
          emit(SearchError(message: failure!.message, code: failure!.code)),
        },
        (v) => {
          _allTools = v,
          _toolCategories = _extractCategories(v, (t) => t.categoryId),
        },
      );
      if (failure != null) return;

      _loaded = true;
      _loading = false;
      print('<<<<<<<<<<<[SearchCubit.load success]>>>>>>>>>>>>>');
      print('sessions=${_allSessions.length} articles=${_allArticles.length} tools=${_allTools.length}');
      _emitFiltered();
    } catch (e) {
      print('<<<<<<<<<<<[SearchCubit.load exception]>>>>>>>>>>>>>');
      print('Exception: $e');
      _loading = false;
      emit(const SearchError(message: 'search.error_loading', code: null));
    }
  }

  void setQuery(String query) {
    print('<<<<<<<<<<<[SearchCubit.setQuery]>>>>>>>>>>>>>');
    _query = query;
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      emit(const SearchInitial());
      return;
    }
    if (!_loaded && !_loading) {
      load();
    } else {
      _emitFiltered();
    }
  }

  void setTab(int index) {
    print('<<<<<<<<<<<[SearchCubit.setTab]>>>>>>>>>>>>>');
    _selectedTab = index;
    if (_loaded) {
      _emitFiltered();
    }
  }

  Future<void> retry() async {
    print('<<<<<<<<<<<[SearchCubit.retry]>>>>>>>>>>>>>');
    _loaded = false;
    await load();
  }

  /// Applies advanced filters and re-emits the filtered results.
  void applyFilters({
    String? category,
    DateTime? selectedDate,
    String? location,
    bool? isAvailable,
  }) {
    print('<<<<<<<<<<<[SearchCubit.applyFilters]>>>>>>>>>>>>>');
    _category = category;
    _selectedDate = selectedDate;
    _location = location;
    _isAvailable = isAvailable;
    _emitFiltered();
  }

  /// Clears all advanced filters and re-emits the results.
  void clearFilters() {
    print('<<<<<<<<<<<[SearchCubit.clearFilters]>>>>>>>>>>>>>');
    _category = null;
    _selectedDate = null;
    _location = null;
    _isAvailable = null;
    _emitFiltered();
  }

  void _emitFiltered() {
    print('<<<<<<<<<<<[SearchCubit._emitFiltered]>>>>>>>>>>>>>');
    final q = _norm(_query);
    final int? categoryFilter = _category != null ? int.tryParse(_category!) : null;

    // --- Sessions (tab 0) filtering ---
    final sessions = _allSessions.where((session) {
      final matchesQuery = q.isEmpty ||
          _norm(session.title).contains(q) ||
          _norm(session.lecturerName).contains(q) ||
          _norm(session.city).contains(q) ||
          _norm(session.placeName).contains(q) ||
          _norm(session.description).contains(q);

      // Category filter (categoryId is an int)
      final matchesCategory = categoryFilter == null || session.categoryId == categoryFilter;

      // Date filter
      bool matchesDate = true;
      if (_selectedDate != null && session.startsAt.isNotEmpty) {
        final sessionDate = DateTime.tryParse(session.startsAt);
        if (sessionDate != null) {
          matchesDate = sessionDate.year == _selectedDate!.year &&
              sessionDate.month == _selectedDate!.month &&
              sessionDate.day == _selectedDate!.day;
        }
      }

      // Location filter
      final matchesLocation = _location == null ||
          _norm(session.city).contains(_norm(_location!)) ||
          _norm(session.placeName).contains(_norm(_location!));

      return matchesQuery && matchesCategory && matchesDate && matchesLocation;
    }).toList(growable: false);

    // --- Articles (tab 1) filtering ---
    final articles = _allArticles.where((article) {
      final matchesQuery = q.isEmpty ||
          _norm(article.title).contains(q) ||
          _norm(article.body).contains(q);

      // Category filter (categoryId is an int)
      final matchesCategory = categoryFilter == null || article.categoryId == categoryFilter;

      return matchesQuery && matchesCategory;
    }).toList(growable: false);

    // --- Study Tools (tab 2) filtering ---
    final toolsFinal = _allTools.where((tool) {
      final matchesQuery = q.isEmpty ||
          _norm(tool.title).contains(q) ||
          _norm(tool.subject).contains(q) ||
          _norm(tool.university).contains(q) ||
          _norm(tool.city).contains(q) ||
          _norm(tool.pickupPlace).contains(q) ||
          _norm(tool.pickupNotes).contains(q);

      // Availability filter
      final matchesAvailability = _isAvailable == null || tool.isTaken == _isAvailable;

      // Category filter (categoryId is an int)
      final matchesCategory = categoryFilter == null || tool.categoryId == categoryFilter;

      return matchesQuery && matchesAvailability && matchesCategory;
    }).toList(growable: false);

    emit(
      SearchLoaded(
        query: _query,
        selectedTab: _selectedTab,
        sessions: sessions,
        articles: articles,
        tools: toolsFinal,
      ),
    );
  }
}
