import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Token storage for iOS and Android using FlutterSecureStorage.
abstract class TokenStore {
  Future<void> save(String token);
  Future<String?> read();
  Future<void> clear();
}

class PlatformTokenStore implements TokenStore {
  static const _key = 'jwt';
  final _storage = const FlutterSecureStorage();

  @override
  Future<void> save(String token) async {
    await _storage.write(key: _key, value: token);
  }

  @override
  Future<String?> read() async {
    return _storage.read(key: _key);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _key);
  }
}
