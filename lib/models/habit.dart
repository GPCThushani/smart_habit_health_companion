class Habit {
  final int? id;
  final String title;
  final String? notes;
  final bool isCompleted;
  final int? reminderHour;
  final int? reminderMinute;
  final int? notifyId;
  final DateTime? createdAt;

  Habit({
    this.id,
    required this.title,
    this.notes,
    this.isCompleted = false,
    this.reminderHour,
    this.reminderMinute,
    this.notifyId,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'notes': notes,
        'isCompleted': isCompleted ? 1 : 0,
        'reminderHour': reminderHour,
        'reminderMinute': reminderMinute,
        'notifyId': notifyId,
        'createdAt': createdAt?.toIso8601String(),
      };

  factory Habit.fromMap(Map<String, dynamic> m) => Habit(
        id: m['id'],
        title: m['title'],
        notes: m['notes'],
        isCompleted: (m['isCompleted'] ?? 0) == 1,
        reminderHour: m['reminderHour'],
        reminderMinute: m['reminderMinute'],
        notifyId: m['notifyId'],
        createdAt: m['createdAt'] != null ? DateTime.parse(m['createdAt']) : null,
      );
}
