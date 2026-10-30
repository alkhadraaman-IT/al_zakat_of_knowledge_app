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
import 'search_state.dart';

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

  String _query = '';
  int _selectedTab = 0;

  String? _category;
  String? _location;
  bool? _isAvailable;
  DateTime? _selectedDate;

  bool _loaded = false;
  bool _loading = false;

  List<int> _sessionCategories = [];
  List<int> _articleCategories = [];
  List<int> _toolCategories = [];
  List<CategoryEntity> _categories = const [];

  // ── Getters للـ UI ─────────────────────────────
  List<SessionEntity> get allSessions => _allSessions;
  List<ArticleEntity> get allArticles => _allArticles;
  List<StudyToolEntity> get allTools => _allTools;

  int get selectedTab => _selectedTab;
  String? get category => _category;
  String? get location => _location;
  bool? get isAvailable => _isAvailable;
  DateTime? get selectedDate => _selectedDate;

  List<int> get sessionCategories => _sessionCategories;
  List<int> get articleCategories => _articleCategories;
  List<int> get toolCategories => _toolCategories;
  List<CategoryEntity> get categories => _categories;

  String _norm(String v) => v.trim().toLowerCase();

  // ── التحميل ─────────────────────────────────────
  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    emit(const SearchLoading());

    try {
      await _loadCategories();

      final sessionsFailure = await _loadSessions();
      if (sessionsFailure != null) return _emitLoadError(sessionsFailure);

      final articlesFailure = await _loadArticles();
      if (articlesFailure != null) return _emitLoadError(articlesFailure);

      final toolsFailure = await _loadTools();
      if (toolsFailure != null) return _emitLoadError(toolsFailure);

      _loaded = true;
      _loading = false;
      _emitFiltered();
    } catch (_) {
      _loading = false;
      emit(const SearchError(message: 'search.error_loading', code: null));
    }
  }

  Future<void> _loadCategories() async {
    final result = await _getCategoriesUseCase();
    result.fold(
      (_) => _categories = _fallbackCategories(),
      (v) => _categories = v.isEmpty ? _fallbackCategories() : v,
    );
  }

  Future<Failure?> _loadSessions() async {
    final result = await _getSessionsUseCase();
    Failure? failure;
    result.fold(
      (f) => failure = f,
      (v) {
        _allSessions = v;
        _sessionCategories = _extractCategories(v, (s) => s.categoryId);
      },
    );
    return failure;
  }

  Future<Failure?> _loadArticles() async {
    final result = await _getArticlesUseCase();
    Failure? failure;
    result.fold(
      (f) => failure = f,
      (v) {
        _allArticles = v;
        _articleCategories = _extractCategories(v, (a) => a.categoryId);
      },
    );
    return failure;
  }

  Future<Failure?> _loadTools() async {
    final result = await _getStudyToolsUseCase();
    Failure? failure;
    result.fold(
      (f) => failure = f,
      (v) {
        _allTools = v;
        _toolCategories = _extractCategories(v, (t) => t.categoryId);
      },
    );
    return failure;
  }

  void _emitLoadError(Failure failure) {
    _loading = false;
    emit(SearchError(message: failure.message, code: failure.code));
  }

  // ── إدخال المستخدم ─────────────────────────────
  void setQuery(String query) {
    _query = query;
    if (_loaded) {
      // ✅ عند المسح: يُظهر كل العناصر بدلاً من شاشة فارغة
      _emitFiltered();
    } else if (query.trim().isNotEmpty) {
      load();
    }
  }

  void setTab(int index) {
    _selectedTab = index;
    if (_loaded) _emitFiltered();
  }

  Future<void> retry() async {
    _loaded = false;
    await load();
  }

  void applyFilters({
    String? category,
    DateTime? selectedDate,
    String? location,
    bool? isAvailable,
  }) {
    _category = category;
    _selectedDate = selectedDate;
    _location = location;
    _isAvailable = isAvailable;
    _emitFiltered();
  }

  void clearFilters() {
    _category = null;
    _selectedDate = null;
    _location = null;
    _isAvailable = null;
    _emitFiltered();
  }

  /// تُستدعى من SearchView عند تغيّر ArticleCubit أو StudyToolCubit.
  void refreshLists({
    List<ArticleEntity>? articles,
    List<StudyToolEntity>? tools,
  }) {
    if (articles != null) {
      _allArticles = articles;
      _articleCategories = _extractCategories(articles, (a) => a.categoryId);
    }
    if (tools != null) {
      _allTools = tools;
      _toolCategories = _extractCategories(tools, (t) => t.categoryId);
    }
    if (_loaded) _emitFiltered();
  }

  // ── الفلترة ─────────────────────────────────────
  void _emitFiltered() {
    final q = _norm(_query);
    final categoryFilter =
        _category != null ? int.tryParse(_category!) : null;

    emit(SearchLoaded(
      query: _query,
      selectedTab: _selectedTab,
      sessions: _filterSessions(q, categoryFilter),
      articles: _filterArticles(q, categoryFilter),
      tools: _filterTools(q, categoryFilter),
    ));
  }

  List<SessionEntity> _filterSessions(String q, int? categoryFilter) {
    return _allSessions.where((s) {
      final matchesQuery = q.isEmpty ||
          _norm(s.title).contains(q) ||
          _norm(s.lecturerName).contains(q) ||
          _norm(s.city).contains(q) ||
          _norm(s.placeName).contains(q) ||
          _norm(s.description).contains(q);
      final matchesCategory =
          categoryFilter == null || s.categoryId == categoryFilter;

      bool matchesDate = true;
      if (_selectedDate != null && s.startsAt.isNotEmpty) {
        final d = DateTime.tryParse(s.startsAt);
        if (d != null) {
          matchesDate = d.year == _selectedDate!.year &&
              d.month == _selectedDate!.month &&
              d.day == _selectedDate!.day;
        }
      }

      final matchesLocation = _location == null ||
          _norm(s.city).contains(_norm(_location!)) ||
          _norm(s.placeName).contains(_norm(_location!));

      return matchesQuery &&
          matchesCategory &&
          matchesDate &&
          matchesLocation;
    }).toList(growable: false);
  }

  List<ArticleEntity> _filterArticles(String q, int? categoryFilter) {
    return _allArticles.where((a) {
      final matchesQuery = q.isEmpty ||
          _norm(a.title).contains(q) ||
          _norm(a.body).contains(q);
      final matchesCategory =
          categoryFilter == null || a.categoryId == categoryFilter;
      return matchesQuery && matchesCategory;
    }).toList(growable: false);
  }

  List<StudyToolEntity> _filterTools(String q, int? categoryFilter) {
    return _allTools.where((t) {
      final matchesQuery = q.isEmpty ||
          _norm(t.title).contains(q) ||
          _norm(t.subject).contains(q) ||
          _norm(t.university).contains(q) ||
          _norm(t.city).contains(q) ||
          _norm(t.pickupPlace).contains(q) ||
          _norm(t.pickupNotes).contains(q);
      final matchesAvailability =
    _isAvailable == null || t.isTaken != _isAvailable;
      final matchesCategory =
          categoryFilter == null || t.categoryId == categoryFilter;
      return matchesQuery && matchesAvailability && matchesCategory;
    }).toList(growable: false);
  }

  // ── مساعدات ─────────────────────────────────────
  List<int> _extractCategories<T>(
    List<T> entities,
    int Function(T) getCategoryId,
  ) {
    final Set<int> ids = {};
    for (final e in entities) {
      final id = getCategoryId(e);
      if (id > 0) ids.add(id);
    }
    return ids.toList()..sort();
  }

  List<CategoryEntity> _fallbackCategories() => const [
        CategoryEntity(
          id: 1, nameAr: 'علوم شريعة', nameEn: 'Islamic Sciences', sortOrder: 1),
        CategoryEntity(id: 2, nameAr: 'طب', nameEn: 'Medicine', sortOrder: 2),
        CategoryEntity(
          id: 3, nameAr: 'برمجة', nameEn: 'Programming', sortOrder: 3),
        CategoryEntity(id: 4, nameAr: 'تجارة', nameEn: 'Commerce', sortOrder: 4),
        CategoryEntity(
          id: 5, nameAr: 'تطوير ذاتي', nameEn: 'Self Development', sortOrder: 5),
        CategoryEntity(id: 6, nameAr: 'أكاديمي', nameEn: 'Academic', sortOrder: 6),
      ];
}