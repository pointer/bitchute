# Copilot / AI Agent Instructions for Bitchute (Flutter)

This file captures the concise, actionable knowledge an AI coding agent needs to be productive in this repo.

## TL;DR
- Small Flutter app that queries the SMAT API (https://api.smat-app.com). Key runtime code lives under `lib/` and tests in `test/`.
- Run locally: `flutter pub get` then `flutter run` (from repo root). Tests: `flutter test` (CI runs `flutter test --coverage`).

## Big-picture architecture (quick)
- UI: `lib/main.dart` (app + `AuthGate` + `HomeScreen`) and `lib/screens/*` (Search, Notifications, History, etc.).
- Services: `lib/services/*` — notable ones:
  - `ApiService` (`lib/services/api_service.dart`): network client for SMAT API; has retries, timeout, backoff, and `homeFeed()` convenience wrapper.
  - `AuthService` (`lib/services/auth_service.dart`): uses `flutter_secure_storage`; currently mocked (no external auth backend).
  - `HistoryService` (`lib/services/history_service.dart`) and other ChangeNotifier-backed services are injected with `Provider` in `main.dart`.
- Models: `lib/models/*` (e.g., `Video.fromJson` maps the SMAT JSON to the app model).
- State: lightweight Provider-based pattern (see `lib/providers/auth_provider.dart`).

## Important code/pattern notes (do not change lightly)
- ApiService behavior
  - Expects SMAT responses in the form `{'hits': {'hits': [ ... ] }}`. See `ApiService.search` for parsing details.
  - Implements exponential backoff + `maxAttempts`, `baseDelayMs`, and `timeout` params. Tests rely on this; use the constructor args to adjust retry behavior during tests (e.g. `baseDelayMs: 1`, `maxAttempts: 2`).

- Video parsing
  - `Video.fromJson` tries several keys for thumbnails (`thumbnail`, `thumbnail_url`, `poster`, `meta.image`, `meta.thumbnail`). Keep this tolerant mapping if touching parsing.

- Tests and mocking
  - Unit tests for `ApiService` use `http/testing.dart`'s `MockClient` (see `test/api_service_test.dart`).
  - Widget tests inject a fake service (`class FakeApiService extends ApiService`) and pass it to widgets via constructors (see `test/search_screen_autoload_test.dart`). Follow these patterns so tests remain fast and deterministic.
  - There is one live integration-ish test `test/api_service_live_test.dart` that hits the real SMAT API. CI runs all tests; consider marking network-dependent tests as skipped or conditional if you change network behavior.

- Providers and dependency injection
  - The app uses `Provider` (ChangeNotifier) in `main.dart`. Services are often passed in via constructor args in widgets for testability (SearchScreen accepts `api` argument).

## Developer workflows (commands)
- Local quick checks:
  - Install deps: `flutter pub get`
  - Run app: `flutter run`
  - Run all tests: `flutter test`
  - Run a single test file: `flutter test test/api_service_test.dart`
- CI: GitHub Actions workflow `.github/workflows/flutter-tests.yml` sets up Flutter and runs `flutter test --coverage` on push/PR.

## Files to inspect when making changes
- Behavior changes: `lib/services/api_service.dart`, `lib/models/video.dart`
- UI changes: `lib/main.dart`, `lib/screens/*`, `lib/widgets/*`
- Auth/state: `lib/services/auth_service.dart`, `lib/providers/auth_provider.dart`
- Tests: `test/*` — update or add unit/widget tests when changing behavior.

## Examples / snippets (use these patterns in tests)
- Mocking network responses with `MockClient`:

```dart
final mockClient = MockClient((request) async => http.Response(jsonEncode(sample), 200));
final api = ApiService(client: mockClient);
```

- Fast retry config in tests:

```dart
final api = ApiService(client: mockClient, maxAttempts: 2, baseDelayMs: 1);
```

- Injecting a fake ApiService into widget tests:

```dart
final fake = FakeApiService(result: sample, delay: Duration(milliseconds: 10));
await tester.pumpWidget(MaterialApp(home: SearchScreen(api: fake, autoLoad: true)));
```

## Platform & 3rd-party notes
- `webview_flutter` requires platform-specific configuration on iOS & Android (see plugin docs). The app currently opens videos in an in-app WebView.
- `flutter_secure_storage` is used by `AuthService`; data storage interactions are mocked but may require platform setup in integration tests.

## Small TODOs / gotchas for contributors
- README run steps still mention `cd flutter_app` which should be updated to indicate running from repo root: `flutter pub get` and `flutter run`.
- The live API test (`test/api_service_live_test.dart`) can fail on CI if the external API is unreachable — be cautious if altering network code.

## PR checklist ✅
- Add a short description of the change and link to any related issue.
- Run `flutter test` locally and ensure all tests pass (mark network-dependent tests as skipped locally if needed). Include the test command you ran and any failures in the PR body.
- Add/Update unit and widget tests for behavioral changes and ensure coverage does not regress significantly (`test/*`).
- Add a concise changelog entry in the PR description when adding features or behavior changes.
- Add appropriate labels to the PR (e.g., `area/ui`, `area/api`, `bug`, `enhancement`, `docs`, `ci`).
- Request at least one reviewer familiar with the touched area (e.g., `@repo-owner` or team aliases).
- Verify CI passes on the PR (see `Flutter tests` workflow); if introducing network-dependent tests, mark them/skips and document why.
- Update `README.md` or `.github/copilot-instructions.md` for any developer-facing changes.
- Ensure new dependencies are added to `pubspec.yaml` and `flutter pub get` succeeds; update lockfiles if present.
- Keep changes small and focused; prefer constructor injection for services to make testing easy (see `SearchScreen`).

## Pre-merge automation suggestion 🔧
- The repo already has a `Flutter tests` workflow that runs on `push` and `pull_request`; enable branch protection to *require* that check before allowing merges into `main`/`master`.
- If you'd like an explicit PR-only job, you can add a lightweight workflow (example below) that runs `flutter test` on `pull_request` and fails the PR when tests do not pass.

```yaml
# .github/workflows/pre-merge-checks.yml (suggested)
name: Pre-merge checks
on:
  pull_request:
    branches: [ main, master ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: 'stable'
      - name: Install dependencies
        run: flutter pub get
      - name: Run tests
        env:
          CI: true
        run: flutter test --coverage
```

- After adding the workflow, set branch protection (Repository settings → Branches) to require the `Pre-merge checks` and/or `Flutter tests` status to pass before merging.

---
If anything above is unclear or missing, tell me what additional sections or examples you'd like (e.g., example test scaffolding), and I will iterate. ✅
