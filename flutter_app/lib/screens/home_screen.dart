import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../widgets/tab_bar.dart';
import '../widgets/toolbar.dart';
import '../widgets/chart_display.dart';
import '../widgets/stats_grid.dart';
import '../widgets/analysis_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bacterial Culture Analyzer Pro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => context.read<DataProvider>().saveData(),
          ),
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: _importCSV,
          ),
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: _showAbout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          const CustomTabBar(),

          // Toolbar
          const CustomToolbar(),

          // Stats Grid
          const StatsGrid(),

          // Chart Display
          const Expanded(
            child: ChartDisplay(),
          ),
        ],
      ),
    );
  }

  void _importCSV() {
    // Implement CSV import
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CSV import coming soon')),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bacterial Culture Analyzer Pro'),
            Text('Version 1.0.0'),
            SizedBox(height: 8),
            Text('Professional bacterial growth analysis tool'),
            Text('with AI-powered insights'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}