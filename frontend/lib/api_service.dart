import 'package:dio/dio.dart';
//import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth/token_store.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();
  final supabase = Supabase.instance.client;
  final supabaseHiddenPassword = "test123!";

  // PROD base URL from doc:
  static const String baseUrl = 'https://www.greencontributor.org/api/v1';
  static const String supabaseHiddenPassword = 'hiddenPassword123!'; // Hidden Password due to Supabase Backend 

  final TokenStore _tokenStore = PlatformTokenStore();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // ----- Token storage -----
  Future<void> saveToken(String token) => _tokenStore.save(token);
  //stores jwt key from strage
  Future<String?> getToken() => _tokenStore.read();
  //reads jwt key from storage
  Future<void> clearToken() => _tokenStore.clear();
  // removes jwt key
  // ----- API calls -----

  // Supabase Sign-Up (hidden Password)
  Future<void> supabaseSignUp({ // Supabase Signup is Standardized; need to import fields through profile.
    required String email,
    required String password,
  }) async {
    final res = await supabase.auth.signUp(
      email: email,
      password: supabaseHiddenPassword,
    );
    if (res.user == null) {
      throw Exception('Supabase sign up failed (no user returned).');
    }
  }

  // Supabase Login
  Future<void> supabaseLogin({ // Supabase Login is also standardized
    required String email,
    required String password,
  }) async {
    final res = await supabase.auth.signInWithPassword(
      email: email,
      password: supabaseHiddenPassword,
    );
    if (res.user == null) {
      throw Exception('Supabase login failed (no user returned).');
    }
  }

  Future<void> forgotPassword({
    required String email,
  }) async {
    try{
      final res = await _dio.post('/auth/forgot-password', data: {
          'email': email,
        },
      );
      print(res.data);
    } on DioException catch (e) { // dio specific errors
      final statusCode = e.response?.statusCode; // server error code 404/400/etc.
      final body = e.response?.data; // server response data
      throw Exception('Forgot Password: Email request failed ($statusCode): $body'); 
    } catch (e) { // all other error points
      throw Exception('Forgot Password: Email request failed $e');
    }
  }

  /// POST /auth/register to server
  Future<void> register({ // Register is an action, therefore it needs to return nothing
    required String email,
    required String password,
    required String name,
    required String? interestedProgram, // "69598383bfc1a2a7926b46f6"
    required String? studentType, // "school"
    required String? photo, // "https://example.com/profile.jpg"
    String? phone,
    String? institution,
    String? address,
    String? country,
    String? gender,
    String? grade,
    String? userType, // 'STUDENT', 
    String? referenceCode,
  }) async {
      try {
      final res = await _dio.post('/auth/register', data: {
          'email': email,
          'password': password,
          'name': name,
          'interestedProgram': interestedProgram,
          'studentType': studentType,
          'photo': photo,
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
      print(res.data);
      // token key depends on backend; "jwt" is only correct if response uses that key
    } on DioException catch (e) {
      print('REGISTER DioException: type=${e.type}');
      print('REGISTER message=${e.message}');
      print('REGISTER error=${e.error}');
      print('REGISTER uri=${e.requestOptions.uri}');
      print('REGISTER data=${e.requestOptions.data}');
      print('REGISTER response=${e.response?.statusCode} body=${e.response?.data}');
      rethrow;
    } catch (e) { // all other error points
      throw Exception('Register failed: $e');
    }
  }
  /// POST /auth/login
  Future<void> login({ // API Login
    required String email,
    required String password,
  }) async {
    final res = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    ); // Sends POST request to baseURL (natural from _dio.post) + /auth/login 
      // server responds with a JSON object res.data; we store in variable as map.
      print(res.data);
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

  Future<void> syncApiIdToSupabaseProfiles() async {
  final supaUser = supabase.auth.currentUser; // reads currently logged in user
  if (supaUser == null) return;

  // Get API profile
  final apiRes = await getProfile();
  final apiUser = apiRes['user'] as Map<String, dynamic>;
  final apiId = apiUser['id']?.toString();

  if (apiId == null || apiId.isEmpty) return;

  // Write to supabase profiles
    await supabase.from('profiles').upsert({
    'id': supaUser.id,          // must exist for upsert
    'api_user_id': apiId,
  }, onConflict: 'id');
  // Saves API ID to user field
}

    Future<Map<String, dynamic>> updateProfileFromProfilePage({
    String? phone,
    String? institution,
    String? address,
    String? gender,
    String? photo,
    String? country,
  }) async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      throw Exception('No token saved');
    }

    final data = <String, dynamic>{};
    if (phone != null && phone.trim().isNotEmpty) data['phone'] = phone.trim();
    if (institution != null && institution.trim().isNotEmpty) data['institution'] = institution.trim();
    if (address != null && address.trim().isNotEmpty) data['address'] = address.trim();
    if (gender != null && gender.trim().isNotEmpty) data['gender'] = gender.trim();
    if (photo != null && photo.trim().isNotEmpty) data['photo'] = photo.trim();
    if (country != null && country.trim().isNotEmpty) data['country'] = country.trim(); 
    print("PUT /user/profile payload = $data");
    final res = await _dio.put(
      '/user/profile', // baseUrl already has /api/v1
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'}),
    );
    print (res.data);

    return (res.data as Map<String, dynamic>);
  }
}
