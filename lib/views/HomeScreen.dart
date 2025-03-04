import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatelessWidget {
  // Dữ liệu mẫu: Điểm các môn học với 3 loại điểm
  final List<Map<String, dynamic>> studentGrades = [
    {
      'subject': 'Toán',
      'midterm': 8.0,
      'final': 8.5,
      'total': 8.3,
    },
    {
      'subject': 'Lý',
      'midterm': 7.0,
      'final': 6.5,
      'total': 6.8,
    },
    {
      'subject': 'Hóa',
      'midterm': 9.0,
      'final': 8.8,
      'total': 8.9,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: studentGrades.length,
          itemBuilder: (context, index) {
            final subjectData = studentGrades[index];
            return Card(
              elevation: 4, // Thêm bóng cho Card
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      subjectData['subject'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[800],
                      ),
                    ),
                    SizedBox(height: 70),
                    SizedBox(
                      height: 200, // Chiều cao biểu đồ
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 10, // Điểm tối đa
                          barGroups: [
                            BarChartGroupData(
                              x: 0, // Nhóm Midterm
                              barRods: [
                                BarChartRodData(
                                  toY: subjectData['midterm'].toDouble(),
                                  color: Colors.orange[400], // Màu cam nhạt
                                  width: 20, // Tăng độ dày cột
                                  borderRadius: BorderRadius.circular(4), // Bo góc cột
                                ),
                              ],
                              showingTooltipIndicators: [0],
                            ),
                            BarChartGroupData(
                              x: 1, // Nhóm Final
                              barRods: [
                                BarChartRodData(
                                  toY: subjectData['final'].toDouble(),
                                  color: Colors.green[400], // Màu xanh lá nhạt
                                  width: 20,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                              showingTooltipIndicators: [0],
                            ),
                            BarChartGroupData(
                              x: 2, // Nhóm Total
                              barRods: [
                                BarChartRodData(
                                  toY: subjectData['total'].toDouble(),
                                  color: Colors.blue[400], // Màu xanh dương nhạt
                                  width: 20,
                                  borderRadius: BorderRadius.circular(4),
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
                                      color: Colors.grey[700],
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false), // Không hiển thị nhãn dưới cột
                            ),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(
                            show: true,
                            horizontalInterval: 2,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey[300], // Lưới nhạt hơn
                                strokeWidth: 0.5, // Lưới mỏng hơn
                              );
                            },
                          ),
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              // Thay tooltipBgColor bằng tooltipContainerDecoration
                              tooltipPadding: const EdgeInsets.all(8),
                              tooltipMargin: 8,
                              getTooltipColor: (_) => Colors.grey[800]!.withOpacity(0.9), // Màu nền tooltip
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                String label;
                                switch (group.x.toInt()) {
                                  case 0:
                                    label = 'Midterm';
                                    break;
                                  case 1:
                                    label = 'Final';
                                    break;
                                  case 2:
                                    label = 'Total';
                                    break;
                                  default:
                                    label = '';
                                }
                                return BarTooltipItem(
                                  '$label\n${rod.toY}',
                                  TextStyle(
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
                    SizedBox(height: 15),
                    // Chú thích màu sắc
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.orange[400],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            SizedBox(width: 5),
                            Text('Midterm', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        SizedBox(width: 15),
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.green[400],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            SizedBox(width: 5),
                            Text('Final', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        SizedBox(width: 15),
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.blue[400],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            SizedBox(width: 5),
                            Text('Total', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}