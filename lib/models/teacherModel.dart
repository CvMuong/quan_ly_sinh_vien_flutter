class TeacherModel {
  final int id_giang_vien;
  final String msgv;
  final String ho_ten;

  TeacherModel({
    required this.id_giang_vien,
    required this.msgv,
    required this.ho_ten
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
        id_giang_vien: json['id_giang_vien'] is int ? json['id_giang_vien'] : int.tryParse(json['id_giang_vien'].toString()) ?? 0,
        msgv: json['msgv'] ?? '',
        ho_ten: json['ho_ten'] ?? ''
    );
  }
}