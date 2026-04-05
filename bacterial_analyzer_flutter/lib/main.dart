import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const BacterialAnalyzerApp());
}

class BacterialAnalyzerApp extends StatelessWidget {
  const BacterialAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bacterial Analyzer',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const GrowthSimulatorPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GrowthSimulatorPage extends StatefulWidget {
  const GrowthSimulatorPage({super.key});

  @override
  State<GrowthSimulatorPage> createState() => _GrowthSimulatorPageState();
}

class _GrowthSimulatorPageState extends State<GrowthSimulatorPage> {
  double _initialCount = 1.0;
  double _growthRate = 0.30;
  int _days = 10;

  List<FlSpot> get _chartData {
    return List.generate(_days + 1, (index) {
      final value = _initialCount * pow(1 + _growthRate, index);
      return FlSpot(index.toDouble(), value.toDouble());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bacterial Growth Simulator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Adjust growth parameters and view the projected curve.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildParameterSlider(
              label: 'Initial count',
              value: _initialCount,
              min: 1,
              max: 20,
              divisions: 19,
              unit: 'x10',
              onChanged: (value) => setState(() => _initialCount = value),
            ),
            _buildParameterSlider(
              label: 'Growth rate',
              value: _growthRate,
              min: 0.05,
              max: 1.0,
              divisions: 19,
              unit: '% per day',
              displayValue: (_growthRate * 100).toStringAsFixed(1),
              onChanged: (value) => setState(() => _growthRate = value),
            ),
            const SizedBox(height: 16),
            Text('Days: $_days', style: Theme.of(context).textTheme.bodyLarge),
            Slider(
              value: _days.toDouble(),
              min: 5,
              max: 30,
              divisions: 25,
              label: _days.toString(),
              onChanged: (value) => setState(() => _days = value.round()),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildChart()),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String unit,
    String? displayValue,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${displayValue ?? value.toStringAsFixed(1)} $unit'),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: displayValue ?? value.toStringAsFixed(1),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildChart() {
    final spots = _chartData;
    final maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: _days.toDouble(),
            minY: 0,
            maxY: maxY * 1.1,
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 32),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 42),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Colors.green,
                barWidth: 4,
                dotData: FlDotData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
