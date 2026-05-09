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
    
    // Strict 20-second sliding window
    double maxX = dataPoints.last.x;
    double minX = maxX - 20;

    if (minX < 0) minX = 0; // Don't show negative time early on
    if (maxX < 20) maxX = 20; // Keep the X axis width strictly at 20 early on

    // Fully Dynamic Y-axis scaling logic matching Chart.js strictly
    double minYValue = 0;
    double maxYValue = 1000;
    double yInterval = 200;
    
    if (dataPoints.isNotEmpty) {
      final values = dataPoints.map((s) => s.y).toList();
      final currentMax = values.reduce((a, b) => a > b ? a : b);
      final currentMin = values.reduce((a, b) => a < b ? a : b);
      double diff = currentMax - currentMin;
      
      if (diff < 5) {
        // Treat as mostly flat (handles tiny sensor noise): +/- 1.0 around the center
        double center = (currentMax + currentMin) / 2;
        minYValue = center - 1.0;
        maxYValue = center + 1.0;
        yInterval = 0.2;
      } else {
        // Ranging line (like Image 1, 3, 4): give a very small dynamic padding 
        // to prevent absolute top/bottom sticking and calculate intervals
        minYValue = currentMin;
        maxYValue = currentMax;
        
        // Calculate nice intervals based on data range
        if (diff <= 10) yInterval = 1;
        else if (diff <= 50) yInterval = 5;
        else if (diff <= 100) yInterval = 10;
        else if (diff <= 500) yInterval = 50;
        else if (diff <= 1000) yInterval = 100;
        else if (diff <= 2000) yInterval = 200;
        else yInterval = 500;
      }
    }

    return Column(
      children: [
        Expanded(
          child: Directionality(
            textDirection: TextDirection.ltr, // Revert back to LTR to ensure numbers increase normally
            child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: yInterval, 
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) => FlLine(
              color: context.colorScheme.onSurface.withOpacity(0.05), // Very faint solid line like Chart.js
              strokeWidth: 1,
            ),
            getDrawingVerticalLine: (value) => FlLine(
              color: context.colorScheme.onSurface.withOpacity(0.05),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
               sideTitles: SideTitles(
                 showTitles: true,
                 interval: 4, // Show every 4 seconds to guarantee no overlap on narrow screens
                 reservedSize: 32.h,
                 getTitlesWidget: (value, meta) {
                   if (value < minX || value > maxX) return const SizedBox.shrink();
                   // fl_chart sometimes forces labels at the extreme edges (minX and maxX), 
                   // which causes them to overlap with the regular interval labels.
                   // Ensure we ONLY draw labels that fall exactly on our 4-second interval.
                   if (value % 4 != 0) return const SizedBox.shrink();
                   
                   // Format seconds into mm:ss to look like a professional temporal axis
                   int totalSeconds = value.toInt();
                   int minutes = totalSeconds ~/ 60;
                   int seconds = totalSeconds % 60;
                   String timeText = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
                   
                   return Padding(
                     padding: EdgeInsets.only(top: 8.h),
                      child: Text(
                        timeText,
                        textAlign: TextAlign.center,
                        style: FontStyles.getRoboto12(context).copyWith(
                          fontSize: 9.sp,
                          color: context.colorScheme.onSurface.withOpacity(0.54),
                          fontWeight: FontWeight.w500,
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
                reservedSize: 65.w, // More room to prevent Y-axis large numbers from overlapping edge
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
              isStrokeCapRound: false,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false), // NO fill, just the sharp line
            ),
          ], // This array right here needs to close
        ),
              duration: Duration.zero,
            ),
          ),
        ),
      ],
    );
  }
}
