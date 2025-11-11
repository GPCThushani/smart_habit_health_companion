// lib/models/reminder.dart
class Reminder {
  final int? id;
  final String title;
  final int hour;
  final int minute;
  final int? notifyId;

  Reminder({this.id, required this.title, required this.hour, required this.minute, this.notifyId});

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'hour': hour,
        'minute': minute,
        'notifyId': notifyId,
      };

  factory Reminder.fromMap(Map<String, dynamic> m) => Reminder(
        id: m['id'],
        title: m['title'],
        hour: m['hour'],
        minute: m['minute'],
        notifyId: m['notifyId'],
      );
}
