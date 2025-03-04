// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'line_chart_widget.dart';
import 'package:fl_chart/fl_chart.dart';

class LineChartContainer extends StatelessWidget {
  final List<FlSpot> dataPoints;
  final double timeCounter;

  const LineChartContainer({
    super.key,
    required this.dataPoints,
    required this.timeCounter,
  });

  @override
  Widget build(BuildContext context) {
    return LineChartWidget(dataPoints: dataPoints, timeCounter: timeCounter);
  }
}
