import 'package:flutter/material.dart';
// Pastikan import ini sesuai dengan nama paket di pubspec.yaml
import 'package:bleau_todo_app/dashboard_screen.dart'; // Nama paketmu: bleau_todo_app

void main() {
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