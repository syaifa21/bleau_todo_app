// Path: lib/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bleau_todo_app/models/task.dart';
import 'package:bleau_todo_app/screens/calendar_screen.dart';
import 'package:bleau_todo_app/screens/dashboard_chart_screen.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:bleau_todo_app/screens/settings_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io'; // Import untuk File

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String _selectedFilter = 'Semua';

  late Box<Task> _taskBox;

  final TextEditingController _namaKegiatanController = TextEditingController();
  final TextEditingController _detailKegiatanController = TextEditingController();

  String? _selectedAttachmentPath;

  final List<String> _statusOptions = ['Belum Dimulai', 'Dalam Proses', 'Selesai'];
  final List<String> _jenisKegiatanOptions = ['Pribadi', 'Kerja', 'Wishlist', 'Lainnya'];

  final _formKey = GlobalKey<FormState>();

  late Future<void> _hiveInitFuture;

  @override
  void initState() {
    super.initState();
    _hiveInitFuture = _openHiveBox();
  }

  Future<void> _openHiveBox() async {
    if (!Hive.isBoxOpen('tasks')) {
      _taskBox = await Hive.openBox<Task>('tasks');
    } else {
      _taskBox = Hive.box<Task>('tasks');
    }
  }

  @override
  void dispose() {
    _namaKegiatanController.dispose();
    _detailKegiatanController.dispose();
    super.dispose();
  }

  void _onBottomNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _hiveInitFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final List<Widget> bottomNavPages = <Widget>[
              _buildTasksPage(context),
              const CalendarScreen(),
              const DashboardChartScreen(),
              const SettingsScreen(),
            ];
            return bottomNavPages.elementAt(_selectedIndex);
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                _namaKegiatanController.clear();
                _detailKegiatanController.clear();
                _selectedAttachmentPath = null;
                _showAddTaskDialog(context);
              },
              child: const Icon(Icons.add),
              backgroundColor: Theme.of(context).primaryColor,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).cardColor,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Tugas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Kalender',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Rekapan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onBottomNavItemTapped,
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, {Task? taskToEdit}) {
    _namaKegiatanController.text = taskToEdit?.name ?? '';
    _detailKegiatanController.text = taskToEdit?.detail ?? '';

    DateTime? dialogSelectedDate = taskToEdit?.date ?? DateTime.now();
    DateTime? dialogSelectedDeadline = taskToEdit?.deadline;
    String? dialogSelectedStatus = taskToEdit?.status ?? _statusOptions[0];
    String? dialogSelectedJenis = taskToEdit?.type ?? _jenisKegiatanOptions[0];
    _selectedAttachmentPath = taskToEdit?.attachmentPath;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              surfaceTintColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(taskToEdit == null ? 'Tambah Kegiatan Baru' : 'Edit Kegiatan',
                  style: Theme.of(context).textTheme.titleLarge),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        controller: _namaKegiatanController,
                        decoration: const InputDecoration(labelText: 'Nama Kegiatan', hintText: 'Misal: Rapat Proyek'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama Kegiatan tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _detailKegiatanController,
                        decoration: const InputDecoration(labelText: 'Detail Kegiatan', hintText: 'Deskripsi singkat tugas'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      _buildDatePickerTile(
                        context,
                        'Tanggal Kegiatan',
                        dialogSelectedDate,
                        (pickedDate) {
                          setDialogState(() {
                            dialogSelectedDate = pickedDate;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Status Kegiatan'),
                        value: dialogSelectedStatus,
                        items: _statusOptions.map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setDialogState(() {
                            dialogSelectedStatus = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Pilih Status Kegiatan';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDatePickerTile(
                        context,
                        'Deadline',
                        dialogSelectedDeadline,
                        (pickedDateTime) {
                          setDialogState(() {
                            dialogSelectedDeadline = pickedDateTime;
                          });
                        },
                        withTime: true,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Jenis Kegiatan'),
                        value: dialogSelectedJenis,
                        items: _jenisKegiatanOptions.map((String jenis) {
                          return DropdownMenuItem<String>(
                            value: jenis,
                            child: Text(jenis),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setDialogState(() {
                            dialogSelectedJenis = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Pilih Jenis Kegiatan';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          FilePickerResult? result = await FilePicker.platform.pickFiles(
                            type: FileType.any,
                          );

                          if (result != null) {
                            setDialogState(() {
                              _selectedAttachmentPath = result.files.single.path;
                            });
                          } else {
                            setDialogState(() {
                              _selectedAttachmentPath = null;
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Icon(Icons.attach_file, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _selectedAttachmentPath != null
                                      ? 'File Terpilih: ${_selectedAttachmentPath!.split('/').last.split('\\').last}'
                                      : 'Tambahkan Lampiran (Opsional)',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_selectedAttachmentPath != null)
                                IconButton(
                                  icon: const Icon(Icons.clear, size: 20),
                                  onPressed: () {
                                    setDialogState(() {
                                      _selectedAttachmentPath = null;
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Batal'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Simpan'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (taskToEdit == null) {
                        final newTask = Task(
                          name: _namaKegiatanController.text,
                          detail: _detailKegiatanController.text.isNotEmpty ? _detailKegiatanController.text : null,
                          date: dialogSelectedDate ?? DateTime.now(),
                          status: dialogSelectedStatus ?? _statusOptions[0],
                          deadline: dialogSelectedDeadline,
                          type: dialogSelectedJenis ?? _jenisKegiatanOptions[0],
                          attachmentPath: _selectedAttachmentPath,
                        );
                        _taskBox.add(newTask);
                      } else {
                        taskToEdit.name = _namaKegiatanController.text;
                        taskToEdit.detail = _detailKegiatanController.text.isNotEmpty ? _detailKegiatanController.text : null;
                        taskToEdit.date = dialogSelectedDate ?? DateTime.now();
                        taskToEdit.status = dialogSelectedStatus ?? _statusOptions[0];
                        taskToEdit.deadline = dialogSelectedDeadline;
                        taskToEdit.type = dialogSelectedJenis ?? _jenisKegiatanOptions[0];
                        taskToEdit.attachmentPath = _selectedAttachmentPath;
                        taskToEdit.save();
                      }
                      Navigator.of(dialogContext).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDatePickerTile(
      BuildContext context, String label, DateTime? selectedDateTime, Function(DateTime?) onDateTimeSelected,
      {bool withTime = false}) {
    return ListTile(
      title: Text(
        '$label: ${selectedDateTime != null ? (withTime ? DateFormat('dd MMM replete HH:mm').format(selectedDateTime) : DateFormat('dd MMM replete').format(selectedDateTime)) : 'Pilih Tanggal${withTime ? ' & Jam' : ''}'}',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      trailing: Icon(withTime ? Icons.access_time : Icons.calendar_today),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDateTime ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          if (withTime) {
            final TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(selectedDateTime ?? DateTime.now()),
            );
            if (pickedTime != null) {
              onDateTimeSelected(DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              ));
            } else {
              onDateTimeSelected(pickedDate);
            }
          } else {
            onDateTimeSelected(pickedDate);
          }
        }
      },
      contentPadding: EdgeInsets.zero,
    );
  }

  void _confirmDeleteTask(BuildContext context, dynamic taskKey, String taskName) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Kegiatan'),
          content: Text('Apakah Anda yakin ingin menghapus kegiatan "$taskName"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
              onPressed: () {
                _taskBox.delete(taskKey);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Helper untuk mengecek apakah path adalah gambar
  bool _isImagePath(String? path) {
    if (path == null || path.isEmpty) return false;
    final lowerCasePath = path.toLowerCase();
    return lowerCasePath.endsWith('.jpg') ||
           lowerCasePath.endsWith('.jpeg') ||
           lowerCasePath.endsWith('.png') ||
           lowerCasePath.endsWith('.gif') ||
           lowerCasePath.endsWith('.bmp') ||
           lowerCasePath.endsWith('.webp');
  }

  void _showTaskDetailDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(task.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Divider(),
                _buildDetailRow(
                    'Detail Kegiatan', task.detail ?? '-'),
                _buildDetailRow('Tanggal Kegiatan', DateFormat('dd MMM replete').format(task.date)),
                _buildDetailRow('Status Kegiatan', task.status),
                _buildDetailRow('Jenis Kegiatan', task.type),
                if (task.deadline != null)
                  _buildDetailRow('Deadline', DateFormat('dd MMM replete HH:mm').format(task.deadline!)),
                
                // Menampilkan preview gambar atau nama file yang bisa diklik
                if (task.attachmentPath != null && task.attachmentPath!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lampiran:',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        if (_isImagePath(task.attachmentPath))
                          GestureDetector(
                            onTap: () async {
                              await OpenFilex.open(task.attachmentPath!);
                            },
                            child: Container(
                              width: double.infinity, // Maks lebar
                              height: 150, // Tinggi tetap untuk preview
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              clipBehavior: Clip.antiAlias, // Penting untuk borderRadius pada gambar
                              child: Image.file(
                                File(task.attachmentPath!),
                                fit: BoxFit.cover, // Gambar akan mengisi ruang yang tersedia
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.broken_image, size: 40, color: Colors.grey[500]),
                                          const SizedBox(height: 8),
                                          Text('Tidak dapat memuat gambar', style: TextStyle(color: Colors.grey[600])),
                                          Text(task.attachmentPath!.split('/').last.split('\\').last, style: TextStyle(color: Colors.grey[600])),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: () async {
                              await OpenFilex.open(task.attachmentPath!);
                            },
                            child: _buildDetailRow(
                              '', // Label kosong karena sudah ada di atas
                              task.attachmentPath!.split('/').last.split('\\').last,
                              isLink: true,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () async {
                              await OpenFilex.open(task.attachmentPath!);
                            },
                            child: const Text('Buka Lampiran'),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  _buildDetailRow('Lampiran', 'Tidak ada'), // Jika tidak ada lampiran
                const Divider(),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tutup'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 2),
          ],
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: isLink ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
              decoration: isLink ? TextDecoration.underline : TextDecoration.none,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTasksPage(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _taskBox.listenable(),
      builder: (context, Box<Task> box, _) {
        List<Task> currentTasks = box.values.toList();

        List<Task> filteredTasks = currentTasks.where((task) {
          if (_selectedFilter == 'Semua') {
            return true;
          }
          return task.status == _selectedFilter;
        }).toList();

        filteredTasks.sort((a, b) => a.date.compareTo(b.date));

        bool hasTasks = filteredTasks.isNotEmpty;
        const String illustrationPath = 'assets/images/no_tasks_illustration.png';

        return Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, left: 16, right: 16, bottom: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StreamBuilder<DateTime>(
                    stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final currentTime = snapshot.data!;
                        final formattedDate = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(currentTime);
                        final formattedTime = DateFormat('HH:mm:ss').format(currentTime);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formattedDate,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Theme.of(context).primaryColor.withOpacity(0.8),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              formattedTime,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                              ),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Halo, Pengguna!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: <Widget>[
                        _buildFilterChip('Semua'),
                        const SizedBox(width: 8),
                        ..._statusOptions.map((status) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: _buildFilterChip(status),
                            )).toList(),
                        IconButton(
                          icon: Icon(Icons.more_horiz, color: Colors.grey[700]),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Opsi filter lainnya belum diimplementasikan.')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Expanded(
              child: hasTasks
                  ? SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ..._jenisKegiatanOptions.map((type) {
                            List<Task> tasksForType = filteredTasks
                                .where((task) => task.type == type)
                                .toList();

                            if (tasksForType.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                  child: Text(
                                    type,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                                  ),
                                ),
                                ...tasksForType.map((task) => _buildTaskCard(task)).toList(),
                                if (_jenisKegiatanOptions.last != type)
                                  const SizedBox(height: 24),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    )
                  : _buildEmptyTasksState(illustrationPath),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTaskCard(Task task) {
    final taskKey = task.key;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          _showTaskDetailDialog(context, task);
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 8,
              decoration: BoxDecoration(
                color: _getTaskTypeColor(task.type),
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      task.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                    if (task.detail != null && task.detail!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          task.detail!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 12),
                    _buildTaskInfoRow(Icons.calendar_today_outlined, 'Tanggal', DateFormat('dd MMM replete').format(task.date)),
                    if (task.deadline != null)
                      _buildTaskInfoRow(Icons.access_time, 'Deadline', DateFormat('dd MMM replete HH:mm').format(task.deadline!)),
                    _buildTaskInfoRow(Icons.category_outlined, 'Jenis', task.type),
                    _buildTaskInfoRow(Icons.info_outline, 'Status', task.status),
                    if (task.attachmentPath != null && task.attachmentPath!.isNotEmpty)
                      _buildTaskInfoRow(Icons.attach_file, 'Lampiran', task.attachmentPath!.split('/').last.split('\\').last),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                          onPressed: () {
                            _showAddTaskDialog(context, taskToEdit: task);
                          },
                          tooltip: 'Edit Kegiatan',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () {
                            if (taskKey != null) {
                              _confirmDeleteTask(context, taskKey, task.name);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Tidak dapat menghapus: Task Key tidak ditemukan.')),
                              );
                            }
                          },
                          tooltip: 'Hapus Kegiatan',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedFilter == label,
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            _selectedFilter = label;
          });
        }
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: _selectedFilter == label ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium?.color,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
        side: BorderSide(
          color: _selectedFilter == label ? Theme.of(context).primaryColor : Theme.of(context).dividerColor,
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      elevation: 2,
      shadowColor: Colors.black12,
    );
  }

  Color _getTaskTypeColor(String type) {
    switch (type) {
      case 'Pribadi':
        return Colors.blueAccent;
      case 'Kerja':
        return Colors.green;
      case 'Wishlist':
        return Colors.purpleAccent;
      case 'Lainnya':
        return Colors.orangeAccent;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTaskInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTasksState(String illustrationPath) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              illustrationPath,
              height: 200,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.assignment_turned_in,
                  size: 150,
                  color: Colors.grey[300],
                );
              },
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Text(
                'Klik tombol "+" di pojok kanan bawah untuk membuat tugas pertamamu.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.brown[700],
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Ayo mulai kelola kegiatanmu!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ],
        ),
      ),
    );
  }
}