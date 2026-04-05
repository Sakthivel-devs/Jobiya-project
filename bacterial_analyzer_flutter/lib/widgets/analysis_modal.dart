import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';

class AnalysisModal extends StatelessWidget {
  final String condition;

  const AnalysisModal({super.key, required this.condition});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>().data;
    final conditionData = data.firstWhere(
      (d) => d.condition == condition,
      orElse: () => BacterialData(
        condition: condition,
        time: [],
        od600: [],
        parameters: {},
      ),
    );

    final params = conditionData.parameters;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getConditionColor(condition),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$condition Analysis',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildParameterGrid(params),
          const SizedBox(height: 24),
          _buildInsights(params),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterGrid(Map<String, dynamic> params) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2,
      children: [
        _buildParameterCard('Carrying Capacity', params['carrying_capacity']?.toStringAsFixed(3) ?? 'N/A', 'L'),
        _buildParameterCard('Growth Rate', params['growth_rate']?.toStringAsFixed(3) ?? 'N/A', 'h⁻¹'),
        _buildParameterCard('Lag Time', params['lag_time']?.toStringAsFixed(1) ?? 'N/A', 'h'),
        _buildParameterCard('Doubling Time', params['doubling_time']?.toStringAsFixed(1) ?? 'N/A', 'h'),
      ],
    );
  }

  Widget _buildParameterCard(String label, String value, String unit) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1826),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF1A2D42),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF7A9AB5),
              fontWeight: FontWeight.w500,
              fontFamily: 'SpaceMono',
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF00F5C4),
                  fontFamily: 'SpaceMono',
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7A9AB5),
                  fontFamily: 'SpaceMono',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsights(Map<String, dynamic> params) {
    final carryingCapacity = params['carrying_capacity'] ?? 0.0;
    final growthRate = params['growth_rate'] ?? 0.0;
    final lagTime = params['lag_time'] ?? 0.0;

    String insight = 'Analysis in progress...';

    if (carryingCapacity > 0) {
      if (lagTime < 2) {
        insight = 'Excellent growth conditions with minimal lag phase. Optimal culture setup.';
      } else if (lagTime > 5) {
        insight = 'Extended lag phase detected. Consider optimizing inoculum or media conditions.';
      } else if (growthRate > 0.5) {
        insight = 'Rapid growth observed. Monitor for potential contamination or excessive nutrients.';
      } else {
        insight = 'Standard growth pattern observed. Conditions appear suitable for bacterial culture.';
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1520),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1A2D42),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Insights',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFDDEEFF),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            insight,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7A9AB5),
              height: 1.4,
            ),
          ),
        ],
      ),
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
}