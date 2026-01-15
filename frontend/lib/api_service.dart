import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  // PROD base URL from doc:
  static const String baseUrl = 'https://www.greencontributor.org/api/v1';

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

  
  /// POST /auth/register to server
  Future<void> register({ // Register is an action, therefore it needs to return nothing
    required String email,
    required String password,
    required String name,
    String? phone,
    String? institution,
    String? address,
    String? country,
    String? gender,
    String? grade,
    String? photo,
    String? userType,
    String? referenceCode,
  }) async {
    try {
      final res = await _dio.post('/auth/register', data: {
          'email': email,
          'password': password,
          'name': name,
          if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
          if (institution != null && institution.trim().isNotEmpty) 'institution': institution.trim(),
          if (address != null && address.trim().isNotEmpty) 'address': address.trim(),
          if (country != null && country.trim().isNotEmpty) 'country': country.trim(),
          if (gender != null && gender.trim().isNotEmpty) 'gender': gender.trim(),
          if (grade != null && grade.trim().isNotEmpty) 'grade': grade.trim(),
          if (photo != null && photo.trim().isNotEmpty) 'photo': photo.trim(),
          if (userType != null && userType.trim().isNotEmpty) 'userType': userType.trim(),
          if (referenceCode != null && referenceCode.trim().isNotEmpty) 'referenceCode': referenceCode.trim(),
          // if Optional Fields are filled out, we integrate them, if not, we use them in POST user/profile
        },
      );
      final data = res.data as Map<String, dynamic>; // JSON Object is returned as map
      // token key depends on backend; "jwt" is only correct if response uses that key
      final token = data['token'];
      if (token == null) {
        throw Exception('No token found in login response: $data');
      }
      await saveToken(token.toString()); 
    } on DioException catch (e) { // dio specific errors
      final statusCode = e.response?.statusCode; // server error code 404/400/etc.
      final body = e.response?.data; // server response data
      throw Exception('Register failed ($statusCode): $body'); 
    } catch (e) { // all other error points
      throw Exception('Register failed: $e');
    }
  }
  /// POST /auth/login
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    ); // Sends POST request to baseURL (natural from _dio.post) + /auth/login 
      // server responds with a JSON object res.data; we store in variable as map.
      final data = res.data as Map<String, dynamic>; 
      final token = data['token'];
      if (token == null) {
       throw Exception('No token found in login response: $data');
      }
      await saveToken(token.toString()); // This now maps the server's token to storage (from server's JSON response to JSON request with the email and password)
    }
  /// GET /user/profile (requires Bearer token)
  Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken(); // reads the user's token from current storage (fields are not)
    if (token == null || token.isEmpty) {
      throw Exception('No token saved');
    }
    final res = await _dio.get( // Retrieve user data from server using token
      '/user/profile',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return (res.data as Map<String, dynamic>); // returns user's data (res.data) to whoever called this function
  }
}
