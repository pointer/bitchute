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
        backgroundColor: Colors.black,
        title: const Text('Bitchute', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.cast),
            onPressed: () {},
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                  child: const Text('9+', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen(api: _apiService, autoOpen: true)));
              },
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const VideoUploadScreen()));
        },
        child: const Icon(Icons.add, size: 32),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
        return SearchScreen(api: _apiService, autoLoad: true);
      case 1:
        return const Center(child: Text('Shorts'));
      case 2:
        return const VideoUploadScreen();
      case 3:
        return const SubscriptionsScreen();
      case 4:
        return ProfileScreen(user: widget.user);
      default:
        return SearchScreen(api: _apiService, autoLoad: true);
    }
  }
}

class SearchScreen extends StatefulWidget {
  final ApiService api;
  final bool autoLoad;
  final bool autoOpen;

  SearchScreen({Key? key, ApiService? api, this.autoLoad = true, this.autoOpen = false}) : api = api ?? ApiService(), super(key: key);

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
    if (widget.autoOpen) WidgetsBinding.instance.addPostFrameCallback((_) => _openSearchDialog());
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
