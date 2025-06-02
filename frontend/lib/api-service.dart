import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://localhost:3000'; // or replace with your Mac's IP

  Future<http.Response> loginUser(String name, String email, String phone) async {
    final url = Uri.parse('$baseUrl/api/users');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'Name': name,
        'Email': email,
        'Phone': phone,
      }),
    );

    return response;
  }
}
