import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/utils/styles.dart';

class DynamicLineChart extends StatelessWidget {
  final List<FlSpot> dataPoints;
  final String currentState;

  const DynamicLineChart({
    super.key,
    required this.dataPoints,
    required this.currentState,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAbnormal = currentState == 'abnormal';
    final Color lineColor = isAbnormal ? Colors.red : Colors.green;

    return ClipRect(
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 500,
            verticalInterval: 10,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.white.withValues(alpha: 0.1),
              strokeWidth: 1,
            ),
            getDrawingVerticalLine: (value) => FlLine(
              color: Colors.white.withValues(alpha: 0.1),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 500,
                reservedSize: 42.w,
                getTitlesWidget: (value, meta) {
                  if (value % 500 == 0) {
                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: Text(
                        value.toInt().toString(),
                        style: FontStyles.roboto12.copyWith(color: Colors.white54),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.white10),
          ),
          minX: dataPoints.isNotEmpty ? dataPoints.first.x : 0,
          maxX: dataPoints.isNotEmpty ? dataPoints.last.x : 50,
          minY: 0,
          maxY: 1200,
          lineBarsData: [
            LineChartBarData(
              spots: dataPoints.isNotEmpty ? dataPoints : [const FlSpot(0, 0)],
              isCurved: true,
              color: lineColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: lineColor.withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
      ),
    );
  }
}
