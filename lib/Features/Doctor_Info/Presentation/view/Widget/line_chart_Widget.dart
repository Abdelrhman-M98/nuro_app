import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/styles.dart';

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
        backgroundColor: kSurfaceLightColor.withValues(alpha: 0.3),
        minX: (timeCounter - 10).clamp(0, double.infinity),
        maxX: timeCounter,
        minY: 0,
        maxY: 100,
        lineBarsData: [
          if (dataPoints.isNotEmpty)
            LineChartBarData(
              spots: dataPoints,
              isCurved: false,
              color: kAccentColor,
              barWidth: 2,
              isStrokeCapRound: false,
              belowBarData: BarAreaData(show: false),
              dotData: FlDotData(
                show: true,
                getDotPainter:
                    (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 2.sp,
                      color: kAccentColor,
                      strokeWidth: 1,
                      strokeColor: kAccentColor,
                    ),
              ),
            ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 25,
              reservedSize: 28.sp,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: FontStyles.roboto12.copyWith(color: kOnSurfaceVariantColor),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 20.sp,
              interval: 1,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: FontStyles.roboto12.copyWith(color: kOnSurfaceVariantColor),
              ),
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
          getDrawingHorizontalLine: (value) => FlLine(
            color: kOnSurfaceVariantColor.withValues(alpha: 0.3),
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: kOnSurfaceVariantColor.withValues(alpha: 0.3),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            width: 1,
            color: kOnSurfaceVariantColor.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
