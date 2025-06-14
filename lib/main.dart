import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Import Hive Flutter
import 'package:bleau_todo_app/dashboard_screen.dart';
import 'package:bleau_todo_app/models/task.dart'; // Import model Task

void main() async { // Ubah main menjadi async
  WidgetsFlutterBinding.ensureInitialized(); // Pastikan Flutter diinisialisasi

  await Hive.initFlutter(); // Inisialisasi Hive
  Hive.registerAdapter(TaskAdapter()); // Daftarkan TaskAdapter

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bleu Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}