import 'package:http/http.dart' as http;
import 'package:quan_ly_diem/models/sectionClassModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/calendarModel.dart';
import 'config.dart';
import 'sectionClassService.dart';

class CalendarService {
  static const String baseUrl = Config.baseUrl;
  static final Map<int, LopHocPhanDetails> _cache = {};

  static Future<List<Schedule>> getSchedulesByClassAndDate({required int id_lop}) async {
    final scheduleResponse = await http.get(
      Uri.parse('$baseUrl/schedule/class/$id_lop'),
      headers: {'Authorization': 'Bearer ${await _getToken()}'},
    );

    if (scheduleResponse.statusCode == 200) {
      final List<dynamic> scheduleData = jsonDecode(scheduleResponse.body);
      List<Schedule> schedules = scheduleData.map((json) => Schedule.fromJson(json)).toList();

      for (var schedule in schedules) {
        if (schedule.id_lop_hoc_phan != null) {
          if (_cache.containsKey(schedule.id_lop_hoc_phan)) {
            schedule.lopHocPhanDetails = _cache[schedule.id_lop_hoc_phan];
          } else {
            final lopHocPhanDetails = await _getLopHocPhanDetails(schedule.id_lop_hoc_phan!);
            _cache[schedule.id_lop_hoc_phan!] = lopHocPhanDetails;
            schedule.lopHocPhanDetails = lopHocPhanDetails;
          }
        }
      }
      return schedules;
    } else if (scheduleResponse.statusCode == 404) {
      throw Exception('Schedule not found for id_lop: $id_lop - ${scheduleResponse.body}');
    } else if (scheduleResponse.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or expired token - ${scheduleResponse.body}');
    } else {
      throw Exception('Failed to load schedules: ${scheduleResponse.statusCode} - ${scheduleResponse.body}');
    }
  }

  static Future<LopHocPhanDetails> _getLopHocPhanDetails(int id_lop_hoc_phan) async {
    final response = await http.get(
      Uri.parse('$baseUrl/sectionClass/$id_lop_hoc_phan'),
      headers: {'Authorization': 'Bearer ${await _getToken()}'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      SectionClassModel sectionClass = SectionClassModel.fromJson(data);

      String? monHocName;
      String? giangVienName;
      String? phongName;
      String? msLopHocPhan = sectionClass.ms_lop_hoc_phan; // Lấy mã học phần từ SectionClassModel

      try {
        final results = await Future.wait([
          SectionClassService.fetchSubjectModel(sectionClass.id_mon_hoc)
              .then((subject) => monHocName = subject.ten_mon)
              .catchError((e) => print('Error fetching subject: $e')),
          SectionClassService.fetchTeacherInfo(sectionClass.id_giang_vien)
              .then((teacher) => giangVienName = teacher.ho_ten)
              .catchError((e) => print('Error fetching teacher: $e')),
          SectionClassService.fetchRoomInfo(sectionClass.id_phong)
              .then((room) => phongName = room.ten_phong)
              .catchError((e) => print('Error fetching room: $e')),
        ]);

      } catch (e) {
        print('Error fetching details for lopHocPhan $id_lop_hoc_phan: $e');
      }

      return LopHocPhanDetails(
        id_lop_hoc_phan: sectionClass.id_lop_hoc_phan,
        id_mon_hoc: sectionClass.id_mon_hoc,
        id_giang_vien: sectionClass.id_giang_vien,
        id_phong: sectionClass.id_phong,
        monHoc: monHocName,
        giangVien: giangVienName,
        phong: phongName,
        ms_lop_hoc_phan: msLopHocPhan, // Thêm mã học phần
      );
    } else {
      throw Exception('Failed to load lop_hoc_phan details: ${response.statusCode} - ${response.body}');
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