import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../providers/data_provider.dart';

class ChartDisplay extends StatelessWidget {
  const ChartDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();
    final currentTab = provider.currentTab;
    final data = provider.data;
    final options = provider.toolbarOptions;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _getChartTitle(currentTab),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildChart(context, currentTab, data, options),
            ),
          ),
        ],
      ),
    );
  }

  String _getChartTitle(String tab) {
    switch (tab) {
      case 'growth':
        return 'Bacterial Growth Curves';
      case 'heatmap':
        return 'Growth Heatmap';
      case 'radar':
        return 'Parameter Analysis Radar';
      case 'science':
        return 'Scientific Analysis Summary';
      default:
        return 'Chart';
    }
  }

  Widget _buildChart(BuildContext context, String tab, List<dynamic> data, Map<String, bool> options) {
    switch (tab) {
      case 'growth':
        return _buildGrowthChart(data, options);
      case 'heatmap':
        return _buildHeatmap(data);
      case 'radar':
        return _buildRadarChart(data);
      case 'science':
        return _buildScienceChart(data);
      default:
        return const Center(child: Text('Chart not available'));
    }
  }

  Widget _buildGrowthChart(List<dynamic> data, Map<String, bool> options) {
    final chartData = data.expand((condition) {
      return List.generate(condition.time.length, (i) {
        return ChartData(
          condition.condition,
          condition.time[i],
          condition.od600[i],
          _getConditionColor(condition.condition),
        );
      });
    }).toList();

    return SfCartesianChart(
      primaryXAxis: NumericAxis(
        title: AxisTitle(text: 'Time (hours)'),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: options['log_scale'] == true ? 'OD₆₀₀ (log)' : 'OD₆₀₀'),
        logarithmic: options['log_scale'] == true,
      ),
      series: <ChartSeries>[
        LineSeries<ChartData, double>(
          dataSource: chartData,
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          color: data.color,
          name: data.condition,
          markerSettings: const MarkerSettings(isVisible: true),
        ),
      ],
      legend: Legend(isVisible: true),
    );
  }

  Widget _buildHeatmap(List<dynamic> data) {
    // Create heatmap data
    final heatmapData = <ChartData>[];
    for (var condition in data) {
      for (var i = 0; i < condition.time.length; i++) {
        heatmapData.add(ChartData(
          condition.condition,
          condition.time[i],
          condition.od600[i],
          _getHeatmapColor(condition.od600[i]),
        ));
      }
    }

    return SfCartesianChart(
      primaryXAxis: NumericAxis(title: AxisTitle(text: 'Time (hours)')),
      primaryYAxis: CategoryAxis(title: AxisTitle(text: 'Conditions')),
      series: <ChartSeries>[
        ScatterSeries<ChartData, double>(
          dataSource: heatmapData,
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.condition.hashCode.toDouble(),
          color: data.color,
          markerSettings: MarkerSettings(
            isVisible: true,
            shape: DataMarkerType.rectangle,
            width: 20,
            height: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildRadarChart(List<dynamic> data) {
    // Create radar data from parameters
    final radarData = data.map((condition) {
      final params = condition.parameters;
      return [
        params['carrying_capacity'] ?? 0.0,
        params['growth_rate'] ?? 0.0,
        params['lag_time'] ?? 0.0,
        params['doubling_time'] ?? 0.0,
      ];
    }).toList();

    return SfCircularChart(
      title: ChartTitle(text: 'Growth Parameters'),
      series: <CircularSeries>[
        RadarSeries<List<double>, String>(
          dataSource: radarData,
          xValueMapper: (data, index) => ['Capacity', 'Rate', 'Lag', 'Doubling'][index],
          yValueMapper: (data, index) => data[index],
          pointColorMapper: (data, index) => _getConditionColor(data[index].toString()),
        ),
      ],
    );
  }

  Widget _buildScienceChart(List<dynamic> data) {
    // Create bar chart for scientific parameters
    final barData = <ChartData>[];
    for (var condition in data) {
      final params = condition.parameters;
      barData.addAll([
        ChartData('Capacity', condition.condition, params['carrying_capacity'] ?? 0.0, _getConditionColor(condition.condition)),
        ChartData('Rate', condition.condition, params['growth_rate'] ?? 0.0, _getConditionColor(condition.condition)),
        ChartData('Lag', condition.condition, params['lag_time'] ?? 0.0, _getConditionColor(condition.condition)),
        ChartData('Doubling', condition.condition, params['doubling_time'] ?? 0.0, _getConditionColor(condition.condition)),
      ]);
    }

    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(),
      series: <ChartSeries>[
        ColumnSeries<ChartData, String>(
          dataSource: barData,
          xValueMapper: (ChartData data, _) => data.condition,
          yValueMapper: (ChartData data, _) => data.y,
          color: data.color,
          name: data.x,
        ),
      ],
      legend: Legend(isVisible: true),
    );
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case 'Control':
        return const Color(0xFF00F5C4);
      case 'Treatment A':
        return const Color(0xFFFF6B6B);
      case 'Treatment B':
        return const Color(0xFFFFD93D);
      case 'Treatment C':
        return const Color(0xFFC084FC);
      default:
        return Colors.grey;
    }
  }

  Color _getHeatmapColor(double value) {
    // Create heatmap color based on OD value
    final intensity = (value / 2.0).clamp(0.0, 1.0);
    return Color.lerp(Colors.blue, Colors.red, intensity) ?? Colors.blue;
  }
}

class ChartData {
  final String condition;
  final dynamic x;
  final double y;
  final Color color;

  ChartData(this.condition, this.x, this.y, this.color);
}