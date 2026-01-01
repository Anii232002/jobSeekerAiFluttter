import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  // Keys for storage
  static const String _userIdKey = 'user_id';
  static const String _authTokenKey = 'auth_token';
  static const String _emailKey = 'user_email';

  /// Save auth data after successful login
  static Future<void> saveAuthData({
    required String userId,
    required String email,
  }) async {
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _emailKey, value: email);
  }

  /// Get saved user ID
  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// Get saved email
  static Future<String?> getEmail() async {
    return await _storage.read(key: _emailKey);
  }

  /// Check if user is logged in (has saved credentials)
  static Future<bool> isLoggedIn() async {
    final userId = await _storage.read(key: _userIdKey);
    return userId != null && userId.isNotEmpty;
  }

  /// Clear all auth data on logout
  static Future<void> clearAuthData() async {
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _authTokenKey);
    await _storage.delete(key: _emailKey);
  }
}
