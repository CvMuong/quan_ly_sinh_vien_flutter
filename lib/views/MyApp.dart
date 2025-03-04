import 'package:flutter/material.dart';
import 'package:quan_ly_diem/models/infoStudentModel.dart';
import 'package:quan_ly_diem/services/authService.dart';
import 'package:quan_ly_diem/services/infoStudentService.dart';
import 'package:quan_ly_diem/views/CalendarScreen.dart';
import 'package:quan_ly_diem/views/RegisterCourseScreen.dart';
import 'package:quan_ly_diem/views/StudentInfoScreen.dart';
import 'FaceScanView.dart';
import 'LoginScreen.dart';
import 'QRScanView.dart';
import 'StudentScoreScreen.dart';

class StudentApp extends StatefulWidget {
  final int userId;

  const StudentApp({super.key, required this.userId});

  @override
  State<StudentApp> createState() => _StudentAppState();
}

class _StudentAppState extends State<StudentApp> {
  int _selectedIndex = 0;
  List<Widget> _screens = [];
  InfoModel? student;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _screens = [
      StudentInfoScreen(userId: widget.userId),
      RegisterCourseScreen(id_sinh_vien: widget.userId),
      StudentScoreScreen(userId: widget.userId),
      CalendarScreen(userId: widget.userId),
    ];
    fetchStudentData();
  }

  Future<void> fetchStudentData() async {
    try {
      InfoModel fetchedStudent = await InfoStudentService.fetchInfoStudent(widget.userId);
      setState(() {
        student = fetchedStudent;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Lỗi khi tải dữ liệu: ${e}";
        isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _scanQRCode() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.5,
            child: QRScanView(
              onQRCodeScanned: (String code) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Mã QR: $code'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Đóng", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _openCameraForFaceRecognition() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FaceScanView(), // Mở FaceScanView full màn hình
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 8,
        shadowColor: Colors.black26,
        centerTitle: true,
        title: const Text(
          'Quản Lý Sinh Viên',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 23,
            letterSpacing: 1.2,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xff6A82FB), Color(0xffFC5C7D)],
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 28,
              ),
              tooltip: 'Xem gương mặt',
              onPressed: _openCameraForFaceRecognition,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _selectedIndex == 0
                ? IconButton(
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () {
                showMenu(
                  context: context,
                  position: const RelativeRect.fromLTRB(100, 80, 0, 0),
                  items: [
                    PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Đăng xuất',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 8,
                  color: Colors.white,
                ).then((value) {
                  if (value == 'logout') {
                    _showLogoutDialog(context);
                  }
                });
              },
            )
                : PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  _showLogoutDialog(context);
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.redAccent, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'Đăng xuất',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ];
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 8,
              color: Colors.white,
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: student?.imageBytes != null
                    ? CircleAvatar(
                  radius: 20,
                  backgroundImage: MemoryImage(student!.imageBytes!),
                )
                    : const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _screens[_selectedIndex],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanQRCode,
        backgroundColor: const Color(0xffFC5C7D),
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const Icon(
          Icons.qr_code_scanner,
          color: Colors.white,
          size: 30,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 70,
        color: const Color(0xff2A2D3E),
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.0,
        elevation: 12,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.person, 'Thông tin', 0),
            _buildNavItem(Icons.book, 'Đăng ký', 1),
            const SizedBox(width: 60),
            _buildNavItem(Icons.score, 'Xem điểm', 2),
            _buildNavItem(Icons.calendar_today, 'Lịch học', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _selectedIndex == index ? Colors.white.withOpacity(0.2) : Colors.transparent,
              ),
              child: Icon(
                icon,
                color: _selectedIndex == index ? Colors.blueAccent : Colors.white70,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _selectedIndex == index ? Colors.blueAccent : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final authService = AuthService();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Xác nhận đăng xuất", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("Bạn có chắc chắn muốn đăng xuất?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                await authService.logout();
                Navigator.of(context).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (Route<dynamic> route) => false,
                );
              },
              child: const Text("Đăng xuất", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}