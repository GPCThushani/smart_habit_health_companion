import 'package:hive/hive.dart';
import 'models/habit_hive.dart';
import 'models/reminder_hive.dart';

class HiveService {
  static const String habitBoxName = 'habits_box';
  static const String reminderBoxName = 'reminders_box';

  // open boxes
  static Future<void> init() async {
    await Hive.openBox<HabitHive>(habitBoxName);
    await Hive.openBox<ReminderHive>(reminderBoxName);
  }

  // Habits
  static Box<HabitHive> habitBox() => Hive.box<HabitHive>(habitBoxName);

  static Future<void> addHabit(HabitHive h) async {
    final box = habitBox();
    await box.put(h.id, h);
  }

  static Future<void> updateHabit(HabitHive h) async {
    await h.save();
  }

  static List<HabitHive> getAllHabits() => habitBox().values.toList();

  static Future<void> deleteHabit(String id) async {
    final box = habitBox();
    await box.delete(id);
  }

  // Reminders
  static Box<ReminderHive> reminderBox() => Hive.box<ReminderHive>(reminderBoxName);

  static Future<void> addReminder(ReminderHive r) async {
    final box = reminderBox();
    await box.put(r.id, r);
  }

  static List<ReminderHive> getAllReminders() => reminderBox().values.toList();

  static Future<void> deleteReminder(String id) async {
    final box = reminderBox();
    await box.delete(id);
  }
}
