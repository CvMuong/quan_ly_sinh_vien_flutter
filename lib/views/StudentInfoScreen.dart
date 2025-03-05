import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:quan_ly_diem/models/classModel.dart';
import 'package:quan_ly_diem/models/infoStudentModel.dart';
import '../services/infoStudentService.dart';
import 'EditStudentInfoScreen.dart';

class StudentInfoScreen extends StatefulWidget {
  final int userId;

  const StudentInfoScreen({super.key, required this.userId});

  @override
  State<StudentInfoScreen> createState() => _StudentInfoScreenState();
}

class _StudentInfoScreenState extends State<StudentInfoScreen>
    with SingleTickerProviderStateMixin {
  InfoModel? student;
  ClassModel? className;
  bool isLoading = true;
  String errorMessage = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    fetchStudentData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchStudentData() async {
    try {
      InfoModel fetchedStudent =
      await InfoStudentService.fetchInfoStudent(widget.userId);
      ClassModel fetchedClass =
      await InfoStudentService.fetchClassInfo(fetchedStudent.id_lop);
      setState(() {
        student = fetchedStudent;
        className = fetchedClass;
        isLoading = false;
        _animationController.forward();
      });
    } catch (e) {
      setState(() {
        errorMessage = "Lỗi khi tải dữ liệu: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
        child: Lottie.asset(
          "assets/Lottie/loading1.json",
          width: 120,
          height: 120,
          fit: BoxFit.contain,
        ),
      )
          : student == null || className == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 60, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              errorMessage.isNotEmpty
                  ? errorMessage
                  : "Không có dữ liệu",
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
          ],
        ),
      )
          : Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  height: 250,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ImageFiltered(
                          imageFilter:
                          ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: student!.imageBytes != null
                                    ? MemoryImage(student!.imageBytes!)
                                    : const AssetImage(
                                    "assets/images/logo_1.png")
                                as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                            foregroundDecoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.3),
                                  Colors.black.withOpacity(0.5),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _scaleAnimation.value,
                                  child: Opacity(
                                    opacity: _fadeAnimation.value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 12,
                                            offset: Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        radius: 80,
                                        backgroundColor: Colors.white,
                                        child: CircleAvatar(
                                          radius: 75,
                                          backgroundImage: student!
                                              .imageBytes !=
                                              null
                                              ? MemoryImage(student!
                                              .imageBytes!)
                                              : const AssetImage(
                                              "assets/images/logo_1.png")
                                          as ImageProvider,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            AnimatedBuilder(
                              animation: _fadeAnimation,
                              builder: (context, child) {
                                return Opacity(
                                  opacity: _fadeAnimation.value,
                                  child: Column(
                                    children: [
                                      Text(
                                        student!.ho_ten,
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                                color: Colors.black45,
                                                blurRadius: 6)
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "MSSV: ${student!.mssv}",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white
                                              .withOpacity(0.9),
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 24.0),
                  child: AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Thông tin cá nhân",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Column(
                              children: [
                                buildInfoRow(
                                    Icons.cake,
                                    "Ngày sinh",
                                    student!.ngay_sinh
                                        .substring(0, 10)),
                                buildInfoRow(
                                    Icons.person,
                                    "Giới tính",
                                    student!.gioi_tinh == 1
                                        ? "Nam"
                                        : "Nữ"),
                                buildInfoRow(Icons.location_on,
                                    "Địa chỉ", student!.dia_chi),
                                buildInfoRow(
                                    Icons.email, "Email", student!.email),
                                buildInfoRow(
                                    Icons.phone, "SĐT", student!.sdt),
                                buildInfoRow(Icons.school, "Lớp",
                                    className!.ten_lop),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          // Positioned(
          //   bottom: 24,
          //   right: 24,
          //   child: AnimatedBuilder(
          //     animation: _fadeAnimation,
          //     builder: (context, child) {
          //       return Opacity(
          //         opacity: _fadeAnimation.value,
          //         child: FloatingActionButton(
          //           heroTag:
          //           "editStudentInfo", // Thêm heroTag duy nhất
          //           onPressed: () {
          //             Navigator.push(
          //               context,
          //               MaterialPageRoute(
          //                 builder: (context) => EditStudentInfoScreen(
          //                     student: student!),
          //               ),
          //             );
          //           },
          //           backgroundColor: Colors.transparent,
          //           elevation: 8,
          //           child: Container(
          //             width: 60,
          //             height: 60,
          //             decoration: const BoxDecoration(
          //               shape: BoxShape.circle,
          //               gradient: LinearGradient(
          //                 colors: [Colors.blueAccent, Colors.teal],
          //                 begin: Alignment.topLeft,
          //                 end: Alignment.bottomRight,
          //               ),
          //             ),
          //             child: const Icon(Icons.edit,
          //                 color: Colors.white, size: 28),
          //           ),
          //         ),
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget buildInfoRow(IconData icon, String title, String value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.blueAccent, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}