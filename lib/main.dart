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
import 'screens/profile_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/video_upload_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bitchute'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen(user: widget.user)),
              );
            },
          ),
        ],
      ),
      body: _getScreen(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: const Icon(Icons.subscriptions), label: 'Subscriptions'),
          BottomNavigationBarItem(icon: const Icon(Icons.add_circle), label: 'Upload'),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: 'You'),
        ],
      ),
    );
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return SearchScreen(api: _apiService, autoLoad: true);
      case 1:
        return const SubscriptionsScreen();
      case 2:
        return const VideoUploadScreen();
      case 3:
        return ProfileScreen(user: widget.user);
      default:
        return SearchScreen(api: _apiService, autoLoad: true);
    }
  }
}

class SearchScreen extends StatefulWidget {
  final ApiService api;
  final bool autoLoad;

  SearchScreen({Key? key, ApiService? api, this.autoLoad = true}) : api = api ?? ApiService(), super(key: key);

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

  void _openSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search'),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: 'Enter search query...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _doSearch();
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
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
        floatingActionButton: FloatingActionButton(
          onPressed: _openSearchDialog,
          tooltip: 'Search',
          child: const Icon(Icons.search),
        ),
      );
}
