class SemesterModel {
  final int id_hoc_ky;
  final String ten_hoc_ky;
  final String nien_khoa;

  SemesterModel({
    required this.id_hoc_ky,
    required this.ten_hoc_ky,
    required this.nien_khoa
  });

  factory SemesterModel.fromJson(Map<String, dynamic> json) {
    return SemesterModel(
        id_hoc_ky: json['id_hoc_ky'] is int ? json['id_hoc_ky'] : int.tryParse(json['id_hoc_ky'].toString()) ?? 0,
        ten_hoc_ky: json['ten_hoc_ky'],
        nien_khoa: json['nien_khoa']
    );
  }
}