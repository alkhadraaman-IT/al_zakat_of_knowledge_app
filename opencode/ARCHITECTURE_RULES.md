# ZAKAT AL-ILM (زكاة العلم) — UI & Architecture Code Generation Rules

## Purpose
This document defines the strict coding standards and rules that any AI coding agent (e.g., OpenCode AI, Claude, Cursor) MUST follow when generating Flutter code for the "زكاة العلم" (Zakat Al-Ilm) mobile application from Google Stitch designs.

This document acts as a binding Coding Contract. The AI must treat these rules as absolute constraints.

---

## 1. Core Principles & App Philosophy
* **Application Nature:** "زكاة العلم" is a non-commercial, community-driven academic platform for university students focused on:
  * In-Person Peer Lectures & Study Sessions.
  * Free Physical Study Material & Book Exchange (Dignified exchange without direct messaging/chat).
  * Continuous Charitable Knowledge Articles ("صدقة جارية").
* **Design Reference:** Treat Google Stitch designs as the primary visual source of truth.
* **No Unnecessary Packages:** Do not add third-party packages unless specified in this document or explicitly requested.
* **Production Readiness:** Write modular, sound-null-safe, highly maintainable Flutter code adhering to Material 3 standards.

---

## 2. Mandatory Tech Stack & Package Matrix
The AI MUST utilize the following package stack and NO alternative implementations:

| Domain / Responsibility | Mandatory Package / Technology |
| :--- | :--- |
| Framework & UI Standard | Flutter / Dart / Material 3 |
| State Management | `flutter_bloc` (BLoC & Cubit patterns) |
| Dependency Injection | `get_it` + `injectable` |
| Backend & Auth | Supabase (`supabase_flutter`) |
| Localization & RTL | `easy_localization` |
| Responsive Layout | `flutter_screenutil` |
| Offline Storage & Cache | `shared_preferences` + `hive_flutter` |
| Toast & Alerts | `fluttertoast` |
| Page Indicators | `smooth_page_indicator` |
| Network Status | `internet_connection_checker` |
| App Lifecycle / Back Handling | `flutter_exit_app` |
| Splash Screen (Pre-app launch) | `flutter_native_splash` |
| Code Generation | `build_runner` (for Hive, Freezed, Injectable) |

---

## 3. Strict Architecture Rules (Clean Architecture)
All features must follow a strict 3-tier Clean Architecture structure:

```text
lib/
├── app/
│   ├── app.dart
│   ├── router/
│   └── theme/
│       ├── app_colors.dart
│       ├── app_theme.dart
│       └── app_typography.dart
├── core/
│   ├── constants/
│   ├── errors/
│   ├── extensions/
│   ├── network/
│   ├── utils/
│   └── widgets/
│       ├── app_button.dart
│       ├── app_text_field.dart
│       └── custom_glow_container.dart
├── features/
│   ├── auth/
│   │   ├── data/ (models, datasources, repo_impl)
│   │   ├── domain/ (entities, usecases, repo_interfaces)
│   │   └── presentation/ (bloc, views, widgets)
│   ├── onboarding/
│   ├── lectures/
│   ├── materials/
│   └── profile/
└── main.dart
Architectural Constraints
UI Independence: Views (presentation/) MUST NOT contain any business logic or direct API calls.
Data Flow: UI triggers BLoC events $\rightarrow$ BLoC calls Domain UseCases $\rightarrow$ UseCases request Data Repositories $\rightarrow$ Repositories query Supabase / Hive.
Mocking: If backend endpoints are not ready, implement mock repositories implementing the exact domain interfaces. NEVER hardcode API calls in build() methods.
4. Design System, Typography & Styling Rules
4.1 Typography Guidelines
Arabic Font: "Thmanyah Font" (خط ثمانية) MUST be used for all Arabic UI strings.
English / Monospace Font: "IBM Plex Mono" MUST be used for numbers, technical metrics, academic IDs, timestamps, and English text.
Do NOT use arbitrary font sizes. Map all text styles to TextTheme using flutter_screenutil (e.g., 16.sp, 14.sp, 20.sp).
4.2 Spacing & Responsive Padding Rules
Screen Padding: A MANDATORY minimum horizontal padding of 20.w (EdgeInsets.symmetric(horizontal: 20.w)) MUST be applied to all root screen layouts.
Always use flutter_screenutil extensions (.w, .h, .sp, .r) for all width, height, font size, and border radius dimensions.
Never hardcode fixed pixel coordinates (Positioned(left: 142)). Use standard layout widgets (Row, Column, Expanded, Flexible, SizedBox).
4.3 Container Types & Glow System
Type 1 (Interactive Primary Glow): BorderRadius.circular(16.r), 1px primary border (#124E48), soft primary neon box-shadow/glow.
Type 2 (Elevated Card): Clean rounded corners (12.r to 16.r), subtle drop shadow (Color(0x0A000000)).
Type 3 (Tinted Accent Container): Low-opacity tinted background (#124E48 at 10% opacity), solid primary accent border with soft amber/emerald glow.
4.4 Themes & Palette
Primary Emerald/Teal: #00d68f
Secondary Warm Amber: #E5A93C
Light Background: #F8FAFC
Dark Background (Slate): #0F172A
Both Light Theme and Slate Dark Theme MUST be fully supported in app_theme.dart.
5. Localization & RTL Guidelines
Base Language: Arabic (ar) as primary, English (en) as secondary.
Localization Package: MUST use easy_localization.
No Hardcoded Strings: NEVER hardcode user-facing text inside widgets. Use tr('key') or 'key'.tr().
Directionality (RTL/LTR):
Use direction-aware padding: EdgeInsetsDirectional.only(start: 20.w, end: 20.w).
Use direction-aware alignment: AlignmentDirectional.centerStart.
Do NOT use EdgeInsets.only(left: ..., right: ...).
6. Business Logic & Feature Constraints
6.1 Seat Capacity & Interactive Indicators
Do NOT render seat capacity as heavy, clunky numbered boxes.
Render seat capacity using a clean row of seat indicators/chips where available/empty seats feature a subtle pulse or interactive micro-animation to encourage student registration.
6.2 Dignified Book/Note Exchange (No Direct Chat)
No direct messaging/chat system between students.
Physical material exchange status must rely on action buttons: "تم الأخذ / Mark as Taken", dynamic timestamps, and status chips ("متاح", "تم الحجز").
6.3 Continuous Charity Toast Alerts
When a user reads/shares an academic article, trigger a spiritual toast notification using fluttertoast: "بارك الله في علمك".
7. Quality, Performance & Safety Checklist
Before declaring any generated screen complete, the AI MUST verify:
Compilation: Code compiles cleanly with zero syntax or analyzer errors.
No Magic Numbers: All padding and dimensions use AppSpacing constants or ScreenUtil extensions.
Const Usage: Use const constructors wherever allowed by Dart.
Keyboard Avoidance: Wrap form screens in SingleChildScrollView or SafeArea to prevent overflow when keyboard appears.
Screen States: Implement Initial, Loading, Loaded/Success, and Error states using BLoC builders/consumers.
No Fake APIs in UI: All network and data handling MUST pass through GetIt-injected repositories.
8. Source of Truth Hierarchy
When requirements conflict, follow this exact priority order:
Explicit User Prompt Instructions
ARCHITECTURE_RULES.md (This document)
Google Stitch Generated Designs
Standard Flutter / Material 3 Guidelines