import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'models/video.dart';
import 'models/user.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'providers/auth_provider.dart';
import 'widgets/video_tile.dart';
import 'screens/sign_in_screen.dart';
import 'screens/subscriptions_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/video_upload_screen.dart';
import 'services/history_service.dart';
import 'screens/history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BitchuteApp());
}

class BitchuteApp extends StatelessWidget {
  const BitchuteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authService: AuthService())),
        ChangeNotifierProvider<HistoryService>(create: (_) => HistoryService()),
      ],
      child: MaterialApp(
        title: 'Bitchute',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: false,
        ).copyWith(
          appBarTheme: AppBarTheme(
            backgroundColor: ColorScheme.fromSeed(seedColor: Colors.blue).surface,
            iconTheme: IconThemeData(color: ColorScheme.fromSeed(seedColor: Colors.blue).onSurface),
            titleTextStyle: TextStyle(color: ColorScheme.fromSeed(seedColor: Colors.blue).secondary, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
          useMaterial3: false,
        ).copyWith(
          appBarTheme: AppBarTheme(
            backgroundColor: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark).surface,
            iconTheme: IconThemeData(color: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark).onSurface),
            titleTextStyle: TextStyle(color: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark).secondary, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        themeMode: ThemeMode.system,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  void _initializeAuth() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!authProvider.isLoggedIn) {
          return _buildAuthStack();
        }

        return HomeScreen(user: authProvider.user!);
      },
    );
  }

  Widget _buildAuthStack() {
    final authService = AuthService();
    return SignInScreen(
      authService: authService,
      onSignInSuccess: (user) {
        context.read<AuthProvider>().signIn(email: 'demo@bitchute.com', password: 'password');
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final ApiService _apiService = ApiService();
  bool _searchActive = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _searchQuery = '';
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _loadNotificationCount();
  }

  Future<void> _loadNotificationCount() async {
    try {
      final notes = await _apiService.notifications();
      if (!mounted) return;
      setState(() {
        _unreadNotifications = notes.where((n) => !n.isRead).length;
      });
    } catch (_) {
      // ignore errors for now
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _searchActive
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _searchActive = false;
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
              )
            : null,
        title: _searchActive
            ? Row(children: [
                Expanded(
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(color: Theme.of(context).cardColor.withOpacity(0.08), borderRadius: BorderRadius.circular(18)),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocus,
                          autofocus: true,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          decoration: InputDecoration(hintText: 'Search', border: InputBorder.none, isDense: true, hintStyle: TextStyle(color: Theme.of(context).hintColor)),
                          onChanged: (s) => setState(() {}),
                          onSubmitted: (s) {
                            setState(() {
                              _searchQuery = s.trim();
                              _selectedIndex = 0;
                            });
                          },
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
                          onPressed: () => setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          }),
                        )
                    ]),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    setState(() {
                      _searchQuery = _searchController.text.trim();
                      _selectedIndex = 0;
                    });
                    _searchFocus.requestFocus();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(24)),
                    child: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
              ])
            : Text('Bitchute', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.cast),
            onPressed: () {},
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  );
                  // refresh count when returning
                  _loadNotificationCount();
                },
              ),
              if (_unreadNotifications > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.error, borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      _unreadNotifications > 99 ? '99+' : _unreadNotifications.toString(),
                      style: TextStyle(color: Theme.of(context).colorScheme.onError, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          if (!_searchActive)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => setState(() {
                  _searchActive = true;
                  // focus after rebuild
                  WidgetsBinding.instance.addPostFrameCallback((_) => _searchFocus.requestFocus());
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(24)),
                  child: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
            ),
        ],
      ),
      body: _getScreen(_selectedIndex),

      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).colorScheme.surface,
        elevation: 8,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side
              Row(
                children: [
                  MaterialButton(
                    minWidth: 60,
                    onPressed: () => setState(() => _selectedIndex = 0),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.home, color: _selectedIndex == 0 ? Theme.of(context).primaryColor : Theme.of(context).disabledColor),
                      Text('Home', style: TextStyle(color: _selectedIndex == 0 ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, fontSize: 12)), 
                    ]),
                  ),
                  MaterialButton(
                    minWidth: 60,
                    onPressed: () => setState(() => _selectedIndex = 1),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.play_arrow, color: _selectedIndex == 1 ? Theme.of(context).primaryColor : Theme.of(context).disabledColor),
                      Text('Shorts', style: TextStyle(color: _selectedIndex == 1 ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, fontSize: 12)), 
                    ]),
                  ),
                ],
              ),

              // Center + button (floating feel)
              Transform.translate(
                offset: const Offset(0, -18),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedIndex = 2),
                  child: Material(
                    elevation: 4,
                    shape: const CircleBorder(),
                    color: Theme.of(context).colorScheme.surface,
                    child: SizedBox(width: 56, height: 56, child: Icon(Icons.add, color: Theme.of(context).colorScheme.onSurface, size: 28)),
                  ),
                ),
              ),

              // Right side
              Row(
                children: [
                  MaterialButton(
                    minWidth: 60,
                    onPressed: () => setState(() => _selectedIndex = 3),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.subscriptions, color: _selectedIndex == 3 ? Theme.of(context).primaryColor : Theme.of(context).disabledColor),
                      Text('Subscriptions', style: TextStyle(color: _selectedIndex == 3 ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, fontSize: 12)), 
                    ]),
                  ),
                  MaterialButton(
                    minWidth: 60,
                    onPressed: () => setState(() => _selectedIndex = 4),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.person, color: _selectedIndex == 4 ? Theme.of(context).primaryColor : Theme.of(context).disabledColor),
                      Text('You', style: TextStyle(color: _selectedIndex == 4 ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, fontSize: 12)),
                    ]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return SearchScreen(api: _apiService, autoLoad: true, query: _searchQuery);
      case 1:
        return const Center(child: Text('Shorts'));
      case 2:
        return const VideoUploadScreen();
      case 3:
        return const SubscriptionsScreen();
      case 4:
        return HistoryScreen();
      default:
        return SearchScreen(api: _apiService, autoLoad: true, query: _searchQuery);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }
}

class SearchScreen extends StatefulWidget {
  final ApiService api;
  final bool autoLoad;
  final String? query;

  SearchScreen({Key? key, ApiService? api, this.autoLoad = true, this.query}) : api = api ?? ApiService(), super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  late final ApiService _api;
  List<Video> _results = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _api = widget.api;
    if (widget.autoLoad) _loadHomeFeed();
    if (widget.query != null && widget.query!.isNotEmpty) {
      _controller.text = widget.query!;
      WidgetsBinding.instance.addPostFrameCallback((_) => _doSearch());
    }
  }

  @override
  void didUpdateWidget(covariant SearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != oldWidget.query) {
      if (widget.query != null && widget.query!.isNotEmpty) {
        _controller.text = widget.query!;
        _doSearch();
      } else {
        _loadHomeFeed();
      }
    }
  }

  void _loadHomeFeed() async {
    setState(() {
      _loading = true;
      _error = null;
      _results = [];
    });
    try {
      final res = await _api.homeFeed();
      setState(() {
        _results = res;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _doSearch() async {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
      _results = [];
    });
    try {
      final res = await _api.search(q);
      setState(() {
        _results = res;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            if (_loading) const LinearProgressIndicator(),
            if (_error != null) Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('Error: $_error', style: TextStyle(color: Theme.of(context).colorScheme.error))),
            Expanded(
                child: _loading
                    ? ListView.separated(
                        itemCount: 6,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Shimmer.fromColors(
                                  baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                                  highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
                                  child: Container(width: 72, height: 72, color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                                )),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Shimmer.fromColors(baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300, highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100, child: Container(width: double.infinity, height: 14, color: isDark ? Colors.grey.shade800 : Colors.grey.shade300)),
                              const SizedBox(height: 8),
                              Shimmer.fromColors(baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300, highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100, child: Container(width: 120, height: 12, color: isDark ? Colors.grey.shade800 : Colors.grey.shade300)),
                            ])),
                          ]),
                        ),
                      )
                    : _results.isEmpty
                        ? const Center(child: Text('No results'))
                        : ListView.builder(itemCount: _results.length, itemBuilder: (context, i) => VideoTile(video: _results[i]))),
          ]),
        ),
      );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

