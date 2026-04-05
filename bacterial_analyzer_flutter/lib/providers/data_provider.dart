import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BacterialData {
  final String condition;
  final List<double> time;
  final List<double> od600;
  final Map<String, dynamic> parameters;

  BacterialData({
    required this.condition,
    required this.time,
    required this.od600,
    required this.parameters,
  });

  factory BacterialData.fromJson(Map<String, dynamic> json) {
    return BacterialData(
      condition: json['condition'] ?? '',
      time: List<double>.from(json['time'] ?? []),
      od600: List<double>.from(json['od600'] ?? []),
      parameters: json['parameters'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'condition': condition,
      'time': time,
      'od600': od600,
      'parameters': parameters,
    };
  }
}

class DataProvider with ChangeNotifier {
  List<BacterialData> _data = [];
  bool _isLoading = false;
  String _currentTab = 'growth';
  Map<String, bool> _toolbarOptions = {
    'phases': true,
    'log_scale': false,
    'errors': false,
    'fit': true,
    'predict': false,
  };

  // Getters
  List<BacterialData> get data => _data;
  bool get isLoading => _isLoading;
  String get currentTab => _currentTab;
  Map<String, bool> get toolbarOptions => _toolbarOptions;

  // Backend URL - change this to your server
  final String baseUrl = 'http://10.0.2.2:5000'; // Android emulator localhost

  DataProvider() {
    loadSampleData();
    loadSavedData();
  }

  Future<void> loadSampleData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$baseUrl/api/data'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        _data = (jsonData as Map<String, dynamic>).entries.map((entry) {
          return BacterialData.fromJson({
            'condition': entry.key,
            'time': entry.value['time'],
            'od600': entry.value['od600'],
            'parameters': {},
          });
        }).toList();
      }
    } catch (e) {
      // Load local sample data if server not available
      _loadLocalSampleData();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _loadLocalSampleData() {
    // Generate sample data locally
    final conditions = ['Control', 'Treatment A', 'Treatment B', 'Treatment C'];
    final random = DateTime.now().millisecondsSinceEpoch;

    _data = conditions.map((condition) {
      final time = List.generate(50, (i) => i * 0.5); // 0 to 24.5 hours
      final od600 = time.map((t) {
        // Logistic growth simulation
        final L = 1.5 + (random % 1000) / 1000; // Carrying capacity
        final k = 0.3 + (random % 500) / 1000; // Growth rate
        final x0 = 0.01 + (random % 50) / 1000; // Initial value
        return L / (1 + (L / x0 - 1) * math.exp(-k * t));
      }).toList();

      return BacterialData(
        condition: condition,
        time: time,
        od600: od600,
        parameters: {},
      );
    }).toList();
  }

  Future<void> analyzeCondition(String condition) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/analyze/$condition'));
      if (response.statusCode == 200) {
        final analysis = json.decode(response.body);
        // Update the data with analysis results
        final index = _data.indexWhere((d) => d.condition == condition);
        if (index != -1) {
          _data[index] = BacterialData(
            condition: _data[index].condition,
            time: _data[index].time,
            od600: _data[index].od600,
            parameters: analysis,
          );
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Analysis failed: $e');
    }
  }

  Future<String?> getChartData(String chartType) async {
    try {
      final params = _toolbarOptions.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      final url = '$baseUrl/api/chart/$chartType?$params';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['chart'];
      }
    } catch (e) {
      debugPrint('Chart loading failed: $e');
    }
    return null;
  }

  void switchTab(String tab) {
    _currentTab = tab;
    notifyListeners();
  }

  void updateToolbarOption(String option, bool value) {
    _toolbarOptions[option] = value;
    notifyListeners();
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataJson = _data.map((d) => d.toJson()).toList();
    await prefs.setString('bacterial_data', json.encode(dataJson));
  }

  Future<void> loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString('bacterial_data');
    if (dataString != null) {
      final dataJson = json.decode(dataString) as List;
      _data = dataJson.map((d) => BacterialData.fromJson(d)).toList();
      notifyListeners();
    }
  }

  Future<void> importCSV(String csvContent) async {
    // Parse CSV and update data
    // Implementation would depend on CSV format
    notifyListeners();
  }

  void updateDataPoint(String condition, int index, double newValue) {
    final dataIndex = _data.indexWhere((d) => d.condition == condition);
    if (dataIndex != -1 && index < _data[dataIndex].od600.length) {
      final updatedOd600 = List<double>.from(_data[dataIndex].od600);
      updatedOd600[index] = newValue;

      _data[dataIndex] = BacterialData(
        condition: _data[dataIndex].condition,
        time: _data[dataIndex].time,
        od600: updatedOd600,
        parameters: _data[dataIndex].parameters,
      );
      notifyListeners();
    }
  }
}