class ClassModel {
  final int id_lop;
  final String ten_lop;

  ClassModel({
    required this.id_lop,
    required this.ten_lop,
  });

  /// Chuyển đối tượng ClassModel thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id_lop': id_lop,
      'ten_lop': ten_lop,
    };
  }

  /// Chuyển JSON thành đối tượng ClassModel
  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id_lop: json['id_lop'] is int
          ? json['id_lop']
          : int.tryParse(json['id_lop'].toString()) ?? 0,
      ten_lop: json['ten_lop'] ?? '',
    );
  }
}
