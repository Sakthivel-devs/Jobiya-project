import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';

class CustomTabBar extends StatelessWidget {
  const CustomTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentTab = context.watch<DataProvider>().currentTab;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          _buildTab(context, 'growth', 'Growth', currentTab == 'growth'),
          _buildTab(context, 'heatmap', 'Heatmap', currentTab == 'heatmap'),
          _buildTab(context, 'radar', 'Radar', currentTab == 'radar'),
          _buildTab(context, 'science', 'Science', currentTab == 'science'),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String tab, String label, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<DataProvider>().switchTab(tab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}