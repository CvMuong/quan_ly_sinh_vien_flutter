import 'dart:convert';

import 'package:quan_ly_diem/models/classModel.dart';
import 'package:quan_ly_diem/models/infoStudentModel.dart';
import 'package:http/http.dart' as http;
import 'package:quan_ly_diem/services/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InfoStudentService {
  static Future<InfoModel> fetchInfoStudent(int userId) async {
    final response = await http.get(Uri.parse('${Config.baseUrl}/student/${userId}'));

    if (response.statusCode == 200) {
      return InfoModel.fromSingleJson(response.body);
    } else {
      throw Exception('Không thể tải thông tin sinh viên');
    }
  }

  static Future<ClassModel> fetchClassInfo(int id_lop) async {
    final response = await http.get(Uri.parse('${Config.baseUrl}/class/${id_lop}'));

    if (response.statusCode == 200) {
      return ClassModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Không thể tải thông tin lớp');
    }
  }

  static Future<void> updateStudentInfo(InfoModel student) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token không tồn tại trong SharedPreferences');
    }

    final response = await http.put(
      Uri.parse('${Config.baseUrl}/student/update/${student.id_sinh_vien}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(student.toJson()),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      print('${response.statusCode} - ${response.body}');
      throw Exception('Không thể cập nhật thông tin sinh viên: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found');
    }
    return token;
  }
}
