import 'package:get/get.dart';
import 'package:quan_ly_diem/controllers/sectionClassController.dart';
import 'package:quan_ly_diem/models/studentStudySectionModel.dart';
import 'package:quan_ly_diem/services/authService.dart';
import 'package:quan_ly_diem/services/studentStudySection.dart';
import '../models/sectionClassModel.dart';

class StudentStudySectionController extends GetxController {
  final SectionClassController sectionClassController = Get.find<SectionClassController>();
  final AuthService authService = AuthService();

  Future<void> registerCourse({
    required int idSinhVien,
    required SectionClassModel section,
  }) async {
    try {
      final token = await authService.getToken();
      if (token == null) {
        throw Exception('Token not found');
      }

      final studySection = StudentStudySectionModel(
        idSinhVien: idSinhVien,
        idLopHocPhan: section.id_lop_hoc_phan,
        ngayDangKy: DateTime.now().toIso8601String().split('T')[0],
        thu: 0,
        diemGiuaKy: null,
        diemCuoiKy: null,
        diemTongKet: null,
      );

      await StudentStudySectionService.registerStudySection(studySection);

      sectionClassController.unenrolledCourseSections.remove(section);
      sectionClassController.enrolledCourseSections.add(section.copyWith(isSelected: true));
    } catch (e) {
      throw Exception('Error registering course: $e');
    }
  }

  Future<void> cancelCourse({
    required int id_sv_hoc_hp,
  }) async {
    try {
      await StudentStudySectionService.deleteStudySection(id_sv_hoc_hp);
    } catch (e) {
      throw Exception('Error canceling course: $e');
    }
  }
}