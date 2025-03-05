import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quan_ly_diem/services/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FaceApiService {
  static const String apiUrl = '${Config.baseUrl}/face';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Map<String, dynamic>?> detectFace(String base64Image) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Token not found in SharedPreferences');
      }

      final response = await http.post(
        Uri.parse('$apiUrl/detect'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'image': base64Image}),
      );

      if (response.statusCode == 200) {
        print("response: ${response.body}");
        return jsonDecode(response.body);
      } else {
        print('Lỗi từ server: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Lỗi khi gửi yêu cầu nhận diện: $e');
      return null;
    }
  }
}