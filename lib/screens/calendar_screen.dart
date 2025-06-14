import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bleau_todo_app/models/task.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late Box<Task> _taskBox;
  List<Task> _tasksOnSelectedDay = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    if (Hive.isBoxOpen('tasks')) {
      _taskBox = Hive.box<Task>('tasks');
      _getTasksForSelectedDay(_selectedDay!);
    } else {
      _openHiveBoxAndLoadTasks();
    }
  }

  Future<void> _openHiveBoxAndLoadTasks() async {
    await Hive.openBox<Task>('tasks');
    _taskBox = Hive.box<Task>('tasks');
    _getTasksForSelectedDay(_selectedDay!);
  }

  void _getTasksForSelectedDay(DateTime day) {
    setState(() {
      _tasksOnSelectedDay = _taskBox.values.where((task) {
        return isSameDay(task.date, day);
      }).toList();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Kegiatan'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (_selectedDay == null || !isSameDay(_selectedDay!, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _getTasksForSelectedDay(selectedDay);
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) {
              if (!_taskBox.isOpen) return [];
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
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                leftChevronIcon: Icon(Icons.chevron_left, color: Theme.of(context).primaryColor), // <--- PERBAIKAN
                rightChevronIcon: Icon(Icons.chevron_right, color: Theme.of(context).primaryColor), // <--- PERBAIKAN
              ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: Colors.redAccent, // Warna dot event yang lebih cerah
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false, // Sembunyikan hari dari bulan sebelumnya/berikutnya
              defaultTextStyle: TextStyle(color: Colors.blueGrey[800]),
              weekendTextStyle: TextStyle(color: Colors.red[600]),
              holidayTextStyle: TextStyle(color: Colors.red[600]),
            ),
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Kegiatan ${(_selectedDay != null && isSameDay(_selectedDay!, DateTime.now())) ? 'Hari Ini' : _selectedDay?.toLocal().toString().split(' ')[0] ?? ''}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _tasksOnSelectedDay.isEmpty
                ? Center(
                    child: Text('Tidak ada kegiatan pada tanggal ini.', style: Theme.of(context).textTheme.bodyLarge),
                  )
                : ListView.builder(
                    itemCount: _tasksOnSelectedDay.length,
                    itemBuilder: (context, index) {
                      final task = _tasksOnSelectedDay[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        elevation: 3, // Sedikit lebih menonjol
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(task.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          subtitle: Text('${task.type} - ${task.status}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
                          trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey[400]),
                          onTap: () {
                            // TODO: Navigasi ke detail tugas di DashboardScreen atau tampilkan dialog detail
                            // Ini akan memerlukan mekanisme komunikasi antar screen atau navigator
                            // Untuk saat ini, kita biarkan saja sebagai tampilan sederhana
                          },
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
        color: Theme.of(context).colorScheme.secondary, // Warna aksen dari tema
      ),
      width: 18.0, // Ukuran marker sedikit lebih besar
      height: 18.0,
      child: Center(
        child: Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}