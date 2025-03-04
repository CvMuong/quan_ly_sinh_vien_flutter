import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quan_ly_diem/models/login_request.dart';
import 'package:quan_ly_diem/models/userModel.dart';
import 'package:quan_ly_diem/services/apiService.dart';

class AuthService {
  final ApiService _apiService;
  User? _currentUser;

  AuthService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  User? get currentUser => _currentUser;

  // Đăng nhập và lưu token
  Future<User> login(String username, String password) async {
    try {
      final loginRequest = LoginRequest(
        username: username,
        password: password,
      );

      final response = await _apiService.login(loginRequest);
      final token = response['token'];

      // Lưu token vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      // Giải mã JWT để lấy thông tin người dùng
      final parts = token.split('.');
      if (parts.length != 3) throw Exception('Invalid token');

      final payload = json
          .decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
      );

      final userId = payload['id_author'];
      await prefs.setInt('user_id', userId);

      _currentUser = User.fromJson(payload, token);
      print('token: ${token}');
      return _currentUser!;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _currentUser = null;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
