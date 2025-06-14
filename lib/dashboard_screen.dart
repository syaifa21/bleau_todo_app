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
  late final List<Widget> _bottomNavPages; // Akan diinisialisasi di initState

  @override
  void initState() {
    super.initState();
    _bottomNavPages = <Widget>[
      _buildTasksPage(), // Sekarang memanggil metode non-statis
      const Center(child: Text('Halaman Kalender')),
      const Center(child: Text('Halaman Milikku')),
    ];
  }

  void _onBottomNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _bottomNavPages.elementAt(_selectedIndex),

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
  // Sekarang bukan static
  Widget _buildTasksPage() {
    bool hasTasks = false; // Ganti ini dengan logika pengecekan tugas

    return Column(
      children: [
        // Header/Filter Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              ? _buildTaskList()
              : _buildEmptyTasksState(),
        ),
      ],
    );
  }

  // Widget untuk membangun Chip Filter (Sekarang bukan static)
  Widget _buildFilterChip(String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedFilter == label,
      onSelected: (bool selected) {
        setState(() {
          _selectedFilter = label; // Memperbarui state saat chip dipilih
        });
      },
      selectedColor: Colors.blue[100],
      labelStyle: TextStyle(
        color: _selectedFilter == label ? Colors.blue[900] : Colors.grey[700],
      ),
    );
  }

  // Widget untuk membangun daftar tugas (placeholder)
  Widget _buildTaskList() {
    return const Center(
      child: Text('Daftar Tugas Akan Tampil Di Sini'),
    );
  }

  // Widget untuk membangun tampilan kosong (ilustrasi dan pesan)
  Widget _buildEmptyTasksState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Placeholder Ilustrasi
        Image.asset(
          'assets/images/no_tasks_illustration.png',
          height: 200,
        ),
        const SizedBox(height: 30),
        // Kotak pesan "Klik di sini untuk membuat tugas pertamamu."
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