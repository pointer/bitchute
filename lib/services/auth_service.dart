import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class AuthService {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'auth_user';
  static const String _keyRefresh = 'refresh_token';

  final FlutterSecureStorage _storage;

  AuthService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<User?> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // TODO: Integrate with real backend API
      // For now, create a mock user
      final user = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        username: username,
        email: email,
        displayName: username,
        createdAt: DateTime.now(),
      );

      // Store credentials securely
      await _storage.write(key: _keyToken, value: 'mock_token_${DateTime.now().millisecondsSinceEpoch}');
      await _storage.write(key: _keyUser, value: user.toJson().toString());

      return user;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // TODO: Integrate with real backend API
      // For now, return a mock user
      final user = User(
        id: 'user_123',
        username: email.split('@')[0],
        email: email,
        displayName: email.split('@')[0],
        createdAt: DateTime.now(),
      );

      // Store credentials securely
      await _storage.write(key: _keyToken, value: 'mock_token_${DateTime.now().millisecondsSinceEpoch}');
      await _storage.write(key: _keyUser, value: user.toJson().toString());

      return user;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  Future<User?> getStoredUser() async {
    try {
      final token = await _storage.read(key: _keyToken);
      if (token == null) return null;

      // TODO: Validate token with backend and get fresh user data
      // For now, return a mock user
      return User(
        id: 'user_123',
        username: 'demo_user',
        email: 'demo@bitchute.com',
        displayName: 'Demo User',
        createdAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _keyToken);
    return token != null;
  }

  Future<void> signOut() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyUser);
    await _storage.delete(key: _keyRefresh);
  }
}
