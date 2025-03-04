import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/classModel.dart';
import '../models/infoStudentModel.dart';

Future<void> cacheStudentData(InfoModel student) async {
  final prefs = await SharedPreferences.getInstance();
  String jsonData = jsonEncode(student.toJson());
  await prefs.setString('cached_student_data', jsonData);
}

Future<InfoModel?> getCachedStudentData() async {
  final prefs = await SharedPreferences.getInstance();
  String? jsonData = prefs.getString('cached_student_data');
  if (jsonData != null) {
    return InfoModel.fromJson(jsonDecode(jsonData));
  }
  return null;
}

Future<void> cacheClassData(ClassModel classModel) async {
  final prefs = await SharedPreferences.getInstance();
  String jsonData = jsonEncode(classModel.toJson());
  await prefs.setString('cached_class_data', jsonData);
}

Future<ClassModel?> getCachedClassData() async {
  final prefs = await SharedPreferences.getInstance();
  String? jsonData = prefs.getString('cached_class_data');
  if (jsonData != null) {
    return ClassModel.fromJson(jsonDecode(jsonData));
  }
  return null;
}




