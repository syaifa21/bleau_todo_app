import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; // Pastikan import ini benar
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bleau_todo_app/models/task.dart'; // Import model Task

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay; // Harus nullable karena bisa tidak ada yang dipilih
  late Box<Task> _taskBox;
  List<Task> _tasksOnSelectedDay = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay; // Default: Hari ini dipilih
    
    // Memastikan box 'tasks' sudah terbuka sebelum mengaksesnya
    // Karena kita membuka box di main.dart, ini seharusnya aman.
    // Jika ada kasus di mana aplikasi dibuka langsung ke CalendarScreen (jarang),
    // maka kita perlu penanganan async di sini juga.
    if (Hive.isBoxOpen('tasks')) {
      _taskBox = Hive.box<Task>('tasks');
      _getTasksForSelectedDay(_selectedDay!); // Muat tugas untuk hari ini
    } else {
      // Fallback: Jika box belum terbuka (misalnya, aplikasi dimulai langsung dari calendar screen)
      _openHiveBoxAndLoadTasks(); // Panggil fungsi async untuk membuka box dan memuat tugas
    }
  }

  Future<void> _openHiveBoxAndLoadTasks() async {
    // Pastikan Hive sudah diinisialisasi di main.dart sebelum mencoba membuka box
    await Hive.openBox<Task>('tasks');
    _taskBox = Hive.box<Task>('tasks');
    _getTasksForSelectedDay(_selectedDay!);
  }

  void _getTasksForSelectedDay(DateTime day) {
    setState(() {
      _tasksOnSelectedDay = _taskBox.values.where((task) {
        // Gunakan isSameDay dari table_calendar untuk perbandingan tanggal yang akurat
        return isSameDay(task.date, day);
      }).toList();
    });
  }

  @override
  void dispose() {
    // Tidak perlu menutup _taskBox di dispose jika ingin tetap terbuka antar widget/sesi
    // karena _taskBox dibuka di main.dart.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Kegiatan'),
        elevation: 0,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              // `_selectedDay` bisa null, jadi gunakan isSameDay dengan operator null-aware
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              // Pastikan _selectedDay dan selectedDay tidak null saat dibandingkan
              if (_selectedDay == null || !isSameDay(_selectedDay!, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay; // update `_focusedDay` as well
                });
                _getTasksForSelectedDay(selectedDay); // Muat ulang tugas untuk hari yang dipilih
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) {
              // Menandai hari dengan kegiatan (misalnya, dot di bawah tanggal)
              // Pastikan _taskBox sudah terbuka sebelum eventLoader dipanggil
              if (!_taskBox.isOpen) return []; // Hindari error jika box belum siap
              return _taskBox.values.where((task) => isSameDay(task.date, day)).toList();
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: _buildEventsMarker(events.length),
                  );
                }
                return null;
              },
            ),
            headerStyle: const HeaderStyle( // Styling untuk header kalender
              formatButtonVisible: false, // Sembunyikan tombol format (Week, 2 Weeks, Month)
              titleCentered: true,
            ),
            calendarStyle: const CalendarStyle( // Styling untuk sel kalender
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.red, // Warna dot event
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          // Tambahkan Judul "Kegiatan Hari Ini"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Kegiatan ${(_selectedDay != null && isSameDay(_selectedDay!, DateTime.now())) ? 'Hari Ini' : _selectedDay?.toLocal().toString().split(' ')[0] ?? ''}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _tasksOnSelectedDay.isEmpty
                ? const Center(child: Text('Tidak ada kegiatan untuk hari ini.'))
                : ListView.builder(
                    itemCount: _tasksOnSelectedDay.length,
                    itemBuilder: (context, index) {
                      final task = _tasksOnSelectedDay[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          title: Text(task.name),
                          subtitle: Text('${task.type} - ${task.status}'),
                          // Kamu bisa menambahkan ikon edit/hapus di sini juga jika mau
                          // trailing: Row(
                          //   mainAxisSize: MainAxisSize.min,
                          //   children: [
                          //     IconButton(icon: const Icon(Icons.edit), onPressed: () { /* logic */ }),
                          //     IconButton(icon: const Icon(Icons.delete), onPressed: () { /* logic */ }),
                          //   ],
                          // ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsMarker(int count) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue[400],
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }
}