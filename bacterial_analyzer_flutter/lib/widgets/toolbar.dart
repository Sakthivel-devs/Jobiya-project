import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';

class CustomToolbar extends StatelessWidget {
  const CustomToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final options = context.watch<DataProvider>().toolbarOptions;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildToggleButton(context, '📊 Phases', 'phases', options['phases'] ?? true),
            const SizedBox(width: 8),
            _buildToggleButton(context, '📈 Log Scale', 'log_scale', options['log_scale'] ?? false),
            const SizedBox(width: 8),
            _buildToggleButton(context, '± Errors', 'errors', options['errors'] ?? false),
            const SizedBox(width: 8),
            _buildToggleButton(context, '〜 Curve Fit', 'fit', options['fit'] ?? true),
            const SizedBox(width: 8),
            _buildToggleButton(context, '🔮 Predict', 'predict', options['predict'] ?? false),
            const SizedBox(width: 16),
            Container(
              width: 1,
              height: 24,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
            const SizedBox(width: 16),
            _buildActionButton(context, '🔍 Reset', () => _resetToolbar(context)),
            const SizedBox(width: 8),
            _buildToggleButton(context, '✨ Animate', 'animate', false),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(BuildContext context, String label, String option, bool isActive) {
    return GestureDetector(
      onTap: () => context.read<DataProvider>().updateToolbarOption(option, !isActive),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _resetToolbar(BuildContext context) {
    final provider = context.read<DataProvider>();
    provider.updateToolbarOption('phases', true);
    provider.updateToolbarOption('log_scale', false);
    provider.updateToolbarOption('errors', false);
    provider.updateToolbarOption('fit', true);
    provider.updateToolbarOption('predict', false);
  }
}