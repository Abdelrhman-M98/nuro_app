import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/utils/styles.dart';
import 'package:nervix_app/Core/utils/theme_extensions.dart';

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
    if (dataPoints.isEmpty) return const Center(child: CircularProgressIndicator());

    final bool isAbnormal = currentState != 'Normal';
    final Color lineColor = isAbnormal ? const Color(0xFFEF4444) : const Color(0xFF22C55E); // Standard Red / Green
    
    final double minX = dataPoints.first.x;
    final double maxX = dataPoints.last.x;

    // Fully Dynamic Y-axis scaling logic
    double minYValue = 0;
    double maxYValue = 1000;
    double yInterval = 200;
    
    if (dataPoints.isNotEmpty) {
      final values = dataPoints.map((s) => s.y).toList();
      final currentMax = values.reduce((a, b) => a > b ? a : b);
      final currentMin = values.reduce((a, b) => a < b ? a : b);
      double diff = currentMax - currentMin;
      
      if (diff < 1.0) {
        minYValue = currentMax * 0.9 - 10;
        maxYValue = currentMax * 1.1 + 10;
      } else {
        final padding = diff * 0.1;
        minYValue = currentMin - padding;
        maxYValue = currentMax + padding;
      }
      
      final range = maxYValue - minYValue;
      yInterval = (range / 5).clamp(0.1, 1000.0);
    }

    return ClipRect(
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: yInterval, 
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) => FlLine(
              color: context.colorScheme.onSurface.withValues(alpha: 0.1),
              strokeWidth: 0.5,
              dashArray: [5, 5],
            ),
            getDrawingVerticalLine: (value) => FlLine(
              color: context.colorScheme.onSurface.withValues(alpha: 0.1),
              strokeWidth: 0.5,
              dashArray: [5, 5],
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
               sideTitles: SideTitles(
                 showTitles: true,
                 interval: 2,
                 reservedSize: 28,
                 getTitlesWidget: (value, meta) {
                   if (value % 2 != 0) return const SizedBox.shrink();
                   if (value < minX || value > maxX) return const SizedBox.shrink();
                   
                   return Padding(
                     padding: EdgeInsets.only(top: 8.h),
                      child: Text(
                        '${value.toInt()}s',
                        textAlign: TextAlign.center,
                        style: FontStyles.getRoboto12(context).copyWith(
                          fontSize: 10.sp,
                          color: context.colorScheme.onSurface.withValues(alpha: 0.54),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                   );
                 },
               )
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: yInterval, 
                reservedSize: 50.w,
                getTitlesWidget: (value, meta) {
                  final String text = yInterval < 1 
                    ? value.toStringAsFixed(1)
                    : value.toInt().toString();
                    
                  return Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: Text(
                      text,
                      textAlign: TextAlign.right,
                      style: FontStyles.getRoboto12(context).copyWith(
                        color: context.colorScheme.onSurface.withValues(alpha: 0.54),
                        fontSize: 10.sp,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          clipData: const FlClipData.all(),
          minX: minX,
          maxX: maxX,
          minY: minYValue,
          maxY: maxYValue,
          lineBarsData: [
            LineChartBarData(
              spots: dataPoints,
              isCurved: false,
              color: lineColor,
              barWidth: 2,
              isStrokeCapRound: true,
              shadow: Shadow(
                color: lineColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    lineColor.withValues(alpha: 0.15),
                    lineColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
        duration: Duration.zero, 
      ),
    );
  }
}
