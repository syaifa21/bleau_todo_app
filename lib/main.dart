// Path: lib/main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bleau_todo_app/dashboard_screen.dart';
import 'package:bleau_todo_app/models/task.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:bleau_todo_app/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());

  await initializeDateFormatting('id_ID', null);

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeModeManager(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModeManager>(
      builder: (context, themeModeManager, child) {
        return MaterialApp(
          title: 'Bleu Todo App',
          // Tentukan tema terang
          theme: ThemeData(
            primarySwatch: Colors.cyan,
            primaryColor: const Color(0xFF4DD0E1),
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.cyan,
              accentColor: const Color(0xFF00BCD4),
              brightness: Brightness.light,
            ),
            visualDensity: VisualDensity.adaptivePlatformDensity,
            fontFamily: 'Montserrat',
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
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
              backgroundColor: Color(0xFF00BCD4),
              foregroundColor: Colors.white,
              elevation: 4,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF00BCD4)),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
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
            dropdownMenuTheme: const DropdownMenuThemeData(
              textStyle: TextStyle(color: Colors.black87),
            ),
          ),
          // Tentukan tema gelap
          darkTheme: ThemeData(
            primarySwatch: Colors.cyan,
            primaryColor: const Color(0xFF00BCD4), // Warna primer gelap (cyan)
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.cyan,
              accentColor: const Color(0xFF4DD0E1), // Aksen terang untuk gelap
              brightness: Brightness.dark, // Penting: atur ke dark
              // cardColor dan canvasColor adalah properti dari ThemeData, bukan ColorScheme.fromSwatch.
              // Mereka harus didefinisikan di luar ColorScheme.fromSwatch.
              // Namun, untuk tema modern, disarankan menggunakan properti ColorScheme: surface dan background.
              // Saya akan memindahkannya ke sini sebagai properti ThemeData:
            ),
            scaffoldBackgroundColor: Colors.grey[900], // Warna latar belakang scaffold gelap
            cardColor: Colors.grey[850], // Warna kartu lebih gelap <-- DIPINDAH KE SINI
            canvasColor: Colors.grey[900], // Warna latar belakang material/canvas gelap <-- DIPINDAH KE SINI
            visualDensity: VisualDensity.adaptivePlatformDensity,
            fontFamily: 'Montserrat',
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey[900],
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
              ),
            ),
            cardTheme: CardThemeData(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[850], // Warna kartu gelap (ini mengesampingkan cardColor di atas jika ada konflik)
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF4DD0E1), // Aksen terang untuk FAB gelap
              foregroundColor: Colors.white,
              elevation: 4,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF4DD0E1)),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4DD0E1),
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
              fillColor: Colors.grey[800], // Warna isian input gelap
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              hintStyle: TextStyle(color: Colors.grey[500]),
            ),
            dropdownMenuTheme: const DropdownMenuThemeData(
              textStyle: TextStyle(color: Colors.white),
            ),
          ),
          themeMode: themeModeManager.themeMode, // Menggunakan themeMode dari manager
          home: const DashboardScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}