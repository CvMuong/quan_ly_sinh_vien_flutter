import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:quan_ly_diem/models/login_request.dart';
import 'package:quan_ly_diem/services/config.dart';

class ApiService {
  Future<Map<String, dynamic>> login(LoginRequest loginRequest) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/account/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(loginRequest.toJson()),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? error['message'] ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception('Failed to login: ${e.toString()}');
    }
  }
}
