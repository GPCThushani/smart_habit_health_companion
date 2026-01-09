import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../main.dart'; // This is needed to access 'flutterLocalNotificationsPlugin' from main.dart

class NotifyHelper {
  // 'static' is allowed here inside a class
  static Future<void> scheduleDaily(int id, String title, int hour, int minute) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Reminder', 
      title,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel', 
          'Reminders',
          importance: Importance.max, 
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancel(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}