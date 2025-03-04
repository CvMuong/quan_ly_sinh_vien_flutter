import 'package:quan_ly_diem/models/roomModel.dart';
import 'package:quan_ly_diem/models/studentStudySectionModel.dart';
import 'package:quan_ly_diem/models/subjectModel.dart';
import 'package:quan_ly_diem/models/teacherModel.dart';

class SectionClassModel {
  final int id_lop_hoc_phan;
  final int id_mon_hoc;
  final int id_giang_vien;
  final int id_phong;
  final int id_hoc_ky;
  final int? id_lop;
  final int tong_so_tiet;
  final int hoc_phi;
  final int id_sv_hoc_hp;
  final String? ms_lop_hoc_phan; // Thêm trường này
  bool isSelected;
  SubjectModel? subject;
  TeacherModel? teacher;
  RoomModel? room;
  StudentStudySectionModel? score;

  SectionClassModel({
    required this.id_lop_hoc_phan,
    required this.id_mon_hoc,
    required this.id_giang_vien,
    required this.id_phong,
    required this.id_hoc_ky,
    this.id_lop,
    required this.tong_so_tiet,
    required this.hoc_phi,
    required this.id_sv_hoc_hp,
    this.ms_lop_hoc_phan,
    this.isSelected = false,
    this.subject,
    this.teacher,
    this.room,
    this.score
  });

  factory SectionClassModel.fromJson(Map<String, dynamic> json) {
    return SectionClassModel(
      id_lop_hoc_phan: json['id_lop_hoc_phan'] is int
          ? json['id_lop_hoc_phan']
          : int.tryParse(json['id_lop_hoc_phan'].toString()) ?? 0,
      id_mon_hoc: json['id_mon_hoc'] is int
          ? json['id_mon_hoc']
          : int.tryParse(json['id_mon_hoc'].toString()) ?? 0,
      id_giang_vien: json['id_giang_vien'] is int
          ? json['id_giang_vien']
          : int.tryParse(json['id_giang_vien'].toString()) ?? 0,
      id_phong: json['id_phong'] is int
          ? json['id_phong']
          : int.tryParse(json['id_phong'].toString()) ?? 0,
      id_hoc_ky: json['id_hoc_ky'] is int
          ? json['id_hoc_ky']
          : int.tryParse(json['id_hoc_ky'].toString()) ?? 0,
      id_sv_hoc_hp: json['id_sv_hoc_hp'] is int
          ? json['id_sv_hoc_hp']
          : int.tryParse(json['id_sv_hoc_hp'].toString()) ?? 0,
      id_lop: json['id_lop'] is int
          ? json['id_lop']
          : int.tryParse(json['id_lop'].toString()),
      tong_so_tiet: json['tong_so_tiet'] is int
          ? json['tong_so_tiet']
          : int.tryParse(json['tong_so_tiet'].toString()) ?? 0,
      hoc_phi: json['hoc_phi'] is int
          ? json['hoc_phi']
          : int.tryParse(json['hoc_phi'].toString()) ?? 0,
      ms_lop_hoc_phan: json['ms_lop_hoc_phan'] as String?,
      isSelected: false,
    );
  }

  SectionClassModel copyWith({
    int? id_lop_hoc_phan,
    int? id_mon_hoc,
    int? id_giang_vien,
    int? id_phong,
    int? id_hoc_ky,
    int? id_lop,
    int? tong_so_tiet,
    int? hoc_phi,
    int? id_sv_hoc_hp,
    String? ms_lop_hoc_phan,
    bool? isSelected,
  }) {
    return SectionClassModel(
      id_lop_hoc_phan: id_lop_hoc_phan ?? this.id_lop_hoc_phan,
      id_mon_hoc: id_mon_hoc ?? this.id_mon_hoc,
      id_giang_vien: id_giang_vien ?? this.id_giang_vien,
      id_phong: id_phong ?? this.id_phong,
      id_hoc_ky: id_hoc_ky ?? this.id_hoc_ky,
      id_lop: id_lop ?? this.id_lop,
      tong_so_tiet: tong_so_tiet ?? this.tong_so_tiet,
      hoc_phi: hoc_phi ?? this.hoc_phi,
      id_sv_hoc_hp: id_lop_hoc_phan ?? this.id_sv_hoc_hp,
      ms_lop_hoc_phan: ms_lop_hoc_phan ?? this.ms_lop_hoc_phan,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}