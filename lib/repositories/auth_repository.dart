import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';

class AuthRepository {
  // TODO: Replace with your Firebase Web API key
  static const String apiKey = 'AIzaSyD_NazBzEaeyvvPdggTBDj1jNE5cI7gto4';

  static const String _prefsKey = 'auth_user_v1';

  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  AuthRepository() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final jsonData = json.decode(raw) as Map<String, dynamic>;
        _currentUser = AppUser.fromJson(jsonData);
      } catch (_) {
        _currentUser = null;
      }
    }
  }

  Future<void> _saveToPrefs(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_prefsKey, json.encode(user.toJson()));
    _currentUser = user;
  }

  Future<void> _clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    _currentUser = null;
  }

  /// Sign in with email/password using Firebase REST API
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey';

    final body = json.encode({
      'email': email,
      'password': password,
      'returnSecureToken': true,
    });

    final res = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json'}, body: body);

    final decoded = json.decode(res.body);
    if (res.statusCode == 200) {
      // Response contains idToken, refreshToken, localId, expiresIn
      final user = AppUser(
        localId: decoded['localId'] ?? '',
        email: decoded['email'] ?? email,
        idToken: decoded['idToken'] ?? '',
        refreshToken: decoded['refreshToken'] ?? '',
        expiresIn: int.tryParse(decoded['expiresIn']?.toString() ?? '0') ?? 0,
      );

      await _saveToPrefs(user);
      return user;
    } else {
      // Extract error message
      final message = _extractFirebaseError(decoded);
      throw Exception(message);
    }
  }

  /// Create account (sign up) using Firebase REST API
  Future<AppUser> signUp({
    required String email,
    required String password,
  }) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey';

    final body = json.encode({
      'email': email,
      'password': password,
      'returnSecureToken': true,
    });

    final res = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json'}, body: body);

    final decoded = json.decode(res.body);
    if (res.statusCode == 200) {
      final user = AppUser(
        localId: decoded['localId'] ?? '',
        email: decoded['email'] ?? email,
        idToken: decoded['idToken'] ?? '',
        refreshToken: decoded['refreshToken'] ?? '',
        expiresIn: int.tryParse(decoded['expiresIn']?.toString() ?? '0') ?? 0,
      );

      await _saveToPrefs(user);
      return user;
    } else {
      final message = _extractFirebaseError(decoded);
      throw Exception(message);
    }
  }

  /// Sign out locally
  Future<void> signOut() async {
    await _clearPrefs();
  }

  /// Refresh idToken using refreshToken via securetoken endpoint
  /// Returns new AppUser (with refreshed idToken) or throws.
  Future<AppUser> refreshIdToken() async {
    if (_currentUser == null) {
      throw Exception('No user to refresh');
    }
    final url =
        'https://securetoken.googleapis.com/v1/token?key=$apiKey'; // note: different endpoint
    final body =
        'grant_type=refresh_token&refresh_token=${_currentUser!.refreshToken}';

    final res = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body);

    final decoded = json.decode(res.body);
    if (res.statusCode == 200 && decoded['id_token'] != null) {
      // Response fields: id_token, refresh_token, expires_in, user_id
      final newUser = AppUser(
        localId: decoded['user_id'] ?? _currentUser!.localId,
        email: _currentUser!.email,
        idToken: decoded['id_token'] ?? _currentUser!.idToken,
        refreshToken: decoded['refresh_token'] ?? _currentUser!.refreshToken,
        expiresIn:
            int.tryParse(decoded['expires_in']?.toString() ?? '3600') ?? 3600,
      );

      await _saveToPrefs(newUser);
      return newUser;
    } else {
      final msg = decoded is Map && decoded.containsKey('error')
          ? (decoded['error'] as Map)['message'] ?? 'Token refresh failed'
          : 'Token refresh failed';
      throw Exception(msg);
    }
  }

  String _extractFirebaseError(dynamic decoded) {
    try {
      if (decoded is Map && decoded.containsKey('error')) {
        final err = decoded['error'];
        if (err is Map && err.containsKey('message')) {
          return err['message'];
        } else if (err is String) {
          return err;
        }
      }
    } catch (_) {}
    return 'Authentication failed';
  }
}
