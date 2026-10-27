# ZAKAT AL-ILM (زكاة العلم) — UI & Architecture Code Generation Rules

## Purpose
This document defines the strict coding standards and rules that any AI coding agent (e.g., OpenCode AI, Claude, Cursor) MUST follow when generating Flutter code for the "زكاة العلم" (Zakat Al-Ilm) mobile application.

This document acts as a binding Coding Contract. The AI must treat these rules as absolute constraints.

---

## 1. Core Principles & App Philosophy
* **Application Nature:** "زكاة العلم" is a non-commercial, community-driven academic platform for university students focused on:
  * In-Person Peer Lectures & Study Sessions.
  * Free Physical Study Material & Book Exchange (Dignified exchange without direct messaging/chat).
  * Continuous Charitable Knowledge Articles ("صدقة جارية").
* **Design & Assets Reference:** 
  * Treat Google Stitch designs as the primary visual source of truth.
  * Use the project logo located in the `images/` directory across the app (Splash, Auth, Headers, etc.).
  * Ensure `easy_localization` and theme settings are strictly enforced globally across the entire application.
* **Production Readiness:** Write modular, sound-null-safe, highly maintainable Flutter code adhering to Clean Architecture standards.

---

## 2. Mandatory Tech Stack & Package Matrix
The AI MUST utilize the following package stack and NO alternative implementations:

| Domain / Responsibility | Mandatory Package / Technology |
| :--- | :--- |
| Framework & UI Standard | Flutter / Dart / Material 3 |
| State Management | `flutter_bloc` (**Cubit pattern ONLY** — no BLoC events) |
| Dependency Injection | `get_it` + `injectable` |
| Backend & Auth | Supabase (`supabase_flutter`) |
| Firebase Services | Firebase Auth (Google Sign-In) & Push Notifications (FCM) |
| Localization & RTL | `easy_localization` |
| Responsive Layout | `flutter_screenutil` |
| Offline Storage & Cache | `shared_preferences` + `hive_ce`, `hive_ce_flutter`, `hive_ce_generator` |
| Toast & Alerts | `fluttertoast` |
| Routing & Deep Links | `go_router` + `url_launcher` + `qr_flutter` |
| Code Generation | `build_runner` + `injectable_generator` |

---

## 3. Strict Architecture Rules (Clean Architecture & Core)

### 3.1 Folder Structure & Core Layers
Every feature must strictly adhere to the following directory and clean architecture structure (matching the architectural pattern of `albarkah_flutter_course_female_2026`, adapted for **Cubit**):

```text
lib/
├── app/
│   ├── app.dart
│   ├── router/
│   └── theme/
├── core/
│   ├── constants/       # App constants, box names, API endpoints
│   ├── errors/          # Failure classes, Exceptions mapping
│   ├── extensions/      # ScreenUtil, context, string extensions
│   ├── network/         # Network info, internet connection checker
│   ├── utils/           # Either type, formatters, helpers
│   └── widgets/         # Shared global app widgets (buttons, text fields, custom containers)
├── features/
│   ├── auth/
│   │   ├── data/        # models (with toMap/fromMap), datasources, repositories_impl
│   │   ├── domain/      # entities, repositories (abstract), usecases
│   │   └── presentation/# cubit, states, views, widgets
│   ├── onboarding/
│   ├── lectures/
│   ├── materials/
│   ├── favorites/
│   ├── reports/
│   └── profile/
└── main.dart
3.2 Detailed Data Flow & Responsibilities
Presentation Layer (Views & Cubits):

Views MUST NOT contain any business logic, state mutations, or direct database/network calls.

Views trigger Cubit actions. Cubits emit States (Initial, Loading, Loaded, Error).

Domain Layer (Pure Dart):

Contains pure Entities, abstract Repositories, and UseCases.

Each business operation has a dedicated UseCase.

Data Layer (Implementation):

Contains Models implementing fromMap(Map<String, dynamic> map) and toMap() (Strictly avoid fromJson / toJson).

Contains DataSources (Supabase, Firebase, Hive local boxes).

Contains Repositories Impl returning Either<Failure, Entity>.

4. Specific Implementation Rules
4.1 Favorites Feature Storage via hive_ce
The favorites system must be handled offline-first using hive_ce and hive_ce_flutter.

Data items must be stored as Hive-annotated models (e.g., FavoriteItemModel with @HiveType and @HiveField) containing item id, title, itemType, thumbnailUrl, and timestamp.

The Cubit must watch or fetch local favorites via the Hive box wrapper (FavoritesLocalDataSourceImpl) injected through GetIt.

4.2 Data Mapping Convention
Mandatory: Always use fromMap(Map<String, dynamic> map) and toMap() for data conversions in models and entities. Do not use fromJson or toJson.

4.3 Code Quality & Guardrails
No Quick Fixes: Do not use lazy shortcuts like random setState or bypassing architecture layers unless it is technically mandated by Flutter framework specifications.

Pre-Execution Plan: For any new feature or major refactor, provide a clear step-by-step plan and wait for user approval before writing code.

5. Design, Typography, Localization & Assets
Fonts: Use "Thmanyah Font" for Arabic UI text and "IBM Plex Mono" for numbers, IDs, and timestamps.

Responsiveness: Minimum horizontal padding 20.w. Use .w, .h, .sp, .r extensions everywhere.

Localization: All user-facing strings must use easy_localization (.tr()). Avoid hardcoded text.

Logo: Use the designated logo asset inside the images/ folder across the app structure.