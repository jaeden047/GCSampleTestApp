import 'dart:html' as html; // browser only

// This file implements API token storage for the web build using sessionStorage (instead of) 
// FlutterSecureStorage). api_service.dart imports a switch file, which exports this web implementation.
// only on web. Because sessionStorage is cleared when the tab/browser is closed, 
// reopening the app later will not find the token and the user will be logged out.

abstract class TokenStore {
  Future<void> save(String token);
  Future<String?> read();
  Future<void> clear();
}

class PlatformTokenStore implements TokenStore {
  static const _k = 'jwt';

  @override
  Future<void> save(String token) async {
    html.window.sessionStorage[_k] = token;
  }

  @override
  Future<String?> read() async {
    return html.window.sessionStorage[_k];
  }

  @override
  Future<void> clear() async {
    html.window.sessionStorage.remove(_k);
  }
}