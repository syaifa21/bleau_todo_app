  import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // Untuk mengelola indeks navigasi bawah
  String _selectedFilter = 'Semua'; // Untuk mengelola filter kegiatan yang dipilih

  // Daftar halaman untuk Bottom Navigation Bar
  static final List<Widget> _bottomNavPages = <Widget>[
    _buildTasksPage(), // Ini akan kita isi dengan UI Dashboard Kegiatan
    const Center(child: Text('Halaman Kalender')), // Placeholder
    const Center(child: Text('Halaman Milikku')), // Placeholder
  ];

  void _onBottomNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar dihilangkan karena kita akan membuat header kustom di body
      body: _bottomNavPages.elementAt(_selectedIndex), // Menampilkan halaman sesuai Bottom Nav

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
          print('Tombol Tambah ditekan!');
          // TODO: Nanti akan memicu pop-up tambah kegiatan
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // --- Metode Baru untuk Membangun Halaman Tugas (Dashboard Kegiatan) ---
  static Widget _buildTasksPage() {
    // Untuk sementara, ini akan menampilkan konten kosong
    // Nanti akan kita kembangkan untuk menampilkan daftar tugas
    bool hasTasks = false; // Ganti ini dengan logika pengecekan tugas

    return Column(
      children: [
        // Header/Filter Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Placeholder untuk area status bar (waktu, sinyal, dll.)
              // Di sini kita tidak bisa langsung mengakses status bar OS
              // Tapi kita bisa memberikan padding atau SizedBox untuk menjaga ruang
              const SizedBox(height: 24), // Memberikan ruang di atas untuk status bar

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
                    // Tombol 3 titik di desain bisa jadi menu tambahan
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        // Aksi untuk tombol 3 titik
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
              ? _buildTaskList() // Nanti akan menampilkan daftar tugas
              : _buildEmptyTasksState(), // Menampilkan ilustrasi dan pesan
        ),
      ],
    );
  }

  // Widget untuk membangun Chip Filter
  static Widget _buildFilterChip(String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedFilter == label, // Perbaikan: _selectedFilter tidak statis
      onSelected: (bool selected) {
        // Perbaikan: Tidak bisa menggunakan setState di metode statis
        // Aksi pemilihan chip akan ditangani di stateful widget utama
        // Untuk saat ini, kita biarkan kosong atau print saja
        print('Filter $label dipilih: $selected');
      },
      selectedColor: Colors.blue[100], // Warna latar belakang saat dipilih
      labelStyle: TextStyle(
        color: _selectedFilter == label ? Colors.blue[900] : Colors.grey[700], // Warna teks
      ),
    );
  }

  // Widget untuk membangun daftar tugas (placeholder)
  static Widget _buildTaskList() {
    return const Center(
      child: Text('Daftar Tugas Akan Tampil Di Sini'),
    );
  }

  // Widget untuk membangun tampilan kosong (ilustrasi dan pesan)
  static Widget _buildEmptyTasksState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Placeholder Ilustrasi
        Image.asset(
          'assets/images/no_tasks_illustration.png', // Ganti dengan path ilustrasi aslimu
          height: 200,
        ),
        const SizedBox(height: 30),
        // Kotak pesan "Klik di sini untuk membuat tugas pertamamu."
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.amber[200], // Warna kuning yang mirip desain
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