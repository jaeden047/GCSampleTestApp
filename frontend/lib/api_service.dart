import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  // PROD base URL from doc:
  static const String baseUrl = 'https://greencontributor.org/api/v1';
  // DEV: 'http://localhost:3000/api/v1'

  final _storage = const FlutterSecureStorage();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // ----- Token storage -----
  Future<void> saveToken(String token) => _storage.write(key: 'jwt', value: token);
  //stores jwt key from strage
  Future<String?> getToken() => _storage.read(key: 'jwt');
  //reads jwt key from storage
  Future<void> clearToken() => _storage.delete(key: 'jwt');
  // removes jwt key
  // ----- API calls -----

  /// POST /auth/login
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    ); // Sends POST request to baseURL (natural from _dio.post) + /auth/login 
    // sends JSON  with two fields; email and password
    // [variable name] : [whats in the variable]
    // { "email": "whateverYourVariableContains" }

      // server responds with a JSON res.data (response variable data)
      // we turn it into a dictionary to map: data['email']; reference the map
      final data = res.data as Map<String, dynamic>; 

      // The docs say you "receive a token" but don't show the exact key name.
      // Need table name
      final token = data['email'] ?? data['password'];
      //Line 2: “find the token inside the JSON”
      //final token = data['token'] ?? data['access_token'] ?? data['jwt'];
      //{ "token": "XYZ" }
      //data['token'] is "XYZ" → token becomes "XYZ"
      //“Try data['token']. If that’s null, try data['access_token']. If that’s null, try data['jwt'].”

    if (token == null) {
      throw Exception('No token found in login response: $data');
    }
    await saveToken(token.toString()); // This now maps the server's token to storage (from server's JSON response to JSON request with the email and password)
  }

  /// GET /user/profile (requires Bearer token)
  Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken(); // reads the user's token from current storage (fields are not)
    if (token == null || token.isEmpty) {
      throw Exception('No JWT saved');
    }

    final res = await _dio.get(
      '/user/profile',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return (res.data as Map<String, dynamic>); // returns another map
  }
}
