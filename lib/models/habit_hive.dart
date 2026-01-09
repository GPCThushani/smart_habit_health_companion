import 'package:hive/hive.dart';

part 'habit_hive.g.dart';

@HiveType(typeId: 0)
class HabitHive extends HiveObject {
  @HiveField(0)
  String id; // string id (timestamp-based) to work on web

  @HiveField(1)
  String title;

  @HiveField(2)
  String? notes;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  int? reminderHour;

  @HiveField(5)
  int? reminderMinute;

  @HiveField(6)
  String createdAtIso; // ISO string

  HabitHive({
    required this.id,
    required this.title,
    this.notes,
    this.isCompleted = false,
    this.reminderHour,
    this.reminderMinute,
    String? createdAtIso,
  }) : createdAtIso = createdAtIso ?? DateTime.now().toIso8601String();
}
