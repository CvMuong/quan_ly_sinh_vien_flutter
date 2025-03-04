class RoomModel {
  final int id_phong;
  final String ten_phong;
  final int so_cho;

  RoomModel({
    required this.id_phong,
    required this.ten_phong,
    required this.so_cho
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
        id_phong: json['id_phong'] is int ? json['id_phong'] : int.tryParse(json['id_phong'].toString()) ?? 0,
        ten_phong: json['ten_phong'] ?? '',
        so_cho: json['so_cho'] is int ? json['so_cho'] : int.tryParse(json['so_cho'].toString()) ?? 0
    );
  }
}