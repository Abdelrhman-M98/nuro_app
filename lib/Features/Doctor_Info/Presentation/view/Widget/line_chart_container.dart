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
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.7), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LineChartWidget(
          dataPoints: dataPoints,
          timeCounter: timeCounter,
        ),
      ),
    );
  }
}
