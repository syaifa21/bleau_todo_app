// Path: lib/screens/dashboard_chart_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bleau_todo_app/models/task.dart';

class DashboardChartScreen extends StatefulWidget {
  const DashboardChartScreen({super.key});

  @override
  State<DashboardChartScreen> createState() => _DashboardChartScreenState();
}

class _DashboardChartScreenState extends State<DashboardChartScreen> {
  late Box<Task> _taskBox;
  Map<String, int> _taskTypeCounts = {};
  Map<String, int> _taskStatusCounts = {};

  // Warna-warna yang konsisten untuk chart
  final Map<String, Color> _typeColors = {
    'Pribadi': Colors.blueAccent,
    'Kerja': Colors.green,
    'Wishlist': Colors.purpleAccent,
    'Lainnya': Colors.orangeAccent,
  };
  final Map<String, Color> _statusColors = {
    'Belum Dimulai': Colors.redAccent,
    'Dalam Proses': Colors.amber,
    'Selesai': Colors.lightGreen,
  };

  @override
  void initState() {
    super.initState();
    _openHiveBoxAndCalculateData();
  }

  Future<void> _openHiveBoxAndCalculateData() async {
    if (!Hive.isBoxOpen('tasks')) {
      _taskBox = await Hive.openBox<Task>('tasks');
    } else {
      _taskBox = Hive.box<Task>('tasks');
    }
    _taskBox.listenable().addListener(_calculateTaskData);
    _calculateTaskData();
  }

  void _calculateTaskData() {
    if (!mounted) {
      return;
    }

    _taskTypeCounts = {};
    _taskStatusCounts = {};

    for (var task in _taskBox.values) {
      _taskTypeCounts[task.type] = (_taskTypeCounts[task.type] ?? 0) + 1;
      _taskStatusCounts[task.status] = (_taskStatusCounts[task.status] ?? 0) + 1;
    }

    setState(() {});
  }

  @override
  void dispose() {
    // *** KOREKSI: Menghapus '.hasListeners' dari kondisi ***
    // Cukup pastikan box terbuka sebelum mencoba menghapus listener.
    if (Hive.isBoxOpen('tasks')) { // Baris 67 yang dikoreksi
      _taskBox.listenable().removeListener(_calculateTaskData);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekapan Kegiatan'),
      ),
      body: _taskBox.isEmpty || (_taskTypeCounts.isEmpty && _taskStatusCounts.isEmpty)
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: 100,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Tidak ada kegiatan untuk direkap.\nTambahkan kegiatan dari tab Tugas!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChartSection(
                    title: 'Berdasarkan Jenis Kegiatan',
                    dataCounts: _taskTypeCounts,
                    colors: _typeColors,
                  ),
                  const SizedBox(height: 40),
                  _buildChartSection(
                    title: 'Berdasarkan Status Kegiatan',
                    dataCounts: _taskStatusCounts,
                    colors: _statusColors,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildChartSection({
    required String title,
    required Map<String, int> dataCounts,
    required Map<String, Color> colors,
  }) {
    if (dataCounts.isEmpty) {
      return const SizedBox.shrink();
    }

    List<PieChartSectionData> sections = dataCounts.entries.map((entry) {
      final percentage = (entry.value / (_taskBox.length > 0 ? _taskBox.length : 1)) * 100;
      final isTouched = false;
      final fontSize = isTouched ? 20.0 : 14.0;
      final radius = isTouched ? 65.0 : 60.0;
      final widgetStyle = TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      );

      return PieChartSectionData(
        color: colors[entry.key] ?? Colors.grey,
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: widgetStyle,
        badgeWidget: _buildBadge(entry.key, colors[entry.key] ?? Colors.grey),
        badgePositionPercentageOffset: .98,
      );
    }).toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(enabled: false),
                  sections: sections,
                  centerSpaceRadius: 50,
                  sectionsSpace: 3,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildIndicators(dataCounts, colors),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicators(Map<String, int> dataCounts, Map<String, Color> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: dataCounts.entries.map((entry) {
        final percentage = (_taskBox.length > 0 ? (entry.value / _taskBox.length) * 100 : 0.0);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors[entry.key] ?? Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${entry.key}: ${entry.value} (${percentage.toStringAsFixed(1)}%)',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.blueGrey[700]),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}