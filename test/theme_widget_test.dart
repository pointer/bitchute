import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bitchute_browser/main.dart' as app;
import 'package:bitchute_browser/models/user.dart';
import 'package:bitchute_browser/models/video.dart';
import 'package:bitchute_browser/widgets/video_tile.dart';

void main() {
  final sampleUser = User(
    id: '1',
    username: 'tester',
    email: 'a@b.c',
    displayName: 'Tester',
    avatarUrl: null,
    createdAt: DateTime.now(),
  );

  testWidgets('HomeScreen uses theme colors in light mode', (tester) async {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: false,
    );
    final theme = base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: base.colorScheme.surface,
        iconTheme: IconThemeData(color: base.colorScheme.onSurface),
        titleTextStyle: TextStyle(color: base.colorScheme.secondary, fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );

    await tester.pumpWidget(MaterialApp(theme: theme, home: app.HomeScreen(user: sampleUser)));

    // AppBar painted background (Material) should match appBarTheme background
    final material = tester.widget<Material>(find.descendant(of: find.byType(AppBar), matching: find.byType(Material)).first);
    expect(material.color, theme.appBarTheme.backgroundColor);

    // Title 'Bitchute' should use the theme's secondary color
    final title = tester.widget<Text>(find.text('Bitchute').first);
    expect(title.style?.color, theme.colorScheme.secondary);
  });

  testWidgets('HomeScreen uses theme colors in dark mode', (tester) async {
    final baseDark = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
      useMaterial3: false,
    );
    final dark = baseDark.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: baseDark.colorScheme.surface,
        iconTheme: IconThemeData(color: baseDark.colorScheme.onSurface),
        titleTextStyle: TextStyle(color: baseDark.colorScheme.secondary, fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );

    await tester.pumpWidget(MaterialApp(theme: ThemeData.light(), darkTheme: dark, themeMode: ThemeMode.dark, home: app.HomeScreen(user: sampleUser)));

    final material = tester.widget<Material>(find.descendant(of: find.byType(AppBar), matching: find.byType(Material)).first);
    expect(material.color, dark.appBarTheme.backgroundColor);

    final title = tester.widget<Text>(find.text('Bitchute').first);
    expect(title.style?.color, dark.colorScheme.secondary);
  });

  testWidgets('Tapping search shows action with surface background matching theme', (tester) async {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: false,
    );

    await tester.pumpWidget(MaterialApp(theme: theme, home: app.HomeScreen(user: sampleUser)));

    // Tap the search action (InkWell with search icon)
    final searchInk = find.widgetWithIcon(InkWell, Icons.search).first;
    await tester.tap(searchInk);
    await tester.pumpAndSettle();

    // The search action Icon is inside a Container with decoration color == surface
    final containerFinder = find.widgetWithIcon(Container, Icons.search);
    expect(containerFinder, findsWidgets);

    // Pick the container that has a BoxDecoration and assert its color
    final containers = tester.widgetList<Container>(containerFinder).toList();
    Container? matched;
    for (final c in containers) {
      if (c.decoration is BoxDecoration) {
        matched = c;
        break;
      }
    }
    expect(matched, isNotNull);
    final box = matched!.decoration as BoxDecoration;
    expect(box.color, theme.colorScheme.surface);
  });

  testWidgets('VideoTile placeholder icon matches theme icon color', (tester) async {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: false,
    );

    final video = Video(title: 't', author: 'a', username: 'u', url: 'u', thumbnail: null);

    await tester.pumpWidget(MaterialApp(theme: theme, home: Scaffold(body: VideoTile(video: video))));

    final icon = tester.widget<Icon>(find.byIcon(Icons.play_circle_fill));
    expect(icon.color, theme.iconTheme.color);
  });
}
