import 'package:get/get.dart';
import '../models/sectionClassModel.dart';
import '../services/sectionClassService.dart';

class SectionClassController extends GetxController {
  RxList<SectionClassModel> enrolledCourseSections = <SectionClassModel>[].obs;
  RxList<SectionClassModel> unenrolledCourseSections = <SectionClassModel>[].obs;
  RxBool isLoadingUnenrolled = false.obs;
  RxBool isLoadingEnrolled = false.obs;
  RxString errorMessage = ''.obs;

  Future<void> fetchUnenrolledCourseSections({
    required int idSinhVien,
    required int idHocKy,
  }) async {
    try {
      isLoadingUnenrolled.value = true;
      errorMessage.value = '';
      unenrolledCourseSections.clear();

      // Gọi trực tiếp hàm static
      final result = await SectionClassService.getUnenrolledCourseSections(
        id_sinh_vien: idSinhVien,
        id_hoc_ky: idHocKy,
      );

      unenrolledCourseSections.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoadingUnenrolled.value = false;
    }
  }

  Future<void> fetchEnrolledCourseSections({
    required int idSinhVien,
    required int idHocKy,
  }) async {
    try {
      isLoadingEnrolled.value = true;
      errorMessage.value = '';
      enrolledCourseSections.clear();

      final result = await SectionClassService.getEnrolledCourseSections(
        id_sinh_vien: idSinhVien,
        id_hoc_ky: idHocKy,
      );

      enrolledCourseSections.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoadingEnrolled.value = false;
    }
  }

  List<int> getEnrolledClassIds() {
    return enrolledCourseSections.map((section) => section.id_lop_hoc_phan).toList();
  }
}