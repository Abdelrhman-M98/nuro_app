import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:neuro_app/Features/Doctor_Info/Presentation/view/Widget/line_chart_container.dart';

class DynamicLineChart extends StatefulWidget {
  const DynamicLineChart({super.key});

  @override
  DynamicLineChartState createState() => DynamicLineChartState();
}

class DynamicLineChartState extends State<DynamicLineChart> {
  List<FlSpot> dataPoints = [];
  late Timer _timer;
  double _timeCounter = 0;

  @override
  void initState() {
    super.initState();
    _startUpdatingChart();
  }

  void _startUpdatingChart() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        double newValue =
            (10 + (90 * (DateTime.now().second % 10) / 10)).toDouble();
        dataPoints.add(FlSpot(_timeCounter, newValue));

        if (dataPoints.length > 5) {
          dataPoints.removeAt(0);
        }

        _timeCounter += 2;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dotted Grid & Border Line Chart")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChartContainer(
          dataPoints: dataPoints,
          timeCounter: _timeCounter,
        ),
      ),
    );
  }
}
