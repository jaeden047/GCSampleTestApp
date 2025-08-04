import 'dart:convert'; // convert Dart map to JSON string
import 'package:http/http.dart' as http; // for making HTTP requests
import 'package:shared_preferences/shared_preferences.dart'; // token storage

// handle API-related functionality
class ApiService {
  // *** NEVER PUSH IP HERE
  static final String baseUrl = "http://localhost:3000";

  // Retrieve the JWT token from SharedPreferences
  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token'); // Get the saved JWT token
  }

  // Logs in or register by sending user info to backend
  Future<String> loginUser(String name, String email, String phone) async {
    final url = Uri.parse('$baseUrl/api/users');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'}, // Postman -> Body -> Raw -> Text: JSON
        body: json.encode({ // Contains Terms for Data Input
          'Name': name,
          'Email': email,
          'Phone': phone,
        }),
      );
      print("Response status: ${response.statusCode}");
      final responseBody = json.decode(response.body); // Backend will pass response.body
      if (responseBody.containsKey('token')) {
        return responseBody['token'];
      } else {
        throw Exception('Token not found in the response');
      }
    } catch (e) {
      print("Error occurred: $e");
      rethrow;
    }
  }

  // Fetch quiz questions and multiple choice
  // Todo: change int grade to a topic (consider environments aren't grades)
  static Future<Map<String, dynamic>?> postQuiz(String topic, String token) async {
    final token = await getToken(); 

    final url = Uri.parse('$baseUrl/api/quiz');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'grade': topic}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to fetch quiz: ${response.body}');
        return null;
      }
    } catch (e) {
      print("Error fetching quiz: $e");
      return null;
    }
  }

  // Still under review
  static Future<Map<String, dynamic>?> submitQuiz(int attemptId, List<int?> selectedAnswers) async {
    final token = await getToken(); 
    final url = Uri.parse('$baseUrl/api/quiz/submit');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'attempt_id': attemptId,
          'selected_answers': selectedAnswers,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to submit quiz: ${response.body}');
        return null;
      }
    } catch (e) {
      print("Error submitting quiz: $e");
      return null;
    }
  }

}
