// services/sectionClassService.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quan_ly_diem/models/studentStudySectionModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quan_ly_diem/models/roomModel.dart';
import 'package:quan_ly_diem/models/subjectModel.dart';
import 'package:quan_ly_diem/models/teacherModel.dart';
import 'package:quan_ly_diem/services/config.dart';
import '../models/sectionClassModel.dart';

class SectionClassService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<List<SectionClassModel>> getUnenrolledCourseSections({
    required int id_sinh_vien,
    required int id_hoc_ky,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Token not found in SharedPreferences');
      }

      final response = await http.get(
        Uri.parse('${Config.baseUrl}/sectionClass/semester-not-student/$id_hoc_ky/$id_sinh_vien'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        List<SectionClassModel> sections = data.map((json) => SectionClassModel.fromJson(json)).toList();

        // Lấy thông tin bổ sung cho từng lớp học phần
        await Future.wait(sections.map((section) async {
          try {
            await Future.wait([
              fetchSubjectModel(section.id_mon_hoc).then((s) => section.subject = s),
              fetchTeacherInfo(section.id_giang_vien).then((t) => section.teacher = t),
              fetchRoomInfo(section.id_phong).then((r) => section.room = r),
            ]);
          } catch (e) {
            print('Error fetching additional info for section ${section.id_lop_hoc_phan}: $e');
          }
        }));

        return sections;
      } else {
        throw Exception('Failed to load unenrolled course sections: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching unenrolled course sections: $e');
    }
  }

  static Future<List<SectionClassModel>> getEnrolledCourseSections({
    required int id_sinh_vien,
    required int id_hoc_ky,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Token not found in SharedPreferences');
      }

      final response = await http.get(
        Uri.parse('${Config.baseUrl}/sectionClass/semester-student/$id_hoc_ky/$id_sinh_vien'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        List<SectionClassModel> sections = data.map((json) => SectionClassModel.fromJson(json)).toList();

        // Lấy thông tin bổ sung cho từng lớp học phần
        await Future.wait(sections.map((section) async {
          try {
            await Future.wait([
              fetchSubjectModel(section.id_mon_hoc).then((s) => section.subject = s),
              fetchTeacherInfo(section.id_giang_vien).then((t) => section.teacher = t),
              fetchRoomInfo(section.id_phong).then((r) => section.room = r),
              fetchStudentStudySection(section.id_sv_hoc_hp).then((g) => section.score = g),
            ]);
          } catch (e) {
            print('Error fetching additional info for section ${section.id_lop_hoc_phan}: $e');
          }
        }));

        return sections;
      } else {
        throw Exception('Failed to load enrolled course sections: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching enrolled course sections: $e');
    }
  }

  static Future<SubjectModel> fetchSubjectModel(int id_mon_hoc) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token not found in SharedPreferences');
    }

    final response = await http.get(
      Uri.parse('${Config.baseUrl}/subject/$id_mon_hoc'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return SubjectModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Không thể tải thông tin môn học: ${response.statusCode}');
    }
  }

  static Future<TeacherModel> fetchTeacherInfo(int id_giang_vien) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token not found in SharedPreferences');
    }

    final response = await http.get(
      Uri.parse('${Config.baseUrl}/teacher/$id_giang_vien'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return TeacherModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Không thể tải thông tin giảng viên: ${response.statusCode}');
    }
  }

  static Future<RoomModel> fetchRoomInfo(int id_phong) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token not found in SharedPreferences');
    }

    final response = await http.get(
      Uri.parse('${Config.baseUrl}/room/$id_phong'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return RoomModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Không thể tải thông tin phòng học: ${response.statusCode}');
    }
  }

  static Future<StudentStudySectionModel> fetchStudentStudySection(int id_sv_hoc_hp) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token not found in SharedPreferences');
    }

    final response = await http.get(
      Uri.parse('${Config.baseUrl}/studentStudySection/$id_sv_hoc_hp'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print('body ${response.body}');
      return StudentStudySectionModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Không thể tải thông tin phòng học: ${response.statusCode}');
    }
  }
}