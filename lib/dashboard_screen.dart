import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // Untuk mengelola indeks navigasi bawah
  String _selectedFilter = 'Semua'; // Untuk mengelola filter kegiatan yang dipilih

  // Controller untuk inputan dialog
  final TextEditingController _namaKegiatanController = TextEditingController();
  final TextEditingController _detailKegiatanController = TextEditingController();

  // Variabel untuk Datepicker & Dropdown di dialog
  DateTime? _selectedDate;
  DateTime? _selectedDeadline;
  String? _selectedStatus;
  String? _selectedJenis;

  // Daftar opsi untuk Status Kegiatan
  final List<String> _statusOptions = ['Belum Dimulai', 'Dalam Proses', 'Selesai'];

  // Daftar opsi untuk Jenis Kegiatan (bisa diperluas nanti)
  final List<String> _jenisKegiatanOptions = ['Pribadi', 'Kerja', 'Wishlist', 'Lainnya'];

  // GlobalKey untuk form validasi
  final _formKey = GlobalKey<FormState>();

  // Daftar halaman untuk Bottom Navigation Bar
  // KITA AKAN HAPUS INISIALISASI DI SINI DAN PINDAHKAN KE BUILD METHOD
  // late final List<Widget> _bottomNavPages; // <--- HAPUS BARIS INI

  @override
  void initState() {
    super.initState();
    // Kita tidak akan menginisialisasi _bottomNavPages di sini lagi
    // Karena _buildTasksPage bergantung pada context yang belum sepenuhnya siap.
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
    // Inisialisasi _bottomNavPages DI SINI (di dalam build method)
    // agar _buildTasksPage bisa mengakses context dengan aman.
    final List<Widget> bottomNavPages = <Widget>[
      _buildTasksPage(context), // <--- Lewatkan context ke _buildTasksPage
      const Center(child: Text('Halaman Kalender')),
      const Center(child: Text('Halaman Milikku')),
    ];

    return Scaffold(
      body: bottomNavPages.elementAt(_selectedIndex), // Gunakan variabel lokal

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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context); // Memanggil metode untuk menampilkan dialog
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // --- Metode untuk Menampilkan Dialog Tambah Kegiatan ---
  void _showAddTaskDialog(BuildContext context) {
    // Reset nilai form sebelum membuka dialog
    _namaKegiatanController.clear();
    _detailKegiatanController.clear();
    // Menggunakan variabel lokal di dalam builder untuk state dialog
    DateTime? dialogSelectedDate = DateTime.now(); // Default tanggal hari ini
    DateTime? dialogSelectedDeadline = null;
    String? dialogSelectedStatus = null;
    String? dialogSelectedJenis = null;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Menggunakan StatefulBuilder untuk memungkinkan setState di dalam dialog
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text('Tambah Kegiatan Baru'),
              content: SingleChildScrollView(
                child: Form( // Gunakan Form untuk validasi
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
                        title: Text('Tanggal Kegiatan: ${dialogSelectedDate != null ? dialogSelectedDate!.toLocal().toString().split(' ')[0] : 'Pilih Tanggal'}'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: dialogSelectedDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null && picked != dialogSelectedDate) {
                            setDialogState(() { // Gunakan setDialogState untuk memperbarui UI dialog
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
                          setDialogState(() { // Gunakan setDialogState
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
                        title: Text('Deadline: ${dialogSelectedDeadline != null ? dialogSelectedDeadline!.toLocal().toString().split('.')[0] : 'Pilih Tanggal & Jam'}'),
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
                              setDialogState(() { // Gunakan setDialogState
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
                          setDialogState(() { // Gunakan setDialogState
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
                              // TODO: Logika untuk memilih file akan ditambahkan di sini
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
                      // Data yang akan disimpan adalah dari variabel lokal dialog
                      print('Nama Kegiatan: ${_namaKegiatanController.text}');
                      print('Detail Kegiatan: ${_detailKegiatanController.text}');
                      print('Tanggal Kegiatan: ${dialogSelectedDate?.toIso8601String()}');
                      print('Status Kegiatan: $dialogSelectedStatus');
                      print('Deadline: ${dialogSelectedDeadline?.toIso8601String()}');
                      print('Jenis Kegiatan: $dialogSelectedJenis');

                      // TODO: Simpan data ke database lokal (Hive/Isar/Sqflite)
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

  // --- Metode untuk Membangun Halaman Tugas (Dashboard Kegiatan) ---
  // Sekarang menerima BuildContext sebagai parameter
  Widget _buildTasksPage(BuildContext context) { // <--- TAMBAHKAN BuildContext context
    bool hasTasks = false; // Akan diganti dengan logika pengecekan data tugas
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
              SizedBox(height: MediaQuery.of(context).padding.top), // <--- AMAN DI SINI SEKARANG

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
              ? _buildTaskList() // Akan menampilkan daftar tugas jika ada
              : _buildEmptyTasksState(illustrationPath), // Menampilkan ilustrasi dan pesan kosong
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
        borderRadius: BorderRadius.circular(20), // Membuat sudut lebih membulat
        side: BorderSide(
          color: _selectedFilter == label ? Colors.blue : Colors.grey[300]!, // Border saat dipilih
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  // Widget untuk membangun daftar tugas (placeholder)
  Widget _buildTaskList() {
    return const Center(
      child: Text('Daftar Tugas Akan Tampil Di Sini'),
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