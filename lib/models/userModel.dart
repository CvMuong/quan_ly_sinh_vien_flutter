class User {
  final int id;
  final String username;
  final String vaiTro;
  final String token;

  User({
    required this.id,
    required this.username,
    required this.vaiTro,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json, String token) {
    return User(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      username: json['username'] ?? '',
      vaiTro: json['vai_tro'] ?? '',
      token: token,
    );
  }
}
