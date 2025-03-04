import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../models/semesterModel.dart';
import '../services/semesterService.dart';
import '../controllers/sectionClassController.dart';

class StudentScoreScreen extends StatefulWidget {
  final int userId;

  StudentScoreScreen({required this.userId});

  @override
  State<StudentScoreScreen> createState() => _StudentScoreScreenState();
}

class _StudentScoreScreenState extends State<StudentScoreScreen>
    with SingleTickerProviderStateMixin {
  final SectionClassController sectionClassController =
  Get.put(SectionClassController());
  List<SemesterModel> semesters = [];
  SemesterModel? selectedSemester;
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _fetchSemesters();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchSemesters() async {
    try {
      final semesterList = await SemesterService.fetchSemesters();
      setState(() {
        semesters = semesterList;
        if (semesters.isNotEmpty) {
          semesters.sort((a, b) {
            final yearA = int.parse(a.nien_khoa.split('-')[1]);
            final yearB = int.parse(b.nien_khoa.split('-')[1]);
            int yearComparison = yearB.compareTo(yearA);
            if (yearComparison != 0) return yearComparison;

            final semesterA =
                int.tryParse(a.ten_hoc_ky.replaceAll(RegExp(r'[^0-9]'), '')) ??
                    0;
            final semesterB =
                int.tryParse(b.ten_hoc_ky.replaceAll(RegExp(r'[^0-9]'), '')) ??
                    0;
            return semesterB.compareTo(semesterA);
          });
          selectedSemester = semesters[0];
          _fetchEnrolledCourseSections();
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải danh sách học kỳ: $e')),
      );
    }
  }

  Future<void> _fetchEnrolledCourseSections() async {
    if (selectedSemester != null) {
      await sectionClassController.fetchEnrolledCourseSections(
        idSinhVien: widget.userId,
        idHocKy: selectedSemester!.id_hoc_ky,
      );
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
        child: Lottie.asset(
          'assets/Lottie/loading1.json',
          width: 120,
          height: 120,
          fit: BoxFit.contain,
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<SemesterModel>(
                value: selectedSemester,
                isExpanded: true,
                hint: const Text('Chọn học kỳ'),
                items: semesters.map((SemesterModel semester) {
                  return DropdownMenuItem<SemesterModel>(
                    value: semester,
                    child:
                    Text('${semester.ten_hoc_ky} - ${semester.nien_khoa}'),
                  );
                }).toList(),
                onChanged: (SemesterModel? newValue) async {
                  setState(() {
                    selectedSemester = newValue;
                  });
                  if (newValue != null) {
                    await sectionClassController.fetchEnrolledCourseSections(
                      idSinhVien: widget.userId,
                      idHocKy: newValue.id_hoc_ky,
                    );
                    _animationController.reset();
                    _animationController.forward();
                  }
                },
                underline: const SizedBox(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (sectionClassController.isLoadingEnrolled.value) {
                  return Center(
                    child: Lottie.asset(
                      "assets/Lottie/loading1.json",
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  );
                }
                if (sectionClassController.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Text(
                      'Lỗi: ${sectionClassController.errorMessage.value}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                if (sectionClassController.enrolledCourseSections.isEmpty) {
                  return const Center(child: Text('Không có dữ liệu điểm'));
                }

                return AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return ListView.builder(
                      itemCount:
                      sectionClassController.enrolledCourseSections.length,
                      itemBuilder: (context, index) {
                        final section = sectionClassController
                            .enrolledCourseSections[index];
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  section.subject?.ten_mon ??
                                      'Môn học không xác định',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal[800],
                                  ),
                                ),
                                const SizedBox(height: 60),
                                SizedBox(
                                  height: 200,
                                  child: BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceAround,
                                      maxY: 10,
                                      barGroups: [
                                        BarChartGroupData(
                                          x: 0,
                                          barRods: [
                                            BarChartRodData(
                                              toY: (section.score?.diemGiuaKy?.toDouble() ??
                                                  0.0) *
                                                  _animation.value, // Animation cho cột
                                              color: Colors.orange[400],
                                              width: 20,
                                              borderRadius:
                                              BorderRadius.circular(4),
                                            ),
                                          ],
                                          showingTooltipIndicators: [0],
                                        ),
                                        BarChartGroupData(
                                          x: 1,
                                          barRods: [
                                            BarChartRodData(
                                              toY: (section.score?.diemCuoiKy
                                                  ?.toDouble() ??
                                                  0.0) *
                                                  _animation.value, // Animation cho cột
                                              color: Colors.green[400],
                                              width: 20,
                                              borderRadius:
                                              BorderRadius.circular(4),
                                            ),
                                          ],
                                          showingTooltipIndicators: [0],
                                        ),
                                        BarChartGroupData(
                                          x: 2,
                                          barRods: [
                                            BarChartRodData(
                                              toY: (section.score?.diemTongKet
                                                  ?.toDouble() ??
                                                  0.0) *
                                                  _animation.value, // Animation cho cột
                                              color: Colors.blue[400],
                                              width: 20,
                                              borderRadius:
                                              BorderRadius.circular(4),
                                            ),
                                          ],
                                          showingTooltipIndicators: [0],
                                        ),
                                      ],
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 40,
                                            getTitlesWidget: (value, meta) {
                                              return Text(
                                                value.toString(),
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[700]),
                                              );
                                            },
                                          ),
                                        ),
                                        bottomTitles: AxisTitles(
                                            sideTitles:
                                            SideTitles(showTitles: false)),
                                        topTitles: AxisTitles(
                                            sideTitles:
                                            SideTitles(showTitles: false)),
                                        rightTitles: AxisTitles(
                                            sideTitles:
                                            SideTitles(showTitles: false)),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      gridData: FlGridData(
                                        show: true,
                                        horizontalInterval: 2,
                                        getDrawingHorizontalLine: (value) {
                                          return FlLine(
                                              color: Colors.grey[300],
                                              strokeWidth: 0.5);
                                        },
                                      ),
                                      barTouchData: BarTouchData(
                                        enabled: true,
                                        touchTooltipData: BarTouchTooltipData(
                                          tooltipPadding:
                                          const EdgeInsets.all(8),
                                          tooltipMargin: 8,
                                          getTooltipColor: (_) => Colors
                                              .grey[800]!
                                              .withOpacity(0.9),
                                          getTooltipItem:
                                              (group, groupIndex, rod, rodIndex) {
                                            String label;
                                            double realValue; // Giá trị thực không nhân với animation
                                            switch (group.x.toInt()) {
                                              case 0:
                                                label = 'Midterm';
                                                realValue = section
                                                    .score?.diemGiuaKy
                                                    ?.toDouble() ??
                                                    0.0;
                                                break;
                                              case 1:
                                                label = 'Final';
                                                realValue = section
                                                    .score?.diemCuoiKy
                                                    ?.toDouble() ??
                                                    0.0;
                                                break;
                                              case 2:
                                                label = 'Total';
                                                realValue = section
                                                    .score?.diemTongKet
                                                    ?.toDouble() ??
                                                    0.0;
                                                break;
                                              default:
                                                label = '';
                                                realValue = 0.0;
                                            }
                                            return BarTooltipItem(
                                              '$label\n${realValue.toStringAsFixed(1)}',
                                              const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: Colors.orange[400],
                                            borderRadius:
                                            BorderRadius.circular(2),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        const Text('Midterm',
                                            style:
                                            TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                    const SizedBox(width: 15),
                                    Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: Colors.green[400],
                                            borderRadius:
                                            BorderRadius.circular(2),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        const Text('Final',
                                            style:
                                            TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                    const SizedBox(width: 15),
                                    Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: Colors.blue[400],
                                            borderRadius:
                                            BorderRadius.circular(2),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        const Text('Total',
                                            style:
                                            TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}