import 'package:quan_ly_diem/services/authService.dart';

class LoginController {
  final AuthService _authService;

  LoginController({AuthService? authService})
      : _authService = authService ?? AuthService();

  Future<void> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      throw Exception('Username and password are required');
    }

    try {
      await _authService.login(username, password);
    } catch (e) {
      rethrow;
    }
  }
}
