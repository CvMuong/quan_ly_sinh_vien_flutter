class SubjectModel {
  final int id_mon_hoc;
  final String ma_mon_hoc;
  final String ten_mon;
  final int so_tc_lt;
  final int so_tc_th;

  SubjectModel({
    required this.id_mon_hoc,
    required this.ma_mon_hoc,
    required this.ten_mon,
    required this.so_tc_lt,
    required this.so_tc_th
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
        id_mon_hoc: json['id_mon_hoc'] is int ? json['id_mon_hoc'] : int.tryParse(json['id_mon_hoc'].toString()) ?? 0,
        ma_mon_hoc: json['ma_mon_hoc'] ?? '',
        ten_mon: json['ten_mon'] ?? '',
        so_tc_lt: json['so_tc_lt'] is int ? json['so_tc_lt'] : int.tryParse(json['so_tc_lt'].toString()) ?? 0,
        so_tc_th: json['so_tc_th'] is int ? json['so_tc_th'] : int.tryParse(json['so_tc_th'].toString()) ?? 0,
    );
  }
}