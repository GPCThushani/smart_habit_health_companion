import 'package:hive/hive.dart';

part 'reminder_hive.g.dart';

@HiveType(typeId: 1)
class ReminderHive extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  int hour;

  @HiveField(3)
  int minute;

  @HiveField(4)
  String createdAtIso;

  @HiveField(5)
  bool sent; // whether server has marked it sent

  ReminderHive({
    required this.id,
    required this.title,
    required this.hour,
    required this.minute,
    String? createdAtIso,
    this.sent = false,
  }) : createdAtIso = createdAtIso ?? DateTime.now().toIso8601String();
}
