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
2. From this folder run:

```bash
cd flutter_app
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

