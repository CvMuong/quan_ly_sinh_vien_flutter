import 'dart:convert';
import 'dart:typed_data';

class InfoModel {
  final int id_sinh_vien;
  final String mssv;
  final String ho_ten;
  final String ngay_sinh;
  final int gioi_tinh;
  final String dia_chi;
  final String email;
  final String sdt;
  final int id_lop;
  final Uint8List? imageBytes;

  InfoModel({
    required this.id_sinh_vien,
    required this.mssv,
    required this.ho_ten,
    required this.ngay_sinh,
    required this.gioi_tinh,
    required this.dia_chi,
    required this.email,
    required this.sdt,
    required this.id_lop,
    required this.imageBytes,
  });

  /// Chuyển dữ liệu từ JSON thành đối tượng InfoModel
  factory InfoModel.fromJson(Map<String, dynamic> json) {
    Uint8List? bytes;
    if (json['image'] != null && json['image']['data'] != null) {
      List<dynamic> data = json['image']['data'];
      bytes = Uint8List.fromList(data.cast<int>());
    }

    return InfoModel(
      id_sinh_vien: json['id_sinh_vien'] is int
          ? json['id_sinh_vien']
          : int.tryParse(json['id_sinh_vien'].toString()) ?? 0,
      mssv: json['mssv'] ?? '',
      ho_ten: json['ho_ten'] ?? '',
      ngay_sinh: json['ngay_sinh'] ?? '',
      gioi_tinh: json['gioi_tinh'] ?? 0,
      dia_chi: json['dia_chi'] ?? '',
      email: json['email'] ?? '',
      sdt: json['sdt'] ?? '',
      id_lop: json['id_lop'] is int
          ? json['id_lop']
          : int.tryParse(json['id_lop'].toString()) ?? 0,
      imageBytes: bytes,
    );
  }

  /// Chuyển đối tượng InfoModel thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id_sinh_vien': id_sinh_vien,
      'mssv': mssv,
      'ho_ten': ho_ten,
      'ngay_sinh': ngay_sinh,
      'gioi_tinh': gioi_tinh,
      'dia_chi': dia_chi,
      'email': email,
      'sdt': sdt,
      'id_lop': id_lop,
      'image': imageBytes != null
          ? base64Encode(imageBytes!)
          : null,
    };
  }

  /// Chuyển một chuỗi JSON thành đối tượng InfoModel
  static InfoModel fromSingleJson(String responseBody) {
    final Map<String, dynamic> parsed = jsonDecode(responseBody);
    return InfoModel.fromJson(parsed);
  }
}
