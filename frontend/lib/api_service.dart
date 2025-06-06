import 'dart:convert'; // convert Dart map to JSON string
import 'package:http/http.dart' as http; // for making HTTP requests

// define a class to handle API-related functionality
class ApiService {
  final String baseUrl = 'http://localhost:3001'; // or replace with your Mac's IP
  // DON'T POST THIS

  Future<http.Response> loginUser(String name, String email, String phone) async {
    final url = Uri.parse('$baseUrl/api/users');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'Name': name,
          'Email': email,
          'Phone': phone,
        }),
      );
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      return response;
    } catch (e) {
      print("Error occurred: $e");
      rethrow;
    }
  }
}
