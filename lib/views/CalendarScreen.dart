import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:quan_ly_diem/models/infoStudentModel.dart';
import 'package:quan_ly_diem/services/infoStudentService.dart';
import '../controllers/calendarController.dart';

class CalendarScreen extends StatefulWidget {
  final int userId;

  const CalendarScreen({required this.userId});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> with AutomaticKeepAliveClientMixin {
  InfoModel? info;
  CalendarController? calendarController;
  RxBool isFetchingClassError = false.obs;
  bool isInitialLoading = true;
  bool shouldShowLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    print('CalendarScreen initState called');
    fetchInfoData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('CalendarScreen didChangeDependencies called');
  }

  Future<void> fetchInfoData() async {
    print('fetchInfoData started');
    try {
      final fetchedInfo = await InfoStudentService.fetchInfoStudent(widget.userId);
      print('UserId: ${widget.userId}');
      print('Thông tin lớp: $fetchedInfo');
      setState(() {
        info = fetchedInfo;
        isFetchingClassError.value = false;
        isInitialLoading = false;
      });
      if (!Get.isRegistered<CalendarController>()) {
        calendarController = Get.put(CalendarController(id_lop: info!.id_lop));
      } else {
        calendarController = Get.find<CalendarController>();
      }
      await calendarController!.fetchLichHoc();
      setState(() {
        shouldShowLoading = false;
      });
    } catch (e) {
      print('Error fetching class data: $e');
      setState(() {
        isFetchingClassError.value = true;
        isInitialLoading = false;
        shouldShowLoading = false;
      });
      if (calendarController != null) {
        calendarController!.errorMessage.value = 'Không thể tải thông tin lớp: $e';
      }
    }
    print('fetchInfoData completed');
  }

  @override
  void dispose() {
    print('CalendarScreen dispose called');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('CalendarScreen build called');
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.blueAccent[700]),
                        onPressed: () {
                          if (calendarController != null && !calendarController!.isLoading.value) {
                            calendarController!.updateDate(
                              calendarController!.selectedDate.value.subtract(Duration(days: 1)),
                            );
                          }
                        },
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: GestureDetector(
                                onTap: () async {
                                  if (calendarController != null && !calendarController!.isLoading.value) {
                                    final DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: calendarController!.selectedDate.value,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2030),
                                    );
                                    if (picked != null && calendarController != null) {
                                      print('Ngày được chọn từ DatePicker: $picked');
                                      calendarController!.updateDate(picked);
                                    }
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.calendar_today, color: Colors.blueAccent[700], size: 20),
                                      SizedBox(width: 4),
                                      Flexible(
                                        child: calendarController == null || shouldShowLoading
                                            ? Text(
                                          'Loading...',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueAccent[700],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        )
                                            : Obx(() => Text(
                                          DateFormat('EEEE, dd/MM/yyyy')
                                              .format(calendarController!.selectedDate.value),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueAccent[700],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 4),
                            IconButton(
                              icon: Icon(Icons.refresh, color: Colors.blueAccent[700], size: 20),
                              tooltip: 'Hiện tại',
                              onPressed: () {
                                if (calendarController != null && !calendarController!.isLoading.value) {
                                  setState(() {
                                    shouldShowLoading = true;
                                  });
                                  calendarController!.resetToCurrentDate();
                                  setState(() {
                                    shouldShowLoading = false;
                                  });
                                  print('Reset to current date via button');
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios, color: Colors.blueAccent[700]),
                        onPressed: () {
                          if (calendarController != null && !calendarController!.isLoading.value) {
                            calendarController!.updateDate(
                              calendarController!.selectedDate.value.add(Duration(days: 1)),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Obx(() {
                    final isError = isFetchingClassError.value;
                    final isControllerLoading = calendarController?.isLoading.value ?? false;
                    final errorMessage = calendarController?.errorMessage.value ?? '';

                    if (isInitialLoading) {
                      return Center(
                        child: Lottie.asset(
                          'assets/Lottie/loading1.json',
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                      );
                    }

                    if (isError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Không thể tải thông tin lớp. Vui lòng thử lại.',
                              style: TextStyle(color: Colors.redAccent, fontSize: 16),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: fetchInfoData,
                              child: Text('Thử lại'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (calendarController == null) {
                      return Center(
                        child: Text(
                          'Đã xảy ra lỗi không mong muốn. Vui lòng thử lại.',
                          style: TextStyle(color: Colors.redAccent, fontSize: 16),
                        ),
                      );
                    }

                    if (isControllerLoading) {
                      return Center(
                        child: Lottie.asset(
                          'assets/Lottie/loading1.json',
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                      );
                    }

                    final lichHoc = calendarController!.lichHoc;
                    final isScheduleNotFound = errorMessage == 'Không tìm thấy lịch học cho lớp này.';
                    final hasSchedules = (lichHoc['Sáng']?.isNotEmpty ?? false) ||
                        (lichHoc['Chiều']?.isNotEmpty ?? false) ||
                        (lichHoc['Tối']?.isNotEmpty ?? false);

                    if (errorMessage.isNotEmpty && !isScheduleNotFound) {
                      return Center(
                        child: Text(
                          errorMessage,
                          style: TextStyle(color: Colors.redAccent, fontSize: 16),
                        ),
                      );
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildScheduleSection(context, 'Sáng', lichHoc['Sáng'] ?? []),
                        SizedBox(height: 20),
                        _buildScheduleSection(context, 'Chiều', lichHoc['Chiều'] ?? []),
                        SizedBox(height: 20),
                        _buildScheduleSection(context, 'Tối', lichHoc['Tối'] ?? []),
                        if (isScheduleNotFound)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                              'Không tìm thấy lịch học',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleSection(BuildContext context, String timeSlot, List<Map<String, dynamic>> buoiHoc) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: _getColorForTimeSlot(timeSlot),
      child: ExpansionTile(
        leading: Icon(_getIconForTimeSlot(timeSlot), color: Colors.white, size: 20),
        title: Text(
          timeSlot,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        children: buoiHoc.isNotEmpty
            ? buoiHoc.map((mon) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: SizedBox(
              width: double.infinity, // Đảm bảo card chiếm toàn bộ chiều rộng
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                color: mon['loai'] == 2 ? Colors.green[200] : Colors.white,
                child: Container(
                  width: 300, // Kích thước cố định, lớn hơn một chút
                  padding: const EdgeInsets.all(16.0), // Tăng padding để card to hơn
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        mon['monHoc'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Mã HP: ${mon['ms_lop_hoc_phan']}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8), // Tăng khoảng cách để đẹp hơn
                      Text(
                        'Giảng viên: ${mon['giangVien']}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Tiết: ${mon['tu_tiet']} - ${mon['den_tiet']}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Phòng: ${mon['phongHoc']}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList()
            : [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Không có lịch học trong ca này',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForTimeSlot(String timeSlot) {
    switch (timeSlot) {
      case 'Sáng':
        return Colors.blue[200]!;
      case 'Chiều':
        return Colors.orange[200]!;
      case 'Tối':
        return Colors.purple[200]!;
      default:
        return Colors.grey[200]!;
    }
  }

  String _getTimeSlotFromHour(int hour) {
    if (hour >= 6 && hour < 12) return 'Sáng';
    if (hour >= 12 && hour < 18) return 'Chiều';
    if (hour >= 18 && hour < 24) return 'Tối';
    return 'Sáng';
  }

  IconData _getIconForTimeSlot(String timeSlot) {
    switch (timeSlot) {
      case 'Sáng':
        return Icons.wb_sunny;
      case 'Chiều':
        return Icons.brightness_medium;
      case 'Tối':
        return Icons.brightness_2;
      default:
        return Icons.schedule;
    }
  }
}