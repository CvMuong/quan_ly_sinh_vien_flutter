import 'package:get/get.dart';
import 'package:quan_ly_diem/models/infoStudentModel.dart';
import 'package:quan_ly_diem/services/infoStudentService.dart';

class InfoStudentController extends GetxController {
  Rx<InfoModel?> student = Rx<InfoModel?>(null);
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  Future<void> updateStudentInfo({
    required int idSinhVien,
    required String hoTen,
    required String email,
    required String sdt,
    required String diaChi,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      InfoModel updatedStudent = InfoModel(
        id_sinh_vien: idSinhVien,
        mssv: student.value!.mssv,
        ho_ten: hoTen,
        ngay_sinh: student.value!.ngay_sinh,
        gioi_tinh: student.value!.gioi_tinh,
        dia_chi: diaChi,
        email: email,
        sdt: sdt,
        id_lop: student.value!.id_lop,
        imageBytes: student.value!.imageBytes, // Giữ nguyên ảnh hiện tại
      );

      await InfoStudentService.updateStudentInfo(updatedStudent);
      student.value = updatedStudent;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchStudentInfo(int userId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final fetchedStudent = await InfoStudentService.fetchInfoStudent(userId);
      student.value = fetchedStudent;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}