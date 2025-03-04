// models/study_section_model.dart
class StudentStudySectionModel {
  final int idSinhVien;
  final int idLopHocPhan;
  final String ngayDangKy;
  final int thu;
  final double? diemGiuaKy;
  final double? diemCuoiKy;
  final double? diemTongKet;

  StudentStudySectionModel({
    required this.idSinhVien,
    required this.idLopHocPhan,
    required this.ngayDangKy,
    required this.thu,
    this.diemGiuaKy,
    this.diemCuoiKy,
    this.diemTongKet,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_sinh_vien': idSinhVien,
      'id_lop_hoc_phan': idLopHocPhan,
      'ngay_dang_ky': ngayDangKy,
      'thu': thu,
      'diem_giua_ky': diemGiuaKy,
      'diem_cuoi_ky': diemCuoiKy,
      'diem_tong_ket': diemTongKet,
    };
  }

  factory StudentStudySectionModel.fromJson(Map<String, dynamic> json) {
    return StudentStudySectionModel(
      idSinhVien: json['id_sinh_vien'] ?? 0,
      idLopHocPhan: json['id_lop_hoc_phan'] ?? 0,
      ngayDangKy: json['ngay_dang_ky'] ?? '',
      thu: json['thu'],
      diemGiuaKy: double.tryParse(json['diem_giua_ky']?.toString() ?? '0') ?? 0.0,
      diemCuoiKy: double.tryParse(json['diem_cuoi_ky']?.toString() ?? '0') ?? 0.0,
      diemTongKet: double.tryParse(json['diem_tong_ket']?.toString() ?? '0') ?? 0.0,
    );
  }
}