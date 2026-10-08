# Model Specifications for the "Zakat Al-Ilm" App (Flutter + Supabase)

> For the developer: This file describes the Supabase tables as created by the `zakat_al_ilm_supabase.sql` script. Adhere to it strictly.
> Architecture: Clean Architecture + BLoC. For each table: an `Entity` in the Domain layer, and a `Model extends Entity` in the Data layer (including `fromJson` and `toJson`).

## First: The Concept in a Nutshell

**The App:** A free volunteer-based platform for university and institute students, featuring three main elements:
1. **Sessions (In-person lectures):** A user posts a session (title, map location, time, number of seats), and others can book a seat.
2. **Free Study Materials:** A user posts that they possess lecture materials for a specific subject at a specific location; the recipient simply clicks "Taken" (without direct contact, to preserve dignity).
3. **Articles:** Useful texts that serve as ongoing charity (*Sadaqah Jariyah*).

**Intended Design Principles (Do not deviate):**
- Single account per user: The same account is used for both attending and posting (no separate roles).
- No ratings, star systems, view counts, or "likes." The app is inspired by the principle of "letting not the left hand know what the right hand gives"; we do not highlight the volunteer's individual impact.
- Sessions are published immediately without prior review. Safeguards include verified profiles (LinkedIn/GitHub/CV), a "New" badge, a report button, and human moderation.

## Second: Understanding the Database

The database consists of **tables** resembling Excel spreadsheets. Each **row** represents a single entity (a user, a session, etc.), and each **column** represents a specific piece of information about that entity. The tables are linked via `id` numbers.

Example: The `sessions` table contains a `publisher_id` column, the value of which corresponds to the session owner's `id` in the `profiles` table. This allows us to identify "whose session it is" without duplicating their personal data.

**The fourteen tables organized into four groups:**
- **People:** `profiles` (users), `user_devices` (devices used for notifications).
- **Sessions:** `sessions`, `bookings`, `favorites`.
- **Content:** `materials`, `articles`, `categories`, `category_follows` (categories followed by the user).
- **Services & Administration:** `notifications`, `reports`, `blocks`, `app_config` (settings), `material_status_log` (internal admin log; no associated Model).

**Session Lifecycle:** Sarah publishes a session (a row is created in `sessions` with `publisher_id` set to Sarah's ID). Ahmed books it (a row is created in `bookings` containing the session ID and Ahmed's ID, and `booked_count` is incremented). If he cancels more than 24 hours in advance, the booking status changes to `cancelled`, and the spot becomes available again.

## Third: Data Protection (Important for you as a developer)

The application runs on the user's phone, meaning anyone could potentially send requests directly to the database. Therefore, **security is implemented within the database itself, not in Flutter**, across three layers:
1. **RLS (Row-Level Security):** Determines who can view or modify each row (e.g., a user can only see their own bookings and cannot modify someone else's session). 2. **Column Permissions:** Columns locked against direct app access (`booked_count`, `is_taken`, `is_admin`, etc.). Do not send them.
3. **RPC Functions:** Multi-step operations executed as a single, secure unit. There are only three: booking a seat, cancelling a booking, and toggling the "taken" status.

**Practical Implications for You:**
- Publishing, editing, adding articles, and writing reports: Use standard queries (`from(...).insert/update`).
- Booking, cancelling, and toggling "taken" status: **RPC only**.
- Send only the permitted fields (listed for each model below); otherwise, the server will reject the request.
- Upon rejection, the server returns an **error code** (see the code table at the end of the file); translate this into a user-friendly message.

## IV. Server-Side Automation (No coding required)

- Creating a `profiles` row upon new user registration (via email or Google).
- Adding entries to `notifications` when a session is cancelled or its time/location is modified (notifying all booked participants), and when a resource is "taken" (notifying the owner).
- Filtering out content from blocked users in query results.
- Capacity protection: Bookings are rejected once seats are full, even with simultaneous requests.

## V. App-Side Implementation

- **"Dua" (Supplication) Notification:** "May Allah bless your knowledge and benefit us through it." This is a **local** notification scheduled on the lecturer's device to trigger at the session's end time (`startsAt + durationMinutes`). It must be rescheduled or cancelled if the session is modified or cancelled. - For the article/content publisher: An immediate local notification upon publication.
- **Pre-session reminder** for attendees: Also a local notification.
- **Push Notifications (FCM)** for session cancellation, modification, and content retrieval: Requires an Edge Function later on; for now, simply displaying the `notifications` list within the app suffices.
- **Deferred to the end:** Category following feature (database table is ready, but logic and UI are pending) and article images (button disabled while `images_enabled = false`).

---

## VI. General Data Model Rules

- Database column names use `snake_case`, while Dart uses `camelCase`. Convert during `fromJson`/`toJson`.
- `uuid` and `text` → `String`; `int` → `int`; `float8` → `double`; `boolean` → `bool`.
- `timestamptz` → `DateTime` via `DateTime.parse(...)`, followed by `.toLocal()` for display.
- `jsonb` → `Map<String, dynamic>?`.
- A column without a ✱ indicates it accepts `null` → Dart type with a `?` suffix.
- **Do not send read-only fields** (e.g., `id`, `created_at`, counters, protected statuses). Each Model must have `toInsertJson()` and `toUpdateJson()` methods containing only the permitted fields (specified for each table). The server will reject requests containing other fields.
- There is no ratings table in the app (an intentional design decision).
- Client key: Use only the `anon/publishable key`. Never use the `service_role` key within the app.
- Statuses are stored as text strings in the database. I define it as an `enum` in Dart with a `fromString` method.

## 1) ProfileModel ← `profiles`

| Dart | Column | Type |
|---|---|---|
| id | id | String |
| name | name | String |
| photoUrl | photo_url | String? |
| linkedinUrl | linkedin_url | String? |
| githubUrl | github_url | String? |
| cvPdfUrl | cv_pdf_url | String? |
| university | university | String? |
| city | city | String? |
| isAdmin