# AI Agent Instructions – Movezz Mobile (Flutter)

These instructions help AI Agent generate code that matches the architecture and conventions of the **Movezz Mobile** project.

## 1. Overall Project Goals

- This project is a **Flutter client** for a Django backend (Movezz).
- Authentication uses **Django session cookies** via `CookieRequest` in `import 'package:pbp_django_auth/pbp_django_auth.dart';`.
- The app uses **feature-based architecture** and **Provider + ChangeNotifier** for state management (at least as a baseline).

When generating code, prefer:

- Clean, small, composable widgets.
- Separation between **data layer** and **presentation layer**.
- Reuse of existing utilities and widgets in `lib/core` and `lib/shared`.

---

## 2. Architecture & Folder Structure

### 2.1 Core Layer

- **Global config** lives in:
  - `lib/core/config/app_config.dart`
  - `lib/core/config/env.dart`
- **Routing** lives in:
  - `lib/core/routing/app_router.dart`
- **Theming** lives in:
  - `lib/core/theme/app_theme.dart`
- **Utilities** live in:
  - `lib/core/utils/extensions.dart`
- **Shared UI components** live in:
  - `lib/core/widgets/app_button.dart`
  - `lib/core/widgets/app_text_field.dart`


> Copilot should **reuse** these files when adding behavior (e.g. validation, theming, snackbars, routing), not reinvent them.

### 2.2 Feature Modules

Each feature has this structure:

```text
lib/features/<feature>/
  data/
    models/
    datasources/
    repositories/
  presentation/
    controllers/
    pages/
    widgets/
```

Current features:

- `auth`
- `feeds`
- `profile`
- `broadcast`
- `marketplace`
- `messages`

**Rules for Copilot:**

- When generating **models**, place them under `lib/features/<feature>/data/models/`.
- When generating **remote data sources**, place them under `lib/features/<feature>/data/datasources/`.
- When generating **repositories**, place them under `lib/features/<feature>/data/repositories/`.
- When generating **controllers/state**, place them under `lib/features/<feature>/presentation/controllers/` and extend `ChangeNotifier` unless the file clearly uses another pattern.
- When generating **screens/pages**, place them under `lib/features/<feature>/presentation/pages/`.
- When generating **small UI components** related to a feature, place them under `lib/features/<feature>/presentation/widgets/`.

Avoid mixing data logic (HTTP calls) inside `presentation/pages` or `presentation/widgets`.

---

## 3. Networking & Backend Rules

- Use **`CookieRequest`** (`import 'package:pbp_django_auth/pbp_django_auth.dart';`) for calls to the Django backend.
- Do **not** instantiate `http.Client` directly in feature code unless there is a clear reason.
- Use `Env.api('/path')` from `lib/core/config/env.dart` to build backend URLs.

**Example (desired shape for a datasource):**

```dart
import 'package:movezz_mobile/core/config/env.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class FeedsRemoteDataSource {
  final CookieRequest cookieRequest;

  FeedsRemoteDataSource(this.cookieRequest);

  Future<List<dynamic>> fetchFeeds() async {
    final url = Env.api('/feeds/');
    final response = await cookieRequest.get(url);
    // Map response to models in repository / controller
    return response as List<dynamic>;
  }
}
```

Copilot should:

- Prefer **injecting** `CookieRequest` (via constructor), not creating it inline.
- Not hard-code full URLs like `http://localhost:8000`; always use `Env.backendBaseUrl` or `Env.api()`.

---

## 4. State Management & UI Rules

- Default state management: **ChangeNotifier + Provider**.
- Controllers should:

  - Live in `presentation/controllers`.
  - Hold UI state (loading flags, list data, error messages).
  - Call repositories; repositories call datasources.

**Example controller pattern:**

```dart
class FeedsController extends ChangeNotifier {
  final FeedsRepository repository;

  FeedsController(this.repository);

  bool isLoading = false;
  String? error;
  List<FeedModel> feeds = [];

  Future<void> loadFeeds() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      feeds = await repository.getFeeds();
    } catch (e) {
      error = 'Failed to load feeds';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
```

- UI widgets should:

  - Be as dumb as possible (receive data via constructor or through Provider).
  - Use extensions from `lib/core/utils/extensions.dart` when it makes sense (e.g. `context.showSnackBar()` if defined).

---

## 5. Theming & Design

- Use `AppTheme.light` / `AppTheme.dark` from `lib/core/theme/app_theme.dart`.
- Reuse `AppButton` and `AppTextField` where appropriate instead of raw `ElevatedButton` or `TextFormField` with repeated styling.
- Avoid hardcoding colors and fonts everywhere; prefer theme and shared widgets.

---

## 6. Naming & Style Conventions

- Class names: `PascalCase` (e.g., `FeedsController`, `ProfileModel`).
- File names: `snake_case` (e.g., `feeds_controller.dart`, `profile_model.dart`).
- Repository naming: `<Feature>Repository` in `data/repositories`.
- Datasource naming: `<Feature>RemoteDataSource` in `data/datasources`.
- Controller naming: `<Feature>Controller` in `presentation/controllers`.
- Page naming: `<Feature>Page` in `presentation/pages`.

Copilot should avoid:

- Creating duplicate pages with slightly different names (`feed_page.dart` vs `feeds_page.dart`) unless clearly intentional.
- Generating UI code that directly calls HTTP endpoints.

---

## 7. Things Copilot Should Not Do

- Do **not** modify `main.dart`, `app_theme.dart`, or `env.dart` unless the user explicitly edits those files.
- Do **not** introduce new state management libraries (Bloc, Riverpod, etc.) unless the file clearly indicates their use or the user types them explicitly.
- Do **not** generate business logic inside test files.
- Do **not** commit credentials, secrets, or environment-specific URLs.

---

## 8. Test & Null Safety

- All generated Dart code must be **null-safe**.
- When handling network responses, Copilot should:

  - Handle possible `null` or malformed data gracefully.
  - Prefer typed models over `dynamic` where possible.

If in doubt, generate smaller, testable, and composable pieces of code rather than large monolithic widgets or functions.


# Ruler Instructions – Movezz Mobile (Flutter)

These rules guide when generating or modifying code in the **Movezz Mobile** Flutter project.

---

## 1. Project Structure Rules

1.1 **Respect the existing architecture**

- Keep using the **feature-based** structure under `lib/features`.
- Do not move files across features unless explicitly requested by the developer.
- Do not collapse or flatten the `data/` and `presentation/` layers.

1.2 **Core folder is authoritative**

- `lib/core/config/` contains application and environment config.
- `lib/core/routing/` contains routing definition.
- `lib/core/theme/` contains app theming.
- `lib/core/utils/` contains shared helpers.
- `lib/core/widgets/` contains shared UI components.

You should treat these as **source of truth**, not generate alternatives in random locations.

---

## 2. File Placement Rules

When generating new code:

- **Models** → `lib/features/<feature>/data/models/`
- **Remote data sources (HTTP)** → `lib/features/<feature>/data/datasources/`
- **Repositories** → `lib/features/<feature>/data/repositories/`
- **Controllers / state** → `lib/features/<feature>/presentation/controllers/`
- **Pages / screens** → `lib/features/<feature>/presentation/pages/`
- **Feature-specific widgets** → `lib/features/<feature>/presentation/widgets/`
- **Shared / cross-feature models** → `lib/shared/models/` (if they are not tied to one feature)

Do not create new top-level folders under `lib/` (e.g., `lib/services/`, `lib/screens/`) unless explicitly requested by the developer.

---

## 3. Networking & Env Rules

3.1 **Use `Env` for URLs**

- All backend URLs should be built via:
  - `Env.backendBaseUrl`
  - or `Env.api('/path')`

Do not hard-code absolute URLs like `http://localhost:8000` or production URLs directly in feature code.

3.2 **Use `CookieRequest` for HTTP**

- For calls to the Django backend, use `CookieRequest` from `import 'package:pbp_django_auth/pbp_django_auth.dart';`.
- Inject `CookieRequest` via constructor in data sources or repositories rather than creating a new instance in each function.

  3.3 **Do not alter core auth behavior**

- Do not change the internal behavior of `CookieRequest` unless the developer is explicitly editing that file.
- Do not introduce additional HTTP clients for the same purpose without clear developer intent.

---

## 4. State Management Rules

4.1 **Default pattern: ChangeNotifier + Provider**

- New controllers should extend `ChangeNotifier` and live in `presentation/controllers`.
- New UI that depends on state should be wired via `ChangeNotifierProvider` / `Consumer` or `context.watch()` / `context.read()`.

  4.2 **Avoid mixing concerns**

- Do not put network logic inside widgets (e.g., inside `build` methods).
- Do not call `CookieRequest` directly from `presentation/pages` or `presentation/widgets`; go through `repositories` or `controllers`.

If the developer is writing code that uses another state management solution (e.g., Riverpod or Bloc), Kilocode may follow that pattern **only in that context** and must not refactor the whole project automatically.

---

## 5. Theming & UI Rules

5.1 **Reuse shared widgets**

- Prefer `AppButton` and `AppTextField` from `lib/core/widgets/` when generating forms, login screens, or standard buttons, unless the developer clearly requests custom UI.

  5.2 **Respect `AppTheme`**

- Do not override global theming or create new `ThemeData` instances arbitrarily.
- Use theming and colors from `AppTheme` instead of hard-coded colors wherever possible, unless explicitly requested.

---

## 6. Naming & Style Rules

- Classes: `PascalCase`
- Files: `snake_case.dart`
- Repositories: `<Feature>Repository`
- Remote data sources: `<Feature>RemoteDataSource`
- Controllers: `<Feature>Controller`
- Pages: `<Feature>Page`

Kilocode should not:

- Generate multiple files with similar names that differ only in small ways (e.g., `feed_page.dart` vs `feeds_page.dart`) unless requested.
- Rename files or classes automatically across the project.

---

## 7. Safe Editing Rules

- Do not edit:

  - `main.dart`
  - `lib/core/config/env.dart`
  - `lib/core/config/app_config.dart`
  - `lib/core/theme/app_theme.dart`
  - `lib/core/network/cookie_request.dart`
  - routing definitions in `lib/core/routing/app_router.dart`

  unless the developer is currently working in those files and the change clearly follows their manual edits.

- Do not remove or alter `.env` and `.env.example` semantics.

---

## 8. Testing & Linting

- All generated Dart code must be null-safe.
- Suggested changes should not introduce analyzer errors based on `analysis_options.yaml`.
- When generating test files, place them under `test/` and follow existing patterns where possible (e.g., widget tests for pages).

---

## 9. Security & Secrets

- Never suggest adding API keys, tokens, passwords, or other secrets directly in source code.
- Do not hard-code credentials or environment-specific secrets.
- If configuration is needed, point to `.env` and `--dart-define` usage, not in-code constants.

