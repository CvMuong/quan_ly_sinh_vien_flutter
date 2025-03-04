// services/study_section_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quan_ly_diem/services/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/studentStudySectionModel.dart';

class StudentStudySectionService {
  static Future<void> registerStudySection(StudentStudySectionModel studentStudySection) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        throw Exception('Token not found in SharedPreferences');
      }
      print('token: ${token}');
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/studentStudySection/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token
        },
        body: jsonEncode(studentStudySection.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Thành công
        return;
      } else {
        throw Exception('Failed to register study section: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error registering study section: $e');
    }
  }

  static Future<void> deleteStudySection(int id_sv_hoc_hp) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        throw Exception('Token not found in SharedPreferences');
      }

      final response = await http.delete(
        Uri.parse('${Config.baseUrl}/studentStudySection/delete/${id_sv_hoc_hp}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token
        },
      );

      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception('Failed to delete study section: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting study section: $e');
    }
  }
}