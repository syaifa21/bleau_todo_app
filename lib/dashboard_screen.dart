import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bleau_todo_app/models/task.dart';
import 'package:bleau_todo_app/screens/calendar_screen.dart'; // Import CalendarScreen

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // Untuk mengelola indeks navigasi bawah
  String _selectedFilter = 'Semua'; // Untuk mengelola filter kegiatan yang dipilih

  late Box<Task> _taskBox; // Deklarasi Box Hive untuk Task
  List<Task> _tasks = []; // List untuk menyimpan data tugas yang dimuat

  // Controller untuk inputan dialog
  final TextEditingController _namaKegiatanController = TextEditingController();
  final TextEditingController _detailKegiatanController = TextEditingController();

  // Variabel untuk Datepicker & Dropdown di dialog (digunakan sebagai nilai awal)
  DateTime? _initialSelectedDate;
  DateTime? _initialSelectedDeadline;
  String? _initialSelectedStatus;
  String? _initialSelectedJenis;

  // Daftar opsi untuk Status Kegiatan
  final List<String> _statusOptions = ['Belum Dimulai', 'Dalam Proses', 'Selesai'];

  // Daftar opsi untuk Jenis Kegiatan (sesuai diagram alur: Pribadi, Kerja, Wishlist, Lainnya)
  final List<String> _jenisKegiatanOptions = ['Pribadi', 'Kerja', 'Wishlist', 'Lainnya'];

  // GlobalKey untuk form validasi
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _openHiveBox(); // Panggil metode untuk membuka box Hive
  }

  Future<void> _openHiveBox() async {
    // Memastikan Hive sudah diinisialisasi di main.dart sebelum membuka box
    if (!Hive.isBoxOpen('tasks')) {
      _taskBox = await Hive.openBox<Task>('tasks'); // Buka box bernama 'tasks'
    } else {
      _taskBox = Hive.box<Task>('tasks');
    }
    _loadTasks(); // Muat tugas setelah box terbuka
  }

  void _loadTasks() {
    setState(() {
      // Pastikan _taskBox sudah diinisialisasi dan terbuka sebelum mengaksesnya
      if (_taskBox.isOpen) {
         _tasks = _taskBox.values.toList();
      } else {
         _tasks = []; // Jika box belum terbuka, set ke kosong
      }
    });
  }

  @override
  void dispose() {
    _namaKegiatanController.dispose();
    _detailKegiatanController.dispose();
    // Biasanya box ditutup di main atau saat aplikasi dihentikan sepenuhnya.
    // Jika hanya di dispose widget, box bisa terbuka lagi saat widget di-rebuild.
    // _taskBox.close(); 
    super.dispose();
  }

  void _onBottomNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Inisialisasi bottomNavPages DI SINI, di dalam build()
    // Agar context sudah sepenuhnya tersedia saat _buildTasksPage dipanggil
    final List<Widget> bottomNavPages = <Widget>[
      _buildTasksPage(context), // Halaman Dashboard Kegiatan (Tab "Tugas")
      const CalendarScreen(), // Halaman Kalender (Tab "Kalender")
      const Center(child: Text('Halaman Milikku')), // Placeholder (Tab "Milikku")
    ];

    return Scaffold(
      body: bottomNavPages.elementAt(_selectedIndex),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Tugas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Kalender',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Milikku',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onBottomNavItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0 // Hanya tampilkan FAB di tab "Tugas"
          ? FloatingActionButton(
              onPressed: () {
                // Reset nilai awal untuk form "Tambah Kegiatan"
                _initialSelectedDate = DateTime.now();
                _initialSelectedDeadline = null;
                _initialSelectedStatus = null;
                _initialSelectedJenis = null;
                _showAddTaskDialog(context); // Memanggil metode untuk menampilkan dialog
              },
              child: const Icon(Icons.add),
              backgroundColor: Colors.blue,
            )
          : null, // Sembunyikan FAB di tab lain
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // --- Metode untuk Menampilkan Dialog Tambah/Edit Kegiatan ---
  void _showAddTaskDialog(BuildContext context, {Task? taskToEdit}) {
    // Isi controller dan variabel dengan data tugas yang akan diedit
    // Jika taskToEdit null, ini adalah mode tambah, jadi gunakan nilai awal.
    _namaKegiatanController.text = taskToEdit?.name ?? '';
    _detailKegiatanController.text = taskToEdit?.detail ?? '';

    // Gunakan variabel lokal di dalam builder untuk state dialog
    DateTime? dialogSelectedDate = taskToEdit?.date ?? _initialSelectedDate;
    DateTime? dialogSelectedDeadline = taskToEdit?.deadline ?? _initialSelectedDeadline;
    String? dialogSelectedStatus = taskToEdit?.status ?? _initialSelectedStatus;
    String? dialogSelectedJenis = taskToEdit?.type ?? _initialSelectedJenis;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text(taskToEdit == null ? 'Tambah Kegiatan Baru' : 'Edit Kegiatan'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        controller: _namaKegiatanController,
                        decoration: const InputDecoration(labelText: 'Nama Kegiatan'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama Kegiatan tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _detailKegiatanController,
                        decoration: const InputDecoration(labelText: 'Detail Kegiatan'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      // Tanggal Kegiatan
                      ListTile(
                        title: Text('Tanggal Kegiatan: ${dialogSelectedDate?.toLocal().toString().split(' ')[0] ?? 'Pilih Tanggal'}'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: dialogSelectedDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null && picked != dialogSelectedDate) {
                            setDialogState(() {
                              dialogSelectedDate = picked;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      // Status Kegiatan Dropdown
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
                      // Deadline Kegiatan (Tanggal dan Jam)
                      ListTile(
                        title: Text('Deadline: ${dialogSelectedDeadline?.toLocal().toString().split('.')[0] ?? 'Pilih Tanggal & Jam'}'),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: dialogSelectedDeadline ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            final TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(dialogSelectedDeadline ?? DateTime.now()),
                            );
                            if (pickedTime != null) {
                              setDialogState(() {
                                dialogSelectedDeadline = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                              });
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      // Jenis Kegiatan Dropdown
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
                      // Placeholder untuk Lampiran
                      Row(
                        children: [
                          const Expanded(
                            child: Text('Lampiran (Foto/Video/File)'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.attach_file),
                            onPressed: () {
                              print('Pilih Lampiran');
                            },
                          ),
                        ],
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
                      // Buat objek Task baru atau perbarui yang sudah ada
                      if (taskToEdit == null) {
                        final newTask = Task(
                          name: _namaKegiatanController.text,
                          detail: _detailKegiatanController.text.isNotEmpty ? _detailKegiatanController.text : null,
                          date: dialogSelectedDate ?? DateTime.now(),
                          status: dialogSelectedStatus ?? _statusOptions[0],
                          deadline: dialogSelectedDeadline,
                          type: dialogSelectedJenis ?? _jenisKegiatanOptions[0],
                          attachmentPath: null,
                        );
                        _taskBox.add(newTask);
                      } else {
                        // Perbarui objek Task yang ada
                        taskToEdit.name = _namaKegiatanController.text;
                        taskToEdit.detail = _detailKegiatanController.text.isNotEmpty ? _detailKegiatanController.text : null;
                        taskToEdit.date = dialogSelectedDate ?? DateTime.now();
                        taskToEdit.status = dialogSelectedStatus ?? _statusOptions[0];
                        taskToEdit.deadline = dialogSelectedDeadline;
                        taskToEdit.type = dialogSelectedJenis ?? _jenisKegiatanOptions[0];
                        // taskToEdit.attachmentPath = ...;
                        taskToEdit.save(); // Simpan perubahan ke Hive (HiveObject.save())
                      }

                      _loadTasks(); // Muat ulang daftar tugas untuk memperbarui UI
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

  // --- Metode untuk Konfirmasi dan Menghapus Kegiatan ---
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
                _taskBox.delete(taskKey); // Hapus tugas dari Hive berdasarkan key
                _loadTasks(); // Muat ulang daftar tugas
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // --- Metode untuk Membangun Halaman Tugas (Dashboard Kegiatan) ---
  Widget _buildTasksPage(BuildContext context) {
    // Filter tugas berdasarkan _selectedFilter
    List<Task> filteredTasks = _tasks.where((task) {
      if (_selectedFilter == 'Semua') {
        return true; // Tampilkan semua tugas
      } else if (task.type == _selectedFilter) { // Filter berdasarkan jenis kegiatan
        return true;
      }
      // Tambahkan filter status atau lainnya di sini jika diperlukan
      // Misalnya, jika ingin filter berdasarkan status:
      // else if (_selectedFilter == 'Belum Dimulai' && task.status == 'Belum Dimulai') {
      //   return true;
      // }
      return false; // Jika tidak ada filter yang cocok
    }).toList();

    bool hasTasks = filteredTasks.isNotEmpty;
    const String illustrationPath = 'assets/images/no_tasks_illustration.png';

    return Column(
      children: [
        // Header/Filter Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ruang untuk status bar di atas, sekarang akses context di sini
              SizedBox(height: MediaQuery.of(context).padding.top),

              // Bagian filter (Semua, Kerja, Pribadi, Wishlist)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    _buildFilterChip('Semua'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Kerja'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Pribadi'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Wishlist'),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        // Aksi untuk tombol 3 titik (opsi filter/pengaturan tambahan)
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: hasTasks
              ? _buildTaskList(filteredTasks) // <--- Lewatkan filteredTasks
              : _buildEmptyTasksState(illustrationPath),
        ),
      ],
    );
  }

  // Widget untuk membangun Chip Filter
  Widget _buildFilterChip(String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedFilter == label,
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            _selectedFilter = label; // Memperbarui state saat chip dipilih
          });
        }
      },
      selectedColor: Colors.blue[100],
      labelStyle: TextStyle(
        color: _selectedFilter == label ? Colors.blue[900] : Colors.grey[700],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: _selectedFilter == label ? Colors.blue : Colors.grey[300]!,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  // Widget untuk membangun daftar tugas (menampilkan dari Hive)
  Widget _buildTaskList(List<Task> tasks) { // Menerima daftar tugas yang difilter
    if (tasks.isEmpty) {
      return const Center(child: Text('Tidak ada tugas untuk ditampilkan dengan filter ini.'));
    }
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final taskKey = task.key; // HiveObject punya properti .key

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (task.detail != null && task.detail!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(task.detail!),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('Tanggal: ${task.date.toLocal().toString().split(' ')[0]}'),
                  ],
                ),
                if (task.deadline != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('Deadline: ${task.deadline!.toLocal().toString().split('.')[0]}'),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.category, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('Jenis: ${task.type}'),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('Status: ${task.status}'),
                  ],
                ),
                const SizedBox(height: 8), // Sedikit ruang sebelum tombol aksi
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        // Memanggil dialog yang sama, tapi dengan taskToEdit
                        _showAddTaskDialog(context, taskToEdit: task);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // Pastikan taskKey tidak null sebelum memanggil delete
                        if (taskKey != null) {
                          _confirmDeleteTask(context, taskKey, task.name);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tidak dapat menghapus: Task Key tidak ditemukan.')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget untuk membangun tampilan kosong (ilustrasi dan pesan)
  Widget _buildEmptyTasksState(String illustrationPath) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          illustrationPath,
          height: 200,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.assignment_turned_in,
              size: 150,
              color: Colors.grey,
            ); // Fallback icon jika gambar tidak ditemukan
          },
        ),
        const SizedBox(height: 30),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.amber[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'Klik di sini untuk membuat tugas pertamamu.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.brown,
            ),
          ),
        ),
      ],
    );
  }
}