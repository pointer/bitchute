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
        theme: ThemeData(primarySwatch: Colors.blue),
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
        backgroundColor: Colors.black,
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
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(18)),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocus,
                          autofocus: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(hintText: 'Search', border: InputBorder.none, isDense: true, hintStyle: TextStyle(color: Colors.white70)),
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
                          icon: const Icon(Icons.close, color: Colors.white),
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
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                    child: const Icon(Icons.search, color: Colors.black),
                  ),
                ),
              ])
            : const Text('Bitchute', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      _unreadNotifications > 99 ? '99+' : _unreadNotifications.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                  child: const Icon(Icons.search, color: Colors.black),
                ),
              ),
            ),
        ],
      ),
      body: _getScreen(_selectedIndex),

      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
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
                      Icon(Icons.home, color: _selectedIndex == 0 ? Theme.of(context).primaryColor : Colors.grey),
                      Text('Home', style: TextStyle(color: _selectedIndex == 0 ? Theme.of(context).primaryColor : Colors.grey, fontSize: 12)),
                    ]),
                  ),
                  MaterialButton(
                    minWidth: 60,
                    onPressed: () => setState(() => _selectedIndex = 1),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.play_arrow, color: _selectedIndex == 1 ? Theme.of(context).primaryColor : Colors.grey),
                      Text('Shorts', style: TextStyle(color: _selectedIndex == 1 ? Theme.of(context).primaryColor : Colors.grey, fontSize: 12)),
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
                    color: Colors.white,
                    child: const SizedBox(width: 56, height: 56, child: Icon(Icons.add, color: Colors.black, size: 28)),
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
                      Icon(Icons.subscriptions, color: _selectedIndex == 3 ? Theme.of(context).primaryColor : Colors.grey),
                      Text('Subscriptions', style: TextStyle(color: _selectedIndex == 3 ? Theme.of(context).primaryColor : Colors.grey, fontSize: 12)),
                    ]),
                  ),
                  MaterialButton(
                    minWidth: 60,
                    onPressed: () => setState(() => _selectedIndex = 4),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.person, color: _selectedIndex == 4 ? Theme.of(context).primaryColor : Colors.grey),
                      Text('You', style: TextStyle(color: _selectedIndex == 4 ? Theme.of(context).primaryColor : Colors.grey, fontSize: 12)),
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
  Widget build(BuildContext context) => Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            if (_loading) const LinearProgressIndicator(),
            if (_error != null) Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('Error: $_error', style: const TextStyle(color: Colors.red))),
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
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  child: Container(width: 72, height: 72, color: Colors.grey.shade300),
                                )),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Shimmer.fromColors(baseColor: Colors.grey.shade300, highlightColor: Colors.grey.shade100, child: Container(width: double.infinity, height: 14, color: Colors.grey.shade300)),
                              const SizedBox(height: 8),
                              Shimmer.fromColors(baseColor: Colors.grey.shade300, highlightColor: Colors.grey.shade100, child: Container(width: 120, height: 12, color: Colors.grey.shade300)),
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
