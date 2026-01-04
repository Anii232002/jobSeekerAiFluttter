import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  // Keys for storage
  static const String _userIdKey = 'user_id';
  static const String _authTokenKey = 'auth_token';
  static const String _emailKey = 'user_email';

  static const String _authTimeKey = 'auth_time';
  // Expiration duration (e.g., 1 hour)
  static const Duration _sessionDuration = Duration(hours: 1);

  /// Save auth data after successful login
  static Future<void> saveAuthData({
    required String userId,
    required String email,
  }) async {
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _emailKey, value: email);
    // Save current timestamp
    await _storage.write(
      key: _authTimeKey,
      value: DateTime.now().toIso8601String(),
    );
  }

  /// Get saved user ID
  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// Get saved email
  static Future<String?> getEmail() async {
    return await _storage.read(key: _emailKey);
  }

  /// Check if user is logged in (has saved credentials and session is valid)
  static Future<bool> isLoggedIn() async {
    final userId = await _storage.read(key: _userIdKey);
    final authTimeStr = await _storage.read(key: _authTimeKey);

    if (userId != null && userId.isNotEmpty && authTimeStr != null) {
      final authTime = DateTime.parse(authTimeStr);
      final now = DateTime.now();

      // Check if session has expired
      if (now.difference(authTime) < _sessionDuration) {
        return true;
      }
    }

    // If expired or invalid, clear data
    await clearAuthData();
    return false;
  }

  /// Clear all auth data on logout
  static Future<void> clearAuthData() async {
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _authTokenKey);
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _authTimeKey);
  }
}
