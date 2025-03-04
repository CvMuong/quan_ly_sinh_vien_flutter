import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/calendarModel.dart';
import 'package:intl/intl.dart';
import '../services/calendarServie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CalendarController extends GetxController {
  Rx<DateTime> selectedDate = DateTime.now().obs;
  RxMap<String, List<Map<String, dynamic>>> lichHoc = <String, List<Map<String, dynamic>>>{}.obs;
  RxBool isLoading = false.obs;
  RxBool isResetting = false.obs;
  RxString errorMessage = ''.obs;
  final int? id_lop;
  List<Schedule> allSchedules = [];
  bool _hasFetched = false;
  String? _lastFilteredDate;

  CalendarController({this.id_lop});

  @override
  void onInit() {
    super.onInit();
    print('CalendarController onInit called with id_lop: $id_lop');
    if (id_lop == null) {
      errorMessage.value = 'Không có id_lop để lấy lịch học';
    } else if (!_hasFetched) {
      _loadCachedSchedules();
      fetchLichHoc();
      _hasFetched = true;
    }
  }

  Future<void> _loadCachedSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('cached_schedules_$id_lop');
    if (cachedData != null) {
      final List<dynamic> jsonData = jsonDecode(cachedData);
      allSchedules = jsonData.map((json) => Schedule.fromJson(json)).toList();
      print('Loaded ${allSchedules.length} schedules from cache');
      filterSchedulesByDate();
    }
  }

  Future<void> _saveSchedulesToCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = allSchedules.map((schedule) => schedule.toJson()).toList();
    await prefs.setString('cached_schedules_$id_lop', jsonEncode(jsonData));
    print('Saved ${allSchedules.length} schedules to cache');
  }

  Future<void> fetchLichHoc() async {
    if (isLoading.value) {
      print('fetchLichHoc skipped: already loading');
      return;
    }

    print('fetchLichHoc started');
    isLoading.value = true;
    errorMessage.value = '';

    try {
      if (id_lop == null) {
        throw Exception('Không có id_lop để lấy lịch học');
      }

      final schedules = await CalendarService.getSchedulesByClassAndDate(id_lop: id_lop!);
      allSchedules = schedules;
      await _saveSchedulesToCache();
      print('Dữ liệu gốc từ API: ${schedules.map((s) => "${s.ngay} - MonHoc: ${s.lopHocPhanDetails?.monHoc}, TuTiet: ${s.tu_tiet}, DenTiet: ${s.den_tiet}, Loai: ${s.loai}").toList()}');
      filterSchedulesByDate();
    } catch (e) {
      print('fetchLichHoc error: $e');
      if (e.toString().contains('Schedule not found')) {
        errorMessage.value = 'Không tìm thấy lịch học cho lớp này.';
      } else if (e.toString().contains('Unauthorized')) {
        errorMessage.value = 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';
      } else if (e.toString().contains('No authentication token found')) {
        errorMessage.value = 'Không tìm thấy token xác thực. Vui lòng đăng nhập lại.';
      } else {
        errorMessage.value = 'Lỗi khi tải lịch học: $e';
      }
      lichHoc.value = {'Sáng': [], 'Chiều': [], 'Tối': []};
    } finally {
      isLoading.value = false;
      print('fetchLichHoc completed');
    }
  }

  void updateDate(DateTime date) {
    selectedDate.value = date;
    print('Selected Date updated to: ${selectedDate.value}');
    filterSchedulesByDate();
  }

  void resetToCurrentDate() {
    isResetting.value = true;
    selectedDate.value = DateTime.now();
    print('Reset Selected Date to current: ${selectedDate.value}');
    filterSchedulesByDate();
    isResetting.value = false;
  }

  void filterSchedulesByDate() {
    String selectedDateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);

    if (_lastFilteredDate == selectedDateStr) {
      print('filterSchedulesByDate skipped: same date already filtered ($selectedDateStr)');
      return;
    }

    print('filterSchedulesByDate started for date: $selectedDateStr');
    final filteredSchedules = allSchedules.where((schedule) {
      if (schedule.ngay == null) return false;
      final scheduleDate = DateTime.parse(schedule.ngay!).add(Duration(hours: 7));
      return DateFormat('yyyy-MM-dd').format(scheduleDate) == selectedDateStr;
    }).toList();

    lichHoc.value = _parseSchedulesToTimeSlots(filteredSchedules);

    if (lichHoc.value.values.every((list) => list.isEmpty)) {
      errorMessage.value = 'Không tìm thấy lịch học cho ngày này.';
    } else {
      errorMessage.value = '';
    }
    _lastFilteredDate = selectedDateStr;
    print('filterSchedulesByDate completed with ${filteredSchedules.length} schedules');
  }

  Map<String, List<Map<String, dynamic>>> _parseSchedulesToTimeSlots(List<Schedule> schedules) {
    Map<String, List<Map<String, dynamic>>> timeSlots = {
      'Sáng': [],
      'Chiều': [],
      'Tối': [],
    };
    for (var schedule in schedules) {
      String sessionName = _getSessionName(schedule.session);
      if (sessionName.isNotEmpty && schedule.ngay != null) {
        final adjustedTime = DateTime.parse(schedule.ngay!).add(Duration(hours: 7));
        timeSlots[sessionName]!.add({
          'monHoc': schedule.lopHocPhanDetails?.monHoc ?? 'Môn học không xác định',
          'giangVien': schedule.lopHocPhanDetails?.giangVien ?? 'Giảng viên không xác định',
          'thoiGian': adjustedTime,
          'phongHoc': schedule.lopHocPhanDetails?.phong ?? 'Phòng không xác định',
          'tu_tiet': schedule.tu_tiet ?? 1,
          'den_tiet': schedule.den_tiet ?? 1,
          'loai': schedule.loai ?? 1,
          'ms_lop_hoc_phan': schedule.lopHocPhanDetails?.ms_lop_hoc_phan ?? '', // Thêm mã học phần
          'icon': _getIconForSession(sessionName),
        });
      }
    }

    timeSlots.forEach((key, value) {
      value.sort((a, b) => (a['tu_tiet'] as int).compareTo(b['tu_tiet'] as int));
    });

    return timeSlots;
  }

  String _getSessionName(int? session) {
    switch (session) {
      case 1:
        return 'Sáng';
      case 2:
        return 'Chiều';
      case 3:
        return 'Tối';
      default:
        return '';
    }
  }

  IconData _getIconForSession(String session) {
    switch (session) {
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

  Map<String, dynamic> _scheduleToJson(Schedule schedule) {
    return {
      'id_lich_hoc': schedule.id_lich_hoc,
      'ngay': schedule.ngay,
      'session': schedule.session,
      'id_lop_hoc_phan': schedule.id_lop_hoc_phan,
      'tu_tiet': schedule.tu_tiet,
      'den_tiet': schedule.den_tiet,
      'loai': schedule.loai,
      'lopHocPhanDetails': {
        'id_lop_hoc_phan': schedule.lopHocPhanDetails?.id_lop_hoc_phan,
        'id_mon_hoc': schedule.lopHocPhanDetails?.id_mon_hoc,
        'id_giang_vien': schedule.lopHocPhanDetails?.id_giang_vien,
        'id_phong': schedule.lopHocPhanDetails?.id_phong,
        'monHoc': schedule.lopHocPhanDetails?.monHoc,
        'giangVien': schedule.lopHocPhanDetails?.giangVien,
        'phong': schedule.lopHocPhanDetails?.phong,
        'ms_lop_hoc_phan': schedule.lopHocPhanDetails?.ms_lop_hoc_phan, // Thêm mã học phần vào JSON
      },
    };
  }
}