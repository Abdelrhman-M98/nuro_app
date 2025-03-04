// ignore_for_file: file_names, deprecated_member_use

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neuro_app/Core/utils/styles.dart';

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
        backgroundColor: Colors.white,
        minX: (timeCounter - 10).clamp(0, double.infinity),
        maxX: timeCounter,
        minY: 0,
        maxY: 100,
        lineBarsData: [
          if (dataPoints.isNotEmpty)
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
              reservedSize: 19.sp,
              getTitlesWidget:
                  (value, meta) => Text(
                    value.toInt().toString(),
                    style: FontStyles.roboto12,
                  ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 14.sp,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Text("${value.toInt()}", style: FontStyles.roboto12);
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
          horizontalInterval: 25.w,
          verticalInterval: 2,
          getDrawingHorizontalLine:
              (value) => FlLine(
                color: Color(0XFFCCCCCC),
                strokeWidth: 1.w,
                dashArray: [5, 5],
              ),
          getDrawingVerticalLine:
              (value) => FlLine(
                color: Color(0XFFCCCCCC),
                strokeWidth: 1.w,
                dashArray: [5, 5],
              ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            width: 1,
            color: Color(0XFFCCCCCC),
            style: BorderStyle.solid,
          ),
        ),
      ),
    );
  }
}
