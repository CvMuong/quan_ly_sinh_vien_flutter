import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quan_ly_diem/services/config.dart';
import '../models/semesterModel.dart';

class SemesterService {
  static Future<List<SemesterModel>> fetchSemesters() async {
    final response = await http.get(Uri.parse('${Config.baseUrl}/semester/list'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => SemesterModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load semesters');
    }
  }
}
