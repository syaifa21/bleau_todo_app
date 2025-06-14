  import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // Untuk mengelola indeks navigasi bawah

  // Daftar widget/halaman yang akan ditampilkan berdasarkan BottomNavigationBar
  static final List<Widget> _widgetOptions = <Widget>[
    const Text('Halaman Tugas (Dashboard Kegiatan)'), // Placeholder untuk halaman tugas
    const Text('Halaman Kalender'), // Placeholder untuk halaman kalender
    const Text('Halaman Milikku'), // Placeholder untuk halaman profil
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bleu Todo App'), // Judul di AppBar
        elevation: 0, // Menghilangkan bayangan di bawah AppBar
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex), // Menampilkan halaman sesuai indeks
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment), // Ikon tugas
            label: 'Tugas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today), // Ikon kalender
            label: 'Kalender',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), // Ikon profil
            label: 'Milikku',
          ),
        ],
        currentIndex: _selectedIndex, // Indeks item yang sedang aktif
        selectedItemColor: Colors.blue, // Warna ikon/teks item yang dipilih
        onTap: _onItemTapped, // Fungsi yang dipanggil saat item diketuk
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aksi saat Floating Action Button ditekan
          print('Tombol Tambah ditekan!');
          // Nanti kita akan buka Pop Up Tambah Kegiatan di sini
        },
        child: const Icon(Icons.add), // Ikon plus
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Posisi FAB
    );
  }
}
```