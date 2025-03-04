// ignore_for_file: file_names, deprecated_member_use

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LineChartWidget extends StatelessWidget {
  final List<FlSpot> dataPoints;
  final double timeCounter;

  const LineChartWidget({
    super.key,
    required this.dataPoints,
    required this.timeCounter,
  });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minX: (timeCounter - 10).clamp(0, double.infinity),
        maxX: timeCounter,
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: dataPoints,
            isCurved: false,
            color: Colors.red,
            barWidth: 2,
            isStrokeCapRound: false,
            belowBarData: BarAreaData(show: false),
            dotData: FlDotData(
              show: true,
              getDotPainter:
                  (spot, percent, barData, index) => FlDotCirclePainter(
                    radius: 2.sp,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: Colors.red,
                  ),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 25,
              reservedSize: 40,
              getTitlesWidget:
                  (value, meta) => Text(
                    value.toInt().toString(),
                    style: TextStyle(fontSize: 12),
                  ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 2,
              getTitlesWidget: (value, meta) {
                return Text("${value.toInt()}", style: TextStyle(fontSize: 12));
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: true,
          horizontalInterval: 25,
          verticalInterval: 2,
          getDrawingHorizontalLine:
              (value) => FlLine(
                color: Colors.grey.withOpacity(0.5),
                strokeWidth: 1.w,
                dashArray: [5, 5],
              ),
          getDrawingVerticalLine:
              (value) => FlLine(
                color: Colors.grey.withOpacity(0.5),
                strokeWidth: 1.w,
                dashArray: [5, 5],
              ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
