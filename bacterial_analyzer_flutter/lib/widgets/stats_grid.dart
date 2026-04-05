import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>().data;

    return Container(
      margin: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5,
        ),
        itemCount: data.length,
        itemBuilder: (context, index) => _buildStatCard(context, data[index]),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, dynamic conditionData) {
    final maxOD = conditionData.od600.isNotEmpty
        ? conditionData.od600.reduce((a, b) => a > b ? a : b).toStringAsFixed(3)
        : '0.000';

    final growthRate = conditionData.parameters['growth_rate']?.toStringAsFixed(3) ?? 'N/A';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getConditionColor(conditionData.condition),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    conditionData.condition,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.analytics, size: 16),
                  onPressed: () => _showAnalysis(context, conditionData.condition),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('MAX OD', maxOD),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem('GROWTH', growthRate),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
            fontFamily: 'SpaceMono',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFamily: 'SpaceMono',
            color: Color(0xFF00F5C4),
          ),
        ),
      ],
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

  void _showAnalysis(BuildContext context, String condition) {
    context.read<DataProvider>().analyzeCondition(condition);
    showModalBottomSheet(
      context: context,
      builder: (context) => AnalysisModal(condition: condition),
    );
  }
}