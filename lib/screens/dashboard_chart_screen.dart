import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart
import 'package:hive_flutter/hive_flutter.dart'; // Import Hive
import 'package:bleau_todo_app/models/task.dart'; // Import model Task

class DashboardChartScreen extends StatefulWidget { // <--- Pastikan namanya SAMA PERSIS
  const DashboardChartScreen({super.key});

  @override
  State<DashboardChartScreen> createState() => _DashboardChartScreenState();
}

class _DashboardChartScreenState extends State<DashboardChartScreen> {
  late Box<Task> _taskBox;
  Map<String, int> _taskTypeCounts = {}; // Untuk menghitung jumlah tugas berdasarkan jenis
  Map<String, int> _taskStatusCounts = {}; // Untuk menghitung jumlah tugas berdasarkan status

  @override
  void initState() {
    super.initState();
    if (Hive.isBoxOpen('tasks')) {
      _taskBox = Hive.box<Task>('tasks');
      _calculateTaskData(); // Hitung data saat initState
    } else {
      // Fallback jika box belum terbuka (jarang terjadi)
      _openHiveBoxAndCalculateData();
    }
  }

  Future<void> _openHiveBoxAndCalculateData() async {
    await Hive.openBox<Task>('tasks');
    _taskBox = Hive.box<Task>('tasks');
    _calculateTaskData();
  }

  void _calculateTaskData() {
    _taskTypeCounts = {};
    _taskStatusCounts = {};

    for (var task in _taskBox.values) {
      // Hitung berdasarkan Jenis Kegiatan
      _taskTypeCounts[task.type] = (_taskTypeCounts[task.type] ?? 0) + 1;
      // Hitung berdasarkan Status Kegiatan
      _taskStatusCounts[task.status] = (_taskStatusCounts[task.status] ?? 0) + 1;
    }

    setState(() {}); // Perbarui UI setelah data dihitung
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekapan Kegiatan'),
        elevation: 0,
      ),
      body: _taskBox.isEmpty
          ? const Center(
              child: Text(
                'Tidak ada kegiatan untuk direkap.\nTambahkan kegiatan terlebih dahulu!',
                textAlign: TextAlign.center,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChartSection(
                    title: 'Rekapan Berdasarkan Jenis',
                    dataCounts: _taskTypeCounts,
                    colors: {
                      'Pribadi': Colors.blue,
                      'Kerja': Colors.green,
                      'Wishlist': Colors.purple,
                      'Lainnya': Colors.orange,
                    },
                  ),
                  const SizedBox(height: 32),
                  _buildChartSection(
                    title: 'Rekapan Berdasarkan Status',
                    dataCounts: _taskStatusCounts,
                    colors: {
                      'Belum Dimulai': Colors.red,
                      'Dalam Proses': Colors.yellow,
                      'Selesai': Colors.green,
                    },
                  ),
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
      return const SizedBox.shrink(); // Jangan tampilkan jika tidak ada data
    }

    List<PieChartSectionData> sections = dataCounts.entries.map((entry) {
      final isTouched = false; // Bisa ditambahkan interaksi sentuhan
      final fontSize = isTouched ? 20.0 : 12.0;
      final radius = isTouched ? 60.0 : 50.0;
      final widgetStyle = TextStyle(
        color: const Color(0xffffffff),
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      );

      return PieChartSectionData(
        color: colors[entry.key] ?? Colors.grey, // Warna default jika tidak ada
        value: entry.value.toDouble(),
        title: '${entry.value}', // Tampilkan jumlah
        radius: radius,
        titleStyle: widgetStyle,
        badgeWidget: _buildBadge(entry.key, colors[entry.key] ?? Colors.grey), // Tampilkan nama kategori
        badgePositionPercentageOffset: .98,
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200, // Ukuran chart
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(enabled: false), // Nonaktifkan interaksi sentuhan untuk kesederhanaan
              sections: sections,
              centerSpaceRadius: 40, // Ukuran lubang di tengah
              sectionsSpace: 2, // Jarak antar segmen
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildIndicators(dataCounts, colors), // Legend/indikator chart
      ],
    );
  }

  Widget _buildIndicators(Map<String, int> dataCounts, Map<String, Color> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: dataCounts.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors[entry.key] ?? Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Text('${entry.key}: ${entry.value}'),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
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