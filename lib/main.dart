// Path: lib/main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bleau_todo_app/dashboard_screen.dart';
import 'package:bleau_todo_app/models/task.dart';
import 'package:intl/date_symbol_data_local.dart'; // Tambahkan ini

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());

  // *** PERBAIKAN UNTUK LocaleDataException ***
  // Inisialisasi data locale untuk 'id_ID'
  await initializeDateFormatting('id_ID', null); // Panggil ini sebelum runApp

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bleu Todo App',
      theme: ThemeData(
        primarySwatch: Colors.cyan, // Menggunakan Colors.cyan sebagai primarySwatch
        primaryColor: const Color(0xFF4DD0E1), // Biru muda ke cyan (Light Cyan)
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.cyan,
          accentColor: const Color(0xFF00BCD4), // Cyan lebih terang untuk aksen
          brightness: Brightness.light,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Montserrat', // Hapus jika tidak ada font ini
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat', // Hapus jika tidak ada font ini
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF00BCD4), // Sesuaikan dengan warna aksen cyan
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF00BCD4)), // Sesuaikan dengan warna aksen cyan
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00BCD4), // Sesuaikan dengan warna aksen cyan
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
        dropdownMenuTheme: const DropdownMenuThemeData( // Menggunakan const jika properti dalamnya juga const
          textStyle: TextStyle(color: Colors.black87),
        ),
      ),
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}