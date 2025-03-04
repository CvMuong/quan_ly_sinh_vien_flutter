import 'package:flutter/material.dart';
import 'package:quan_ly_diem/models/semesterModel.dart';
import 'package:quan_ly_diem/services/semesterService.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controllers/sectionClassController.dart';
import '../controllers/studentStudySectionController.dart';
import '../models/sectionClassModel.dart';
import 'package:intl/intl.dart';

class RegisterCourseScreen extends StatefulWidget {
  final int id_sinh_vien;

  RegisterCourseScreen({required this.id_sinh_vien});

  @override
  State<RegisterCourseScreen> createState() => _RegisterCourseScreenState();
}

class _RegisterCourseScreenState extends State<RegisterCourseScreen> with SingleTickerProviderStateMixin {
  String? selectedYear;
  String? selectedType = 'Học mới';
  List<SemesterModel> semesters = [];
  bool isLoading = true;
  late TabController _tabController;

  final SectionClassController sectionClassController = Get.put(SectionClassController());
  final StudentStudySectionController studySectionController = Get.put(StudentStudySectionController());
  final NumberFormat numberFormat = NumberFormat('#,###', 'vi_VN');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSemesters();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadSemesters() async {
    List<SemesterModel> fetchedSemesters = await SemesterService.fetchSemesters();
    setState(() {
      semesters = fetchedSemesters;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
        child: Lottie.asset(
          'assets/Lottie/loading1.json',
          width: 100,
          height: 100,
          fit: BoxFit.contain,
        ),
      )
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đăng Ký Học Phần',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent.shade700,
                ),
              ),
              SizedBox(height: 20),
              _buildDropdownSection(
                title: 'Chọn học kỳ',
                value: selectedYear,
                items: semesters.map((semester) {
                  return DropdownMenuItem(
                    value: semester.id_hoc_ky.toString(),
                    child: Text('${semester.ten_hoc_ky} ${semester.nien_khoa}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedYear = value;
                    if (value != null) {
                      sectionClassController.fetchUnenrolledCourseSections(
                        idSinhVien: widget.id_sinh_vien,
                        idHocKy: int.parse(value),
                      );
                      sectionClassController.fetchEnrolledCourseSections(
                        idSinhVien: widget.id_sinh_vien,
                        idHocKy: int.parse(value),
                      );
                    }
                  });
                },
              ),
              SizedBox(height: 16),
              _buildDropdownSection(
                title: 'Loại đăng ký',
                value: selectedType,
                items: [
                  DropdownMenuItem(value: 'Học mới', child: Text('Học mới')),
                  DropdownMenuItem(value: 'Học lại', child: Text('Học lại')),
                  DropdownMenuItem(value: 'Học cải thiện', child: Text('Học cải thiện')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedType = value;
                  });
                },
              ),
              SizedBox(height: 20),
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.orangeAccent,
                labelColor: Colors.blueAccent.shade700,
                unselectedLabelColor: Colors.grey.shade600,
                labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                tabs: [
                  Tab(text: 'Đăng ký môn học'),
                  Tab(text: 'Môn học đã đăng ký'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRegisterTab(),
                    _buildRegisteredTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownSection({
    required String title,
    required String? value,
    required List<DropdownMenuItem<String?>> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.blueAccent.shade700,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonFormField<String?>(
            value: value,
            items: [
              DropdownMenuItem(value: null, child: Text('Chọn một tùy chọn')),
              ...items,
            ],
            onChanged: onChanged,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: TextStyle(color: Colors.black87, fontSize: 16),
            dropdownColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterTab() {
    if (selectedYear == null) {
      return Center(
        child: Text(
          'Vui lòng chọn học kỳ để xem danh sách môn học',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Obx(() {
              if (sectionClassController.isLoadingUnenrolled.value) {
                return Center(
                  child: Lottie.asset(
                    'assets/Lottie/loading.json',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                );
              }
              if (sectionClassController.errorMessage.isNotEmpty) {
                return Center(
                  child: Text(
                    sectionClassController.errorMessage.value,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                  ),
                );
              }
              if (sectionClassController.unenrolledCourseSections.isEmpty) {
                return Center(
                  child: Text(
                    'Không có môn học nào để đăng ký',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                  ),
                );
              }

              return ListView.builder(
                itemCount: sectionClassController.unenrolledCourseSections.length,
                itemBuilder: (context, index) {
                  final section = sectionClassController.unenrolledCourseSections[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    color: Colors.white,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _showCourseDetails(context, section),
                      child: ListTile(
                        leading: Icon(Icons.book, color: Colors.blueAccent, size: 30),
                        title: Text(
                          '${section.subject?.ten_mon}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          'Học phí: ${numberFormat.format(section.hoc_phi)} VNĐ',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                        trailing: Checkbox(
                          value: section.isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              sectionClassController.unenrolledCourseSections[index].isSelected = value ?? false;
                            });
                          },
                          activeColor: Colors.orangeAccent,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: _confirmRegistration,
              child: Text(
                'Xác Nhận Đăng Ký',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisteredTab() {
    if (selectedYear == null) {
      return Center(
        child: Text(
          'Vui lòng chọn học kỳ để xem danh sách môn học',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Obx(() {
        if (sectionClassController.isLoadingEnrolled.value) {
          return Center(
            child: Lottie.asset(
              'assets/Lottie/loading.json',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
          );
        }
        if (sectionClassController.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              sectionClassController.errorMessage.value,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
            ),
          );
        }
        if (sectionClassController.enrolledCourseSections.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, color: Colors.grey.shade600, size: 50),
                SizedBox(height: 10),
                Text(
                  'Chưa có khóa học nào được đăng ký!',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 18),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: sectionClassController.enrolledCourseSections.length,
          itemBuilder: (context, index) {
            final section = sectionClassController.enrolledCourseSections[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              color: Colors.white,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showCourseDetails(context, section),
                child: ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green, size: 30),
                  title: Text(
                    '${section.subject?.ten_mon}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  subtitle: Text(
                    'Học phí: ${numberFormat.format(section.hoc_phi)} VNĐ',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.cancel, color: Colors.redAccent),
                    onPressed: () async {
                      if (section.id_sv_hoc_hp != null) {
                        try {
                          await studySectionController.cancelCourse(
                            id_sv_hoc_hp: section.id_sv_hoc_hp!,
                          );
                          if (selectedYear != null) {
                            await sectionClassController.fetchEnrolledCourseSections(
                              idSinhVien: widget.id_sinh_vien,
                              idHocKy: int.parse(selectedYear!),
                            );
                            await sectionClassController.fetchUnenrolledCourseSections(
                              idSinhVien: widget.id_sinh_vien,
                              idHocKy: int.parse(selectedYear!),
                            );
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Đã hủy học phần ${section.subject?.ten_mon}!'),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Lỗi khi hủy học phần: $e'),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Không tìm thấy ID đăng ký học phần!'),
                            backgroundColor: Colors.orange,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _confirmRegistration() async {
    if (selectedYear != null) {
      final selectedSections = sectionClassController.unenrolledCourseSections.where((section) => section.isSelected).toList();
      if (selectedSections.isNotEmpty) {
        // Hiển thị animation ngay lập tức
        showDialog(
          context: context,
          barrierDismissible: false, // Không cho phép tắt dialog bằng cách nhấn ngoài
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/Lottie/successful.json', // Đường dẫn tới file animation thành công
                    width: 150,
                    height: 150,
                    fit: BoxFit.contain,
                    repeat: false, // Chỉ chạy animation một lần
                    onLoaded: (composition) {
                      // Đóng dialog sau khi animation hoàn tất (không phụ thuộc server)
                      Future.delayed(Duration(milliseconds: (composition.duration.inMilliseconds * 0.9).round()), () {
                        Navigator.of(context).pop();
                      });
                    },
                  ),
                ],
              ),
            );
          },
        );

        // Thực hiện đăng ký và làm mới danh sách trong nền
        try {
          // Đăng ký từng học phần
          for (var section in selectedSections) {
            await studySectionController.registerCourse(
              idSinhVien: widget.id_sinh_vien,
              section: section,
            );
          }

          // Làm mới danh sách sau khi đăng ký
          if (selectedYear != null) {
            await sectionClassController.fetchUnenrolledCourseSections(
              idSinhVien: widget.id_sinh_vien,
              idHocKy: int.parse(selectedYear!),
            );
            await sectionClassController.fetchEnrolledCourseSections(
              idSinhVien: widget.id_sinh_vien,
              idHocKy: int.parse(selectedYear!),
            );
          }

          // Animation đã tự đóng trước đó, giờ chỉ cần chuyển tab
          _tabController.animateTo(1);
        } catch (e) {
          // Nếu có lỗi, hiển thị thông báo lỗi sau khi animation đã đóng
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: $e'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vui lòng chọn ít nhất một học phần!'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn đầy đủ thông tin!'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showCourseDetails(BuildContext context, SectionClassModel section) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Thông Tin Lớp Học Phần \n${section.subject?.ten_mon}',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Mã môn học: ', section.subject?.ma_mon_hoc ?? 'N/A'),
              _buildDetailRow('Giảng viên: ', section.teacher?.ho_ten ?? 'N/A'),
              _buildDetailRow('Phòng: ', section.room?.ten_phong ?? 'N/A'),
              _buildDetailRow('Tổng số tiết: ', section.tong_so_tiet.toString() ?? 'N/A'),
              _buildDetailRow('Học phí: ', '${numberFormat.format(section.hoc_phi)} VNĐ'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Đóng',
                style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}