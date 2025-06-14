import 'package:hive/hive.dart';

part 'task.g.dart'; // Ini akan otomatis dibuat oleh build_runner

@HiveType(typeId: 0) // TypeId harus unik untuk setiap model Hive
class Task extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String? detail;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String status;

  @HiveField(4)
  DateTime? deadline;

  @HiveField(5)
  String type;

  @HiveField(6)
  String? attachmentPath; // Path ke file lampiran di perangkat

  Task({
    required this.name,
    this.detail,
    required this.date,
    required this.status,
    this.deadline,
    required this.type,
    this.attachmentPath,
  });
}