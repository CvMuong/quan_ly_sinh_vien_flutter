import 'package:flutter/material.dart';
import 'package:quan_ly_diem/services/authService.dart';
import 'package:quan_ly_diem/views/MyApp.dart';
import 'package:quan_ly_diem/views/LoginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  late AnimationController _controller;
  late Animation<double> _scaleAnimation; // Hiệu ứng phóng to logo
  late Animation<double> _fadeAnimation; // Hiệu ứng mờ dần logo

  @override
  void initState() {
    super.initState();

    // Khởi tạo AnimationController
    _controller = AnimationController(
      duration: const Duration(seconds: 2), // Tổng thời gian SplashScreen
      vsync: this,
    );

    // Tạo hiệu ứng phóng to từ 0.5 đến 1.0
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Tạo hiệu ứng mờ dần từ 1.0 về 0.0 cho logo
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn), // Mờ dần từ 70% thời gian
      ),
    );

    // Bắt đầu animation
    _controller.forward();

    // Kiểm tra trạng thái đăng nhập
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();

    if (isLoggedIn) {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      if (userId != null) {
        navigateToHome(userId);
      } else {
        navigateToLogin();
      }
    } else {
      navigateToLogin();
    }
  }

  void navigateToHome(int userId) async {
    // Đợi animation hoàn tất (2 giây)
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              StudentApp(userId: userId),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0); // Bắt đầu từ dưới
            const end = Offset.zero; // Kết thúc ở vị trí mặc định
            final tween = Tween(begin: begin, end: end);
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut, // Đường cong mượt mà
            );
            return SlideTransition(
              position: tween.animate(curvedAnimation),
              child: FadeTransition(
                opacity: animation, // Hiệu ứng mờ dần
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 500), // Thời gian chuyển trang
        ),
      );
    }
  }

  void navigateToLogin() async {
    // Đợi animation hoàn tất (2 giây)
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
          const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0); // Bắt đầu từ dưới
            const end = Offset.zero; // Kết thúc ở vị trí mặc định
            final tween = Tween(begin: begin, end: end);
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut, // Đường cong mượt mà
            );
            return SlideTransition(
              position: tween.animate(curvedAnimation),
              child: FadeTransition(
                opacity: animation, // Hiệu ứng mờ dần
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 500), // Thời gian chuyển trang
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Giải phóng AnimationController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation, // Hiệu ứng mờ dần của logo
          child: ScaleTransition(
            scale: _scaleAnimation, // Hiệu ứng phóng to logo
            child: Image.asset(
              "assets/images/logo_1.png",
              width: 150,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}