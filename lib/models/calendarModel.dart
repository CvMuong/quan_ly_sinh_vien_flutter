class LopHocPhanDetails {
  final int? id_lop_hoc_phan;
  final int? id_phong;
  final int? id_giang_vien;
  final int? id_mon_hoc;
  String? phong;
  String? giangVien;
  String? monHoc;
  String? ms_lop_hoc_phan; // Thêm trường này

  LopHocPhanDetails({
    this.id_lop_hoc_phan,
    this.id_phong,
    this.id_giang_vien,
    this.id_mon_hoc,
    this.phong,
    this.giangVien,
    this.monHoc,
    this.ms_lop_hoc_phan,
  });

  factory LopHocPhanDetails.fromJson(Map<String, dynamic> json) {
    return LopHocPhanDetails(
      id_lop_hoc_phan: json['id_lop_hoc_phan'] as int?,
      id_phong: json['id_phong'] as int?,
      id_giang_vien: json['id_giang_vien'] as int?,
      id_mon_hoc: json['id_mon_hoc'] as int?,
      phong: json['phong'] as String?,
      giangVien: json['giangVien'] as String?,
      monHoc: json['monHoc'] as String?,
      ms_lop_hoc_phan: json['ms_lop_hoc_phan'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_lop_hoc_phan': id_lop_hoc_phan,
      'id_phong': id_phong,
      'id_giang_vien': id_giang_vien,
      'id_mon_hoc': id_mon_hoc,
      'phong': phong,
      'giangVien': giangVien,
      'monHoc': monHoc,
      'ms_lop_hoc_phan': ms_lop_hoc_phan,
    };
  }
}

class Schedule {
  final int? id_lich_hoc;
  final String? ngay;
  final int? session;
  final int? id_lop_hoc_phan;
  final int? tu_tiet;
  final int? den_tiet;
  final int? loai;
  LopHocPhanDetails? lopHocPhanDetails;

  Schedule({
    this.id_lich_hoc,
    this.ngay,
    this.session,
    this.id_lop_hoc_phan,
    this.tu_tiet,
    this.den_tiet,
    this.loai,
    this.lopHocPhanDetails,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id_lich_hoc: json['id_lich_hoc'] as int?,
      ngay: json['ngay'] as String?,
      session: json['session'] as int?,
      id_lop_hoc_phan: json['id_lop_hoc_phan'] as int?,
      tu_tiet: json['tu_tiet'] as int?,
      den_tiet: json['den_tiet'] as int?,
      loai: json['loai'] as int?,
      lopHocPhanDetails: json['lopHocPhanDetails'] != null
          ? LopHocPhanDetails.fromJson(json['lopHocPhanDetails'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_lich_hoc': id_lich_hoc,
      'ngay': ngay,
      'session': session,
      'id_lop_hoc_phan': id_lop_hoc_phan,
      'tu_tiet': tu_tiet,
      'den_tiet': den_tiet,
      'loai': loai,
      'lopHocPhanDetails': lopHocPhanDetails?.toJson(),
    };
  }
}