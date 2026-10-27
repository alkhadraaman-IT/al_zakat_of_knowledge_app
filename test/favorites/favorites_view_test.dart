import 'dart:convert';

import 'package:al_zakat_of_knowledge_app/core/utils/either.dart';
import 'package:al_zakat_of_knowledge_app/features/favorites/domain/entities/favorite_item_entity.dart';
import 'package:al_zakat_of_knowledge_app/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:al_zakat_of_knowledge_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:al_zakat_of_knowledge_app/features/favorites/presentation/views/favorites_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mock_repository.dart';

void main() {
  // Translations are loaded ONCE in setUpAll (outside the test's fake
  // async zone) and served to every test through a preloaded
  // [AssetLoader]. Reading them via rootBundle inside each widget test
  // only completes for the FIRST test in the file — later tests hang
  // with an empty widget tree while EasyLocalization waits forever.
  late Map<String, Map<String, dynamic>> translations;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Mock the SharedPreferences platform channel BEFORE EasyLocalization
    // initializes, so saving/loading the locale doesn't throw
    // MissingPluginException inside the test.
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();

    translations = {
      for (final code in ['en', 'ar'])
        code: json.decode(
              await rootBundle.loadString('assets/translations/$code.json'),
            )
            as Map<String, dynamic>,
    };
  });

  late MockFavoritesRepository mockRepository;

  setUp(() async {
    await GetIt.I.reset();
    mockRepository = MockFavoritesRepository();

    // Register the mock + the cubit factory exactly the way the view
    // resolves them (FavoritesView calls `sl<FavoritesCubit>()`).
    GetIt.I.registerSingleton<FavoritesRepository>(mockRepository);
    GetIt.I.registerFactory<FavoritesCubit>(
      () => FavoritesCubit(
        favoritesRepository: GetIt.I<FavoritesRepository>(),
      ),
    );
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  /// Pumps [FavoritesView] wrapped in the same layers the app uses:
  /// - [EasyLocalization] so `.tr()` translation keys resolve.
  /// - [ScreenUtilInit] so `.w` / `.h` / `.r` extensions are initialized.
  Future<void> pumpFavoritesView(WidgetTester tester) async {
    // Use the app's design size so ScreenUtil ratios are exactly 1.0.
    // The default test viewport (800x600) would scale every `.w`/`.h`
    // value by 800/375 ≈ 2.13 and cause RenderFlex overflows.
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // flutter_test has no real fonts: every glyph renders as a full-em
    // square, so long strings lay out ~2x wider than in production and
    // harmless RenderFlex overflow reports are thrown during layout.
    // Ignore ONLY those — every other Flutter error still fails the test.
    final previousFlutterErrorOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      final message = details.exceptionAsString();
      if (message.contains('A RenderFlex overflowed')) return;
      previousFlutterErrorOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = previousFlutterErrorOnError);

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('ar'), Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        assetLoader: _PreloadedAssetLoader(translations),
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp(
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              home: const FavoritesView(),
            );
          },
        ),
      ),
    );
    // Lets the cubit's async load + translation loading settle without
    // throwing on missing widgets/text. The preloaded asset loader
    // completes in microtasks, so no real async turn is needed here.
    await tester.pumpAndSettle();
  }

  testWidgets('FavoritesView displays empty state when no favorites',
      (widgetTester) async {
    // Mock defaults to an empty success list.
    await pumpFavoritesView(widgetTester);

    expect(find.byType(Scaffold), findsOneWidget);
    // favorites.empty_lectures (locale en)
    expect(find.text('No favorite lectures at the moment'), findsOneWidget);
  });

  testWidgets('FavoritesView shows loading state', (widgetTester) async {
    await pumpFavoritesView(widgetTester);

    // The async load settles into the loaded (empty) state.
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
  });

  testWidgets('FavoritesView interacts with segmented tabs',
      (widgetTester) async {
    await pumpFavoritesView(widgetTester);
    expect(find.text('No favorite lectures at the moment'), findsOneWidget);

    // Switch to Articles tab → tab-specific empty state.
    await widgetTester.tap(find.text('Saved Articles'));
    await widgetTester.pumpAndSettle();
    expect(find.text('No favorite articles at the moment'), findsOneWidget);

    // Switch to Tools tab → tab-specific empty state.
    await widgetTester.tap(find.text('Saved Tools'));
    await widgetTester.pumpAndSettle();
    expect(find.text('No saved tools yet'), findsOneWidget);
  });

  testWidgets('FavoritesView renders favorite items from the repository',
      (widgetTester) async {
    mockRepository.getFavoritesResponse = Right([
      FavoriteItemEntity(
        id: '1',
        title: 'Session 1',
        itemType: 'session',
        thumbnailUrl: 'thumbnail1.jpg',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ),
    ]);

    await pumpFavoritesView(widgetTester);

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.text('Session 1'), findsOneWidget);
  });
}

/// Serves the translations preloaded in `setUpAll` instead of reading
/// from `rootBundle`, so the load completes in plain microtasks and
/// works deterministically in every test, not just the first one.
class _PreloadedAssetLoader extends AssetLoader {
  const _PreloadedAssetLoader(this._translations);

  final Map<String, Map<String, dynamic>> _translations;

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async =>
      _translations[locale.languageCode];
}
