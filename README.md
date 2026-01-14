# Bitchute (Flutter)

A small Flutter app scaffold inspired by the Ruby project in this repository — it uses the SMAT API endpoint that the Ruby script calls to search Bitchute videos and displays results.

## What I added ✅
- `pubspec.yaml` with dependencies (`http`, `url_launcher`)
- `lib/main.dart` — simple search UI (search box, results list)
- `lib/models/video.dart` — `Video` model with `fromJson`
- `lib/services/api_service.dart` — `ApiService.search` that queries the SMAT endpoint
- `lib/widgets/video_tile.dart` — result tile that shows thumbnail and opens the video in an in-app WebView
- Thumbnails are cached with `cached_network_image` and show a shimmer placeholder while loading.

## Run locally
1. Install Flutter (https://flutter.dev/docs/get-started/install) if you don't have it.
2. From the repository root run:

```bash
flutter pub get
flutter run
```

3. Type a search term and tap "Search".

## Notes
- The app queries: `https://api.smat-app.com/content?term=<query>&limit=<n>&site=bitchute_video...`
- Check the API provider's usage policy before heavy usage.
- Tapping a result opens the video in an in-app WebView. `webview_flutter` requires additional platform setup on iOS and Android; see the plugin docs for configuration details.

## Next steps
- Add pagination, details page, and tests
- Improve error handling and offline caching

## Changelog
- 2026-01-08 — Added an **auto-load home feed** feature: `SearchScreen` now accepts an `autoLoad` boolean (defaults to **true**) and will load a home/trending feed on startup. `ApiService` includes a `homeFeed()` helper that maps to a default search, and a widget test (`test/search_screen_autoload_test.dart`) verifies the auto-load behavior with a fake `ApiService`.

## Branch protection
We recommend protecting the `main`/`master` branches and requiring CI checks before merging. To enable branch protection:

1. Go to your repository on GitHub → **Settings** → **Branches** → **Add rule**.
2. Use a branch name pattern (e.g., `main`) and enable **Require status checks to pass before merging**.
3. Select `Flutter tests` and `Pre-merge checks` (if present) from the list of checks.
4. Optionally enable **Require pull request reviews before merging** (e.g., 1 reviewer) and **Require branches to be up to date before merging**.
5. Save changes.

This ensures PRs cannot be merged unless CI passes and encourages reviewers to verify changes.

